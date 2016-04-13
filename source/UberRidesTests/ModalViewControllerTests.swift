//
//  ModalViewControllerTests.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
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
@testable import UberRides

class ModalViewControllerTests: XCTestCase {
    
    private let timeout = 2.0
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setSandboxEnabled(true)
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testDelegate_willDismiss() {
        @objc class ModalViewControllerDelegateMock : NSObject, ModalViewControllerDelegate {
            var testClosure: () -> ()
            init(testClosure: () -> ()) {
                self.testClosure = testClosure
            }
            @objc func modalViewControllerWillDismiss(modalViewController: ModalViewController) {
                testClosure()
            }
            @objc func modalViewControllerDidDismiss(modalViewController: ModalViewController) {
                //intentionally left blank
            }
        }
        
        let expectation = expectationWithDescription("Test willDismiss() is called")
        
        let testVC = UIViewController()
        let ridesModal = ModalViewController(childViewController: testVC)
        let testClosure = {
            expectation.fulfill()
        }
        let modalDelegateMock = ModalViewControllerDelegateMock(testClosure: testClosure)
        ridesModal.delegate = modalDelegateMock
        
        ridesModal.dismiss()
        
        waitForExpectationsWithTimeout(timeout) { (error) -> Void in
            XCTAssertNil(error)
        }
    }
    
    func testDelegate_didDismiss() {
        @objc class ModalViewControllerDelegateMock : NSObject, ModalViewControllerDelegate {
            var testClosure: () -> ()
            init(testClosure: () -> ()) {
                self.testClosure = testClosure
            }
            @objc func modalViewControllerWillDismiss(modalViewController: ModalViewController) {
                //intentionally left blank
            }
            @objc func modalViewControllerDidDismiss(modalViewController: ModalViewController) {
                testClosure()
            }
        }
        
        let expectation = expectationWithDescription("Test willDismiss() is called")
        
        let testVC = UIViewController()
        let ridesModal = ModalViewController(childViewController: testVC)
        let testClosure = {
            expectation.fulfill()
        }
        let modalDelegateMock = ModalViewControllerDelegateMock(testClosure: testClosure)
        ridesModal.delegate = modalDelegateMock
        
        ridesModal.viewDidDisappear(false)
        
        waitForExpectationsWithTimeout(timeout) { (error) -> Void in
            XCTAssertNil(error)
        }
    }
}
