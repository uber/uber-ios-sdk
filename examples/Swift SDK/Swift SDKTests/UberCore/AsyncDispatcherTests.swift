//
//  AsyncDispatcherTests.swift
//  UberRides
//
//  Copyright © 2018 Uber Technologies, Inc. All rights reserved.
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


import XCTest
@testable import UberCore

class AsyncDispatcherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCallsAllClosures() {
        let urls: [URL] = [ URL(string: "http://www.google.com")! ]

        let withExp = XCTestExpectation(description: "with closure should be called")
        let continueExp = XCTestExpectation(description: "continue closure should be called")
        let finallyExp = XCTestExpectation(description: "finally closure should be called")

        var finallyCallCount = 0
        var currentUrlIndex = 0

        AsyncDispatcher.exec(for: urls,
                             with: { (url: URL) in
                                XCTAssertEqual(url, urls[currentUrlIndex])
                                currentUrlIndex += 1

                                withExp.fulfill()
                             },
                             asyncMethod: openURLTestMethod(_:completion:),
                             continue: { (error: NSError?) -> Bool in
                                continueExp.fulfill()
                                return true
                             },
                             finally: {
                                finallyCallCount += 1
                                XCTAssertEqual(finallyCallCount, 1)

                                finallyExp.fulfill()
                             })

        wait(for: [withExp, continueExp, finallyExp], timeout: 0.1)
    }

    func testExitsInterationEarly() {
        let urls: [URL] = [ URL(string: "http://www.google.com")!,
                            URL(string: "http://www.uber.com")!,
                            URL(string: "http://www.facebook.com")! ]

        let finallyExp = XCTestExpectation(description: "finally closure should be called")

        var emittedErrors = [NSError]()

        AsyncDispatcher.exec(for: urls,
                             with: { _ in },
                             asyncMethod: openURLTestMethod(_:completion:),
                             continue: { (error: NSError?) -> Bool in
                                if let error = error {
                                    emittedErrors.append(error)
                                    if error.domain == "http://www.uber.com" {
                                        return false
                                    }
                                }
                                return true
                             },
                             finally: {
                                finallyExp.fulfill()
                             })

        wait(for: [finallyExp], timeout: 0.1)

        let expectedErrors = [ NSError(domain: "http://www.google.com", code: 0, userInfo: nil),
                               NSError(domain: "http://www.uber.com", code: 0, userInfo: nil) ]

        XCTAssertEqual(emittedErrors, expectedErrors)
    }

    // MARK: - Test helpers

    func openURLTestMethod(_ url: URL, completion: ((NSError?) -> Void)?) {
        DispatchQueue.main.async {
            let error = NSError(domain: url.absoluteString, code: 0, userInfo: nil)
            completion?(error);
        }
    }

}
