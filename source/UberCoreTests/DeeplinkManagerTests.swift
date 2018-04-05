//
//  DeeplinkManagerTests.swift
//  UberCoreTests
//
//  Created by Edward Jiang on 12/5/17.
//  Copyright © 2017 Uber. All rights reserved.
//

import XCTest
@testable import UberCore

class DeeplinkManagerTests: XCTestCase {
    private var deeplinkManager: DeeplinkManager!
    private var urlOpener: URLOpeningMock!
    private var testDeeplink: TestDeeplink!

    override func setUp() {
        super.setUp()

        deeplinkManager = DeeplinkManager()
        urlOpener = URLOpeningMock()
        deeplinkManager.urlOpener = urlOpener
        testDeeplink = TestDeeplink()
    }

    func testDeeplinkOpensFirstURL() {
        let expectCallback = self.expectation(description: "Callback is run")
        urlOpener.openURLHandler = { url in
            return true // All URLS can open
        }
        openDeeplink(testDeeplink) { error in
            XCTAssertNil(error)
            expectCallback.fulfill()
        }
        XCTAssertEqual(urlOpener.openURLCallCount, 1)

        self.waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testDeeplinkOpensSecondURL() {
        let expectCorrectURLScheme = self.expectation(description: "We need to open up the app2 URL scheme")
        let expectCallback = self.expectation(description: "Callback is run")
        urlOpener.openURLHandler = { url in
            if url.scheme == "app2" {
                expectCorrectURLScheme.fulfill()
            }
            return url.scheme == "app2"
        }
        openDeeplink(testDeeplink) { error in
            XCTAssertNil(error)
            expectCallback.fulfill()
        }
        XCTAssertEqual(urlOpener.openURLCallCount, 2)

        self.waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testDeeplinkErrorsWhenNoFallbacks() {
        let expectCallback = self.expectation(description: "Callback is run")
        urlOpener.openURLHandler = { url in
            return false
        }
        openDeeplink(testDeeplink) { error in
            let expectedError = DeeplinkErrorFactory.errorForType(DeeplinkErrorType.unableToOpen)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, expectedError)
            expectCallback.fulfill()
        }
        XCTAssertEqual(urlOpener.openURLCallCount, 4)

        self.waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testDeeplinkOpensURLWhenIOSPromptsPermission() {
        let expectCallback = self.expectation(description: "Callback is run")
        urlOpener.openURLHandler = { url in
            return true // All URLS can open
        }
        openDeeplinkWithSuccessfulPrompt(testDeeplink) { error in
            XCTAssertNil(error)
            expectCallback.fulfill()
        }
        XCTAssertEqual(urlOpener.openURLCallCount, 1)

        self.waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testDeeplinkErrorsWhenUserDeniesPermission() {
        let expectCallback = self.expectation(description: "Callback is run")
        urlOpener.openURLHandler = { url in
            return true // All URLS can open
        }
        openDeeplinkWithCancelledPrompt(testDeeplink) { error in
            let expectedError = DeeplinkErrorFactory.errorForType(.deeplinkNotFollowed)
            XCTAssertEqual(error, expectedError)
            expectCallback.fulfill()
        }
        XCTAssertEqual(urlOpener.openURLCallCount, 1)

        self.waitForExpectations(timeout: 0.5, handler: nil)
    }

    private func openDeeplink(_ deeplink: Deeplinking, completion: @escaping DeeplinkCompletionHandler) {
        deeplinkManager.open(deeplink, completion: completion)
        NotificationCenter.default.post(Notification(name: Notification.Name.UIApplicationDidEnterBackground))
    }

    private func openDeeplinkWithSuccessfulPrompt(_ deeplink: Deeplinking, completion: @escaping DeeplinkCompletionHandler) {
        deeplinkManager.open(deeplink, completion: completion)
        NotificationCenter.default.post(Notification(name: Notification.Name.UIApplicationWillResignActive))
        NotificationCenter.default.post(Notification(name: Notification.Name.UIApplicationDidBecomeActive))
        NotificationCenter.default.post(Notification(name: Notification.Name.UIApplicationDidEnterBackground))
    }

    private func openDeeplinkWithCancelledPrompt(_ deeplink: Deeplinking, completion: @escaping DeeplinkCompletionHandler) {
        deeplinkManager.open(deeplink, completion: completion)
        NotificationCenter.default.post(Notification(name: Notification.Name.UIApplicationWillResignActive))
        NotificationCenter.default.post(Notification(name: Notification.Name.UIApplicationDidBecomeActive))    }
}

private class TestDeeplink: Deeplinking {
    func execute(completion: DeeplinkCompletionHandler?) {}

    var url: URL = URL(string: "app1://test")!
    var fallbackURLs: [URL] = [URL(string: "app2://test")!,
                               URL(string: "app3://test")!,
                               URL(string: "https://test")!]
}

private class URLOpeningMock: URLOpening {
    var canOpenURLCallCount = 0
    var canOpenURLHandler: ((URL) -> Bool)?
    func canOpenURL(_ url: URL) -> Bool {
        canOpenURLCallCount += 1

        return canOpenURLHandler?(url) ?? false
    }

    var openURLCallCount = 0
    var openURLHandler: ((URL) -> Bool)?
    func openURL(_ url: URL) -> Bool {
        openURLCallCount += 1

        return openURLHandler?(url) ?? false
    }
}
