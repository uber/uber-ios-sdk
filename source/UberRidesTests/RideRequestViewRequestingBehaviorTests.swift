//
//  RideRequestViewRequestingBehaviorTests.swift
//  UberRides
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
import CoreLocation
import UberCore
@testable import UberRides

class RideRequestViewRequestingBehaviorTests : XCTestCase {

    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
    }
    
    override func tearDown() {
        super.tearDown()
        Configuration.restoreDefaults()
    }
    
    func testUpdateLoginManager() {
        let baseVC = UIViewController()
        let initialLoginManger = LoginManager(loginType: .native)
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: baseVC, loginManager: initialLoginManger)
        XCTAssertNotNil(behavior.loginManager)
        XCTAssertEqual(behavior.modalRideRequestViewController.rideRequestViewController.loginManager, initialLoginManger)
        
        let newLoginManager = LoginManager(accessTokenIdentifier: "testToken")
        behavior.loginManager = newLoginManager
        XCTAssertNotNil(behavior.loginManager)
        XCTAssertEqual(behavior.modalRideRequestViewController.rideRequestViewController.loginManager, newLoginManager)
    }
    
    func testRideParametersUpdated() {
        class UIViewControllerMock : UIViewController {
            override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                return
            }
        }
        
        let baseVC = UIViewControllerMock()
        let initialLoginManger = LoginManager(loginType: .native)
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: baseVC, loginManager: initialLoginManger)
        XCTAssertNotNil(behavior.modalRideRequestViewController)
        XCTAssertNotNil(behavior.modalRideRequestViewController.rideRequestViewController)
        let pickupLocation = CLLocation(latitude: -32.0, longitude: 42.2)
        let rideParametersBuilder = RideParametersBuilder()
        rideParametersBuilder.pickupLocation = pickupLocation
        let newRideParams = rideParametersBuilder.build()
        behavior.requestRide(parameters: newRideParams)
        XCTAssertTrue(behavior.modalRideRequestViewController.rideRequestViewController.rideRequestView.rideParameters === newRideParams)
    }
    
    func testPresentModal() {
        class UIViewControllerMock : UIViewController {
            let testClosure: (UIViewController) -> ()
            fileprivate init(testClosure: @escaping (UIViewController) -> ()) {
                self.testClosure = testClosure
                super.init(nibName: nil, bundle: nil)
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                self.testClosure(viewControllerToPresent)
                return
            }
        }
        
        let expectation = self.expectation(description: "ModalRideViewController is presented")
        let expectationClosure: (UIViewController) -> () = { viewController in
            XCTAssertTrue(viewController is ModalRideRequestViewController)
            expectation.fulfill()
        }
        
        let baseVC = UIViewControllerMock(testClosure: expectationClosure)
        let initialLoginManger = LoginManager(loginType: .native)
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: baseVC, loginManager: initialLoginManger)
        behavior.requestRide(parameters: RideParametersBuilder().build())
        waitForExpectations(timeout: 2.0) {error in
            XCTAssertNil(error)
        }
    }
}
