//
//  DeeplinkManager.swift
//  UberCore
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

/**
 The Deeplink Manager keeps track of an external URL being opened.
 */
class DeeplinkManager {
    static let shared = DeeplinkManager()
    var urlOpener: URLOpening = UIApplication.shared

    private var urlQueue: [URL] = []
    private var callback: DeeplinkCompletionHandler?

    private var waitingOnSystemPromptResponse = false
    private var checkingSystemPromptResponse = false
    private var promptTimer: Timer?

    /// Open a deeplink, utilizing its fallback URLs.
    func open(_ deeplink: Deeplinking, completion: DeeplinkCompletionHandler? = nil) {
        urlQueue = deeplink.fallbackURLs

        open(deeplink.url, completion: completion)
    }

    /// Open a URL
    func open(_ url: URL, completion: DeeplinkCompletionHandler? = nil) {
        callback = completion

        open(url)
    }

    //Mark: Internal Interface

    private func open(_ url: URL) {
        if #available(iOS 10.0, *) {
            executeOnIOS10(deeplink: url)
        }
        else if #available(iOS 9.0, *) {
            executeOnIOS9(deeplink: url)
        } else {
            executeOnBelowIOS9(deeplink: url)
        }
    }

    private func deeplinkDidFinish(error: NSError?) {
        if error != nil && !urlQueue.isEmpty &&
            error != DeeplinkErrorFactory.errorForType(.deeplinkNotFollowed) {
            // There is an error AND urlQueue is NOT empty.
            // Also, it's not a user cancelled deeplink.
            // Thus we will try opening the next url in the queue.
            open(urlQueue.removeFirst())
            return
        }
        if #available(iOS 9.0, *) {
            NotificationCenter.default.removeObserver(self)
            self.promptTimer?.invalidate()
            self.promptTimer = nil
            self.checkingSystemPromptResponse = false
            self.waitingOnSystemPromptResponse = false
        }

        callback?(error)

        self.urlQueue = []
        self.callback = nil
    }

    @available(iOS 10.0, *)
    private func executeOnIOS10(deeplink url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (succeeded) in
                if !succeeded {
                    self.deeplinkDidFinish(error: DeeplinkErrorFactory.errorForType(.deeplinkNotFollowed))
                }
                else {
                    self.deeplinkDidFinish(error: nil)
                }
            })
        } else {
            deeplinkDidFinish(error: DeeplinkErrorFactory.errorForType(.unableToOpen))
        }
    }

    private func executeOnIOS9(deeplink url: URL) {
        subscribeToNotifications()

        var error: NSError?
        let openedURL = urlOpener.openURL(url)
        if !openedURL {
            error = DeeplinkErrorFactory.errorForType(.unableToOpen)
        }

        if error != nil {
            deeplinkDidFinish(error: error)
        }
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActiveHandler), name: Notification.Name.UIApplicationWillResignActive, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveHandler), name: Notification.Name.UIApplicationDidBecomeActive, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackgroundHandler), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    private func executeOnBelowIOS9(deeplink url: URL) {
        var error: NSError?
        if urlOpener.canOpenURL(url) {
            let openedURL = urlOpener.openURL(url)
            if !openedURL {
                error = DeeplinkErrorFactory.errorForType(.unableToFollow)
            }
        } else {
            error = DeeplinkErrorFactory.errorForType(.unableToOpen)
        }

        deeplinkDidFinish(error: error)
    }

    // Mark: App Lifecycle Notifications

    @objc private func appWillResignActiveHandler(_ notification: Notification) {
        if !waitingOnSystemPromptResponse {
            waitingOnSystemPromptResponse = true
        } else if checkingSystemPromptResponse {
            deeplinkDidFinish(error: nil)
        }
    }

    @objc private func appDidBecomeActiveHandler(_ notification: Notification) {
        if waitingOnSystemPromptResponse {
            checkingSystemPromptResponse = true
            promptTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(deeplinkHelper), userInfo: nil, repeats: false)
        }
    }

    @objc private func appDidEnterBackgroundHandler(_ notification: Notification) {
        deeplinkDidFinish(error: nil)
    }

    @objc private func deeplinkHelper() {
        let error = DeeplinkErrorFactory.errorForType(.deeplinkNotFollowed)
        deeplinkDidFinish(error: error)
    }
}

protocol URLOpening {
    func canOpenURL(_ url: URL) -> Bool
    func openURL(_ url: URL) -> Bool
}

extension UIApplication: URLOpening {}
