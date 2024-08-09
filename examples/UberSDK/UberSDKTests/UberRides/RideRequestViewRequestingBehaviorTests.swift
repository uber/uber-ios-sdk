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
@testable import UberAuth
@testable import UberCore
@testable import UberRides

class RideRequestViewRequestingBehaviorTests : XCTestCase {

    func testRideParametersUpdated() {
        class UIViewControllerMock : UIViewController {
            override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                return
            }
        }
        
        let baseVC = UIViewControllerMock()
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: baseVC)
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
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: baseVC)
        behavior.requestRide(parameters: RideParametersBuilder().build())
        waitForExpectations(timeout: 2.0) {error in
            XCTAssertNil(error)
        }
    }
}
