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
        if urlOpener.canOpenURL(url) {
            urlOpener.open(url, completionHandler: { (succeeded) in
                if !succeeded {
                    self.deeplinkDidFinish(error: DeeplinkErrorFactory.errorForType(.unableToFollow))
                }
                else {
                    self.deeplinkDidFinish(error: nil)
                }
            })
        } else {
            deeplinkDidFinish(error: DeeplinkErrorFactory.errorForType(.unableToOpen))
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
        
        callback?(error)

        self.urlQueue = []
        self.callback = nil
    }

    @objc private func deeplinkHelper() {
        let error = DeeplinkErrorFactory.errorForType(.deeplinkNotFollowed)
        deeplinkDidFinish(error: error)
    }
}

public protocol URLOpening {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, completionHandler: ((Bool) -> Void)?)
}

extension UIApplication: URLOpening {
    
    public func open(_ url: URL, completionHandler: ((Bool) -> Void)?) {
        open(url, options: [:], completionHandler: completionHandler)
    }
}
