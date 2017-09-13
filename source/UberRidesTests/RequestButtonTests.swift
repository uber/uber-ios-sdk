//
//  RequestButtonTests.swift
//  UberRidesTests
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
import OHHTTPStubs
import CoreLocation
import WebKit
@testable import UberRides

class RequestButtonTests: XCTestCase {
    var client: RidesClient!
    var button: RideRequestButton!
    weak var expectation: XCTestExpectation?
    weak var errorExpectation: XCTestExpectation?
    var rideButtonError: RidesError!
    let timeout: Double = 5
    
    override func setUp() {
        super.setUp()
        Configuration.bundle = Bundle(for: type(of: self))
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        client = RidesClient()
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        OHHTTPStubs.removeAllStubs();
        super.tearDown()
    }
    
    /**
     Test that title is initialized properly to default value.
     */
    func testInitRequestButtonDefaultText() {
        button = RideRequestButton(client: client)
        XCTAssertEqual(button.uberTitleLabel.text!, "Ride there with Uber")
    }
    
    func testCorrectSource_whenRideRequestViewRequestingBehavior() {
        let testExpectation = expectation(description: "Test RideRequestView source parameter")
        
        let expectationClosure: (URLRequest) -> () = { request in
            testExpectation.fulfill()
            guard let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let items = components.queryItems else {
                XCTAssert(false)
                return
            }
            XCTAssertTrue(items.count > 0)
            var foundUserAgent = false
            for item in items {
                if (item.name == "user-agent") {
                    if let value = item.value {
                        foundUserAgent = true
                        XCTAssertTrue(value.contains(RideRequestButton.sourceString))
                        break
                    }
                }
            }
            XCTAssert(foundUserAgent)
        }
        
        let testIdentifier = "testAccessTokenIdentifier"
        let testToken = AccessToken(JSON: ["access_token" : "testTokenString"])
        _ = TokenManager.save(accessToken: testToken!, tokenIdentifier: testIdentifier)
        defer {
            _ = TokenManager.deleteToken(identifier: testIdentifier)
        }
        let baseViewController = UIViewControllerMock()
        let requestBehavior = RideRequestViewRequestingBehavior(presentingViewController: baseViewController)
        let button = RideRequestButton(rideParameters: RideParameters(), requestingBehavior: requestBehavior)
    
        let loginManger = LoginManager(accessTokenIdentifier: testIdentifier)
        let rideRequestVC = RideRequestViewController(rideParameters: RideParameters(), loginManager: loginManger)
        XCTAssertNotNil(rideRequestVC.view)
        
        let webViewMock = WebViewMock(frame: CGRect.zero, configuration: WKWebViewConfiguration(), testClosure: expectationClosure)
        rideRequestVC.rideRequestView.webView = webViewMock

        requestBehavior.modalRideRequestViewController.rideRequestViewController = rideRequestVC
        
        button.uberButtonTapped(button)
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertTrue(rideRequestVC.loginView.isHidden)
            XCTAssertFalse(rideRequestVC.rideRequestView.isHidden)
        })
    }
    
    func testCorrectSource_whenDeeplinkRequestingBehavior() {
        let testExpectation = expectation(description: "Test Deeplink source parameter")
        
        let expectationClosure: (URL?) -> (Bool) = { url in
            testExpectation.fulfill()
            guard let url = url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let items = components.queryItems else {
                XCTAssert(false)
                return false
            }
            XCTAssertTrue(items.count > 0)
            var foundUserAgent = false
            for item in items {
                if (item.name == "user-agent") {
                    if let value = item.value {
                        foundUserAgent = true
                        XCTAssertTrue(value.contains(RideRequestButton.sourceString))
                        break
                    }
                }
            }
            XCTAssert(foundUserAgent)
            return false
        }
        
        let requestBehavior = DeeplinkRequestingBehaviorMock(testClosure: expectationClosure)
        let button = RideRequestButton(rideParameters: RideParameters(), requestingBehavior: requestBehavior)
    
        button.uberButtonTapped(button)
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    /**
     Test that product ID is set on metadata.
     */
    func testSetProductID() {
        let rideParams = RideParameters()
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.loadRideInformation()
        XCTAssertEqual(button.metadata.productID, productID)
    }
    
    /**
     Test that pickup location lat/long is set on metadata.
     */
    func testSetPickupLocation() {
        let location = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let rideParams = RideParameters(pickupLocation: location, dropoffLocation: nil)
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.loadRideInformation()
        XCTAssertEqual(button.metadata.pickupLatitude, pickupLat)
        XCTAssertEqual(button.metadata.pickupLongitude, pickupLong)
    }
    
    /**
     Test that dropoff location lat/long is set on metadata.
     */
    func testSetDropoffLocation() {
        let location = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: nil, dropoffLocation: location)
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.loadRideInformation()
        XCTAssertEqual(button.metadata.dropoffLatitude, dropoffLat)
        XCTAssertEqual(button.metadata.dropoffLongitude, dropoffLong)
    }
    
    /**
     Test get metadata with productID and pickup location only. Expected only time estimate label.
     */
    func testGetMetadataSimple() {
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getTimeEstimateProduct.json", type(of: self))!, statusCode:200, headers:nil)
        }
        
        expectation = expectation(description: "information loaded")
        
        let location = CLLocation(latitude: dropoffLat, longitude: pickupLong)
        let rideParams = RideParameters(pickupLocation: location, dropoffLocation: nil)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.button.uberTitleLabel.text!, "Get a ride")
            XCTAssertEqual(self.button.uberMetadataLabel.text!, "4 MINS AWAY")
        })
    }
    
    /**
     Test get metadata with productID, pickup, and dropoff locations. Expected time and price estimates on label.
     */
    func testGetMetadataDetailed() {
        stub(condition: isHost("sandbox-api.uber.com")) { urlRequest in
            if isPath("/v1/estimates/price")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getPriceEstimates.json", type(of: self))!, statusCode:200, headers:nil)
            } else if isPath("/v1/estimates/time")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getTimeEstimateProduct.json", type(of: self))!, statusCode:200, headers:nil)
            } else {
                XCTAssert(false)
                return OHHTTPStubsResponse()
            }
        }
        
        expectation = expectation(description: "information loaded")
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.button.uberTitleLabel.text!, "Get a ride")
            XCTAssertEqual(self.button.uberMetadataLabel.text!, "4 MINS AWAY\n$15 for uberX")
        })
    }
    
    func testErrorGettingPriceEstimates() {
        stub(condition: isHost("sandbox-api.uber.com")) { urlRequest in
            if isPath("/v1/estimates/time")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getTimeEstimateProduct.json", type(of: self))!, statusCode:200, headers: [ "Authorization" : "Bearer token" ])
            } else if isPath("/v1/estimates/price")(urlRequest) {
                let obj = ["code":"price_estimate_error"]
                return OHHTTPStubsResponse(jsonObject: obj, statusCode: 404, headers: nil)
            } else {
                XCTAssert(false)
                return OHHTTPStubsResponse()
            }
        }
    
        errorExpectation = expectation(description: "price estimate error")
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.button.uberTitleLabel.text!, "Get a ride")
            XCTAssertEqual(self.button.uberMetadataLabel.text!, "4 MINS AWAY")
            XCTAssertEqual(self.rideButtonError.code, "price_estimate_error")
        })
    }
    
    func testErrorGettingTimeEstimates() {
        stub(condition: isHost("sandbox-api.uber.com")) { urlRequest in
            if isPath("/v1/estimates/price")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getPriceEstimates.json", type(of: self))!, statusCode:200, headers:nil)
            } else if isPath("/v1/estimates/time")(urlRequest) {
                let obj = ["code":"time_estimate_error"]
                return OHHTTPStubsResponse(jsonObject: obj, statusCode: 404, headers: nil)
            } else {
                XCTAssert(false)
                return OHHTTPStubsResponse()
            }
        }
        
        errorExpectation = expectation(description: "time estimate error")
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()
        
        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.button.uberTitleLabel.text!, "Get a ride")
            XCTAssertEqual(self.button.uberMetadataLabel.text!, "$15 for uberX")
            XCTAssertEqual(self.rideButtonError.code, "time_estimate_error")
        })
    }

    func testEmptyTimeEstimatesCallsDelegateValidPriceEstimates() {
        stub(condition: isHost("sandbox-api.uber.com")) { urlRequest in

            if isPath("/v1/estimates/price")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getPriceEstimates.json", type(of: self))!, statusCode:200, headers:nil)
            } else if isPath("/v1/estimates/time")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getTimeEstimatesEmpty.json", type(of: self))!, statusCode:200, headers:nil)
            } else {
                XCTAssert(false)
                return OHHTTPStubsResponse()
            }
        }

        expectation = expectation(description: "information loaded")

        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()

        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.button.uberTitleLabel.text!, "Get a ride")
            XCTAssertEqual(self.button.uberMetadataLabel.text!, "$15 for uberX")
        })
    }

    func testEmptyPriceEstimatesValidTimeEstimates() {
        stub(condition: isHost("sandbox-api.uber.com")) { urlRequest in
            if isPath("/v1/estimates/price")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getPriceEstimatesEmpty.json", type(of: self))!, statusCode:200, headers:nil)
            } else if isPath("/v1/estimates/time")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getTimeEstimateProduct.json", type(of: self))!, statusCode:200, headers:nil)
            } else {
                XCTAssert(false)
                return OHHTTPStubsResponse()
            }
        }

        expectation = expectation(description: "information loaded")
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()

        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.button.uberTitleLabel.text!, "Get a ride")
            XCTAssertEqual(self.button.uberMetadataLabel.text!, "4 MINS AWAY")
        })
    }

    func testEmptyPriceEstimatesEmptyTimeEstimates() {
        stub(condition: isHost("sandbox-api.uber.com")) { urlRequest in
            if isPath("/v1/estimates/price")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getPriceEstimatesEmpty.json", type(of: self))!, statusCode:200, headers:nil)
            } else if isPath("/v1/estimates/time")(urlRequest) {
                return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getTimeEstimatesEmpty.json", type(of: self))!, statusCode:200, headers:nil)
            } else {
                XCTAssert(false)
                return OHHTTPStubsResponse()
            }
        }

        expectation = expectation(description: "information loaded")
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()

        waitForExpectations(timeout: timeout, handler: { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.button.uberTitleLabel.text!, "Ride there with Uber")
            XCTAssertNil(self.button.uberMetadataLabel.text)
        })
    }

    func testMissingClientTriggersErrorDelegate() {
        errorExpectation = expectation(description: "Expected to receive 422 error")
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.client = nil
        button.loadRideInformation()

        waitForExpectations(timeout: timeout, handler: { error in
            guard let ridesError = self.rideButtonError else {
                XCTFail("Expected to receive 422 error")
                return
            }
            XCTAssertEqual(ridesError.status, 422)
            XCTAssertEqual(ridesError.code, "validation_failed")
            XCTAssertEqual(ridesError.title, "Invalid Request")
        })
    }

    func testMissingPickupTriggersErrorDelegate() {
        errorExpectation = expectation(description: "Expected to receive 422 error")
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: nil, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()

        waitForExpectations(timeout: timeout, handler: { error in
            guard let ridesError = self.rideButtonError else {
                XCTFail("Expected to receive 422 error")
                return
            }
            XCTAssertEqual(ridesError.status, 422)
            XCTAssertEqual(ridesError.code, "validation_failed")
            XCTAssertEqual(ridesError.title, "Invalid Request")
        })
    }

    func testUseCurrentLocationTriggersErrorDelegate() {
        errorExpectation = expectation(description: "Expected to receive 422 error")
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: nil, dropoffLocation: dropoffLocation)
        rideParams.productID = productID
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.delegate = self
        button.loadRideInformation()

        waitForExpectations(timeout: timeout, handler: { error in
            guard let ridesError = self.rideButtonError else {
                XCTFail("Expected to receive 422 error")
                return
            }
            XCTAssertEqual(ridesError.status, 422)
            XCTAssertEqual(ridesError.code, "validation_failed")
            XCTAssertEqual(ridesError.title, "Invalid Request")
        })
    }

    /**
     Test that button defaults to "Get a Ride" when no productID is set.
     */
    func testMetadataSimpleWithNoProductID() {
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParams = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        button = RideRequestButton(client: client, rideParameters:rideParams, requestingBehavior: DeeplinkRequestingBehavior())
        button.loadRideInformation()
        
        XCTAssertEqual(self.button.uberTitleLabel.text!, "Ride there with Uber")
    }
}

private class UIViewControllerMock : UIViewController {
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        viewControllerToPresent.viewWillAppear(flag)
        viewControllerToPresent.viewDidAppear(flag)
        
        if let modal = viewControllerToPresent as? ModalRideRequestViewController {
            modal.rideRequestViewController.viewWillAppear(flag)
            modal.rideRequestViewController.viewDidAppear(flag)
        }
        
        return
    }
}

// MARK: RequestButtonDelegate

extension RequestButtonTests: RideRequestButtonDelegate {
    func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton) {
        expectation?.fulfill()
    }
    
    func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError) {
        self.rideButtonError = error
        errorExpectation?.fulfill()
    }
}
