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

class DeeplinkManager {
    static let shared = DeeplinkManager()

    private var currentDeeplink: Deeplinking?
    private var callbackWrapper: DeeplinkCompletionHandler?

    private var waitingOnSystemPromptResponse = false
    private var checkingSystemPromptResponse = false
    private var promptTimer: Timer?

    func open(_ deeplink: Deeplinking, completion: DeeplinkCompletionHandler? = nil) {
        open(deeplink.url, completion: completion)
    }

    func open(_ url: URL, completion: DeeplinkCompletionHandler? = nil) {
        if #available(iOS 9.0, *) {
            executeOnIOS9(deeplink: url, callback: completion)
        } else {
            executeOnBelowIOS9(deeplink: url, callback: completion)
        }
    }

    //Mark: Internal Interface

    private func executeOnIOS9(deeplink url: URL, callback: DeeplinkCompletionHandler?) {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActiveHandler), name: Notification.Name.UIApplicationWillResignActive, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveHandler), name: Notification.Name.UIApplicationDidBecomeActive, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackgroundHandler), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)

        callbackWrapper = { handled in
            NotificationCenter.default.removeObserver(self)
            self.promptTimer?.invalidate()
            self.promptTimer = nil
            self.checkingSystemPromptResponse = false
            self.waitingOnSystemPromptResponse = false
            callback?(handled)
        }

        var error: NSError?
        if UIApplication.shared.canOpenURL(url) {
            let openedURL = UIApplication.shared.openURL(url)
            if !openedURL {
                error = DeeplinkErrorFactory.errorForType(.unableToFollow)
            }
        } else {
            error = DeeplinkErrorFactory.errorForType(.unableToOpen)
        }

        if error != nil {
            callbackWrapper?(error)
        }
    }

    private func executeOnBelowIOS9(deeplink url: URL, callback: DeeplinkCompletionHandler?) {
        callbackWrapper = { handled in
            callback?(handled)
        }

        var error: NSError?
        if UIApplication.shared.canOpenURL(url) {
            let openedURL = UIApplication.shared.openURL(url)
            if !openedURL {
                error = DeeplinkErrorFactory.errorForType(.unableToFollow)
            }
        } else {
            error = DeeplinkErrorFactory.errorForType(.unableToOpen)
        }

        callbackWrapper?(error)
    }

    //Mark: App Lifecycle Notifications

    @objc private func appWillResignActiveHandler(_ notification: Notification) {
        if !waitingOnSystemPromptResponse {
            waitingOnSystemPromptResponse = true
        } else if checkingSystemPromptResponse {
            callbackWrapper?(nil)
        }
    }

    @objc private func appDidBecomeActiveHandler(_ notification: Notification) {
        if waitingOnSystemPromptResponse {
            checkingSystemPromptResponse = true
            promptTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(deeplinkHelper), userInfo: nil, repeats: false)
        }
    }

    @objc private func appDidEnterBackgroundHandler(_ notification: Notification) {
        callbackWrapper?(nil)
    }

    @objc private func deeplinkHelper() {
        let error = DeeplinkErrorFactory.errorForType(.deeplinkNotFollowed)
        callbackWrapper?(error)
    }
}
