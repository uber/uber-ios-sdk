//
//  ObjectMappingTests.swift
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
import ObjectMapper
@testable import UberRides

class ObjectMappingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.setSandboxEnabled(true)
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }

    /**
     Tests mapping result of GET /v1/product/{product_id} endpoint.
     */
    func testGetProduct() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getProductID", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                let product = ModelMapper<UberProduct>().mapFromJSON(JSONString)
                XCTAssertNotNil(product)
                XCTAssertEqual(product!.productID, "d4abaae7-f4d6-4152-91cc-77523e8165a4")
                XCTAssertEqual(product!.name, "UberBLACK")
                XCTAssertEqual(product!.details, "The original Uber")
                XCTAssertEqual(product!.capacity, 4)
                XCTAssertEqual(product!.imagePath, "http://d1a3f4spazzrp4.cloudfront.net/car.jpg")
                
                let priceDetails = product!.priceDetails
                XCTAssertNotNil(priceDetails)
                XCTAssertEqual(priceDetails!.distanceUnit, "mile")
                XCTAssertEqual(priceDetails!.costPerMinute, 0.65)
                XCTAssertEqual(priceDetails!.minimumFee, 15.0)
                XCTAssertEqual(priceDetails!.costPerDistance, 3.75)
                XCTAssertEqual(priceDetails!.baseFee, 8.0)
                XCTAssertEqual(priceDetails!.cancellationFee, 10.0)
                XCTAssertEqual(priceDetails!.currencyCode, "USD")
                
                let serviceFees = priceDetails!.serviceFees
                XCTAssertNotNil(serviceFees)
                XCTAssertEqual(serviceFees!.count, 1)
                XCTAssertEqual(serviceFees!.first!.name, "Safe Rides Fee")
                XCTAssertEqual(serviceFees!.first!.fee, 1.0)
            }
        }
    }
    
    /**
     Tests mapping of malformed result of GET /v1/products endpoint.
     */
    func testGetProductBadJSON() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getProductID", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                var JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                
                // Represent some bad JSON
                JSONString = JSONString.stringByReplacingOccurrencesOfString("[", withString: "")
                
                let product = ModelMapper<UberProducts>().mapFromJSON(JSONString)
                XCTAssertNil(product)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1/products/{product_id} endpoint.
     */
    func testGetAllProducts() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getProducts", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                let products = ModelMapper<UberProducts>().mapFromJSON(JSONString)
                XCTAssertNotNil(products)
                XCTAssertNotNil(products!.list)
                XCTAssertEqual(products!.list!.count, 5)
                XCTAssertEqual(products!.list![0].name, "uberX")
                XCTAssertEqual(products!.list![1].name, "uberXL")
                XCTAssertEqual(products!.list![2].name, "UberBLACK")
                XCTAssertEqual(products!.list![3].name, "UberSUV")
                XCTAssertEqual(products!.list![4].name, "uberTAXI")
            }
        }
    }
    
    /**
     Tests mapping of malformed result of GET /v1/products endpoint.
     */
    func testGetAllProductsBadJSON() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getProducts", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                var JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                
                // Represent some bad JSON
                JSONString = JSONString.stringByReplacingOccurrencesOfString("[", withString: "")
                
                let products = ModelMapper<UberProducts>().mapFromJSON(JSONString)
                XCTAssertNil(products)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1/estimates/time
     */
    func testGetTimeEstimates() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getTimeEstimates", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                let timeEstimates = ModelMapper<TimeEstimates>().mapFromJSON(JSONString)
                XCTAssertNotNil(timeEstimates)
                XCTAssertNotNil(timeEstimates!.list)
                
                let list = timeEstimates!.list!
                XCTAssertEqual(timeEstimates!.list!.count, 4)
                XCTAssertEqual(list[0].productID, "5f41547d-805d-4207-a297-51c571cf2a8c")
                XCTAssertEqual(list[0].estimate, 410)
                XCTAssertEqual(list[0].name, "UberBLACK")
                XCTAssertEqual(list[1].name, "UberSUV")
                XCTAssertEqual(list[2].name, "uberTAXI")
                XCTAssertEqual(list[3].name, "uberX")
            }
        }
    }
    
    /**
     Tests mapping of malformed result of GET /v1/estimates/time
     */
    func testGetTimeEstimatesBadJSON() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getTimeEstimates", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                var JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                
                // Represent some bad JSON
                JSONString = JSONString.stringByReplacingOccurrencesOfString("[", withString: "")
                
                let timeEstimates = ModelMapper<TimeEstimates>().mapFromJSON(JSONString)
                XCTAssertNil(timeEstimates)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1/estimates/price endpoint.
     */
    func testGetPriceEstimates() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getPriceEstimates", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                let priceEstimates = ModelMapper<PriceEstimates>().mapFromJSON(JSONString)
                XCTAssertNotNil(priceEstimates)
                XCTAssertNotNil(priceEstimates!.list)
                
                let list = priceEstimates!.list!
                XCTAssertEqual(list.count, 4)
                XCTAssertEqual(list[0].productID, "08f17084-23fd-4103-aa3e-9b660223934b")
                XCTAssertEqual(list[0].currencyCode, "USD")
                XCTAssertEqual(list[0].name, "UberBLACK")
                XCTAssertEqual(list[0].estimate, "$23-29")
                XCTAssertEqual(list[0].lowEstimate, 23)
                XCTAssertEqual(list[0].highEstimate, 29)
                XCTAssertEqual(list[0].surgeMultiplier, 1)
                XCTAssertEqual(list[0].duration, 640)
                XCTAssertEqual(list[0].distance, 5.34)
            }
        }
    }

    /**
     Tests mapping of malformed result of GET /v1/estimates/price endpoint.
     */
    func testGetPriceEstimatesBadJSON() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getPriceEstimates", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                var JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                
                // Represent some bad JSON
                JSONString = JSONString.stringByReplacingOccurrencesOfString("[", withString: "")
                
                let priceEstimates = ModelMapper<PriceEstimates>().mapFromJSON(JSONString)
                XCTAssertNil(priceEstimates)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1.2/history
     */
    func testGetTripHistory() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getHistory", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                let userActivity = ModelMapper<TripHistory>().mapFromJSON(JSONString)
                XCTAssertNotNil(userActivity)
                XCTAssertNotNil(userActivity!.history)
                XCTAssertEqual(userActivity!.count, 1)
                XCTAssertEqual(userActivity!.limit, 5)
                XCTAssertEqual(userActivity!.offset, 0)
                
                let history = userActivity!.history!
                XCTAssertEqual(history.count, 1)
                XCTAssertEqual(history[0].status, RideStatus.Completed)
                XCTAssertEqual(history[0].distance, 1.64691465)
                XCTAssertEqual(history[0].requestTime, NSDate(timeIntervalSince1970: 1428876188))
                XCTAssertEqual(history[0].startTime, NSDate(timeIntervalSince1970: 1428876374))
                XCTAssertEqual(history[0].endTime, NSDate(timeIntervalSince1970: 1428876927))
                XCTAssertEqual(history[0].requestID, "37d57a99-2647-4114-9dd2-c43bccf4c30b")
                XCTAssertEqual(history[0].productID, "a1111c8c-c720-46c3-8534-2fcdd730040d")
                
                XCTAssertNotNil(history[0].startCity)
                
                let city = history[0].startCity!
                XCTAssertEqual(city.name, "San Francisco")
                XCTAssertEqual(city.latitude, 37.7749295)
                XCTAssertEqual(city.longitude, -122.4194155)
            }
        }
    }
    
    /**
     Tests mapping of malformed result of GET /v1.2/history endpoint.
     */
    func testGetHistoryBadJSON() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getHistory", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                var JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                
                // Represent some bad JSON
                JSONString = JSONString.stringByReplacingOccurrencesOfString("[", withString: "")
                
                let userActivity = ModelMapper<TripHistory>().mapFromJSON(JSONString)
                XCTAssertNil(userActivity)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1/me endpoint.
     */
    func testGetUserProfile() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getMe", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                let userProfile = ModelMapper<UserProfile>().mapFromJSON(JSONString)
                XCTAssertNotNil(userProfile)
                XCTAssertEqual(userProfile!.firstName, "Uber")
                XCTAssertEqual(userProfile!.lastName, "Developer")
                XCTAssertEqual(userProfile!.email, "developer@uber.com")
                XCTAssertEqual(userProfile!.picturePath, "https://profile-picture.jpg")
                XCTAssertEqual(userProfile!.promoCode, "teypo")
                XCTAssertEqual(userProfile!.UUID, "91d81273-45c2-4b57-8124-d0165f8240c0")
            }
        }
    }
    
     /**
     Tests mapping of malformed result of GET /v1/me endpoint.
     */
    func testGetUserProfileBadJSON() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getMe", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                var JSONString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
                JSONString = JSONString.stringByReplacingOccurrencesOfString("{", withString: "")
                
                let userProfile = ModelMapper<UserProfile>().mapFromJSON(JSONString)
                XCTAssertNil(userProfile)
            }
        }
    }
    
    /**
     Tests mapping result of POST /v1/requests
     */
    func testPostRequest() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("postRequests", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                guard let trip = ModelMapper<Ride>().mapFromJSON(JSONString) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertNotNil(trip)
                XCTAssertEqual(trip.requestID, "852b8fdd-4369-4659-9628-e122662ad257")
                XCTAssertEqual(trip.status, RideStatus.Processing)
                XCTAssertEqual(trip.eta, 5)
                XCTAssertNil(trip.vehicle)
                XCTAssertNil(trip.driver)
                XCTAssertNil(trip.driverLocation)
                XCTAssertEqual(trip.surgeMultiplier, 1.0)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1/requests/current or /v1/requests/{request_id}
     */
    func testGetRequest() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getRequest", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                guard let trip = ModelMapper<Ride>().mapFromJSON(JSONString) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(trip.requestID, "17cb78a7-b672-4d34-a288-a6c6e44d5315")
                XCTAssertEqual(trip.status, RideStatus.Accepted)
                XCTAssertEqual(trip.eta, 5)
                XCTAssertEqual(trip.surgeMultiplier, 1.0)
                
                XCTAssertNotNil(trip.driverLocation)
                XCTAssertEqual(trip.driverLocation!.latitude, 37.7886532015)
                XCTAssertEqual(trip.driverLocation!.longitude, -122.3961987534)
                XCTAssertEqual(trip.driverLocation!.bearing, 135)
                
                XCTAssertNotNil(trip.vehicle)
                XCTAssertEqual(trip.vehicle!.make, "Bugatti")
                XCTAssertEqual(trip.vehicle!.model, "Veyron")
                XCTAssertEqual(trip.vehicle!.licensePlate, "I<3Uber")
                XCTAssertEqual(trip.vehicle!.pictureURL, "https://d1w2poirtb3as9.cloudfront.net/car.jpeg")
                
                XCTAssertNotNil(trip.driver)
                XCTAssertEqual(trip.driver!.name, "Bob")
                XCTAssertEqual(trip.driver!.pictureURL, "https://d1w2poirtb3as9.cloudfront.net/img.jpeg")
                XCTAssertEqual(trip.driver!.phoneNumber, "(555)555-5555")
                XCTAssertEqual(trip.driver!.rating, 5)
                
                XCTAssertNotNil(trip.pickup)
                XCTAssertEqual(trip.pickup!.latitude, 37.7872486012)
                XCTAssertEqual(trip.pickup!.longitude, -122.4026315287)
                XCTAssertEqual(trip.pickup!.eta, 5)
                
                XCTAssertNotNil(trip.destination)
                XCTAssertEqual(trip.destination!.latitude, 37.7766874)
                XCTAssertEqual(trip.destination!.longitude, -122.394857)
                XCTAssertEqual(trip.destination!.eta, 19)
            }
        }
    }
    
    /**
     Tests mapping of POST /v1/requests/estimate endpoint.
     */
    func testGetRequestEstimate() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("requestEstimate", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                let estimate = ModelMapper<RideEstimate>().mapFromJSON(JSONString)
                XCTAssertNotNil(estimate)
                XCTAssertEqual(estimate!.pickupEstimate, 2)
                
                XCTAssertNotNil(estimate!.priceEstimate)
                XCTAssertEqual(estimate!.priceEstimate!.surgeConfirmationURL, "https://api.uber.com/v1/surge-confirmations/7d604f5e")
                XCTAssertEqual(estimate!.priceEstimate!.surgeConfirmationID, "7d604f5e")
                
                XCTAssertNotNil(estimate!.distanceEstimate)
                XCTAssertEqual(estimate!.distanceEstimate!.distance, 2.1)
                XCTAssertEqual(estimate!.distanceEstimate!.duration, 540)
                XCTAssertEqual(estimate!.distanceEstimate!.distanceUnit, "mile")
            }
        }
    }
    
    func testGetRequestEstimateNoCars() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("requestEstimateNoCars", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                let estimate = ModelMapper<RideEstimate>().mapFromJSON(JSONString)
                XCTAssertNotNil(estimate)
                XCTAssertEqual(estimate!.pickupEstimate, -1)
                
                XCTAssertNotNil(estimate!.priceEstimate)
                XCTAssertEqual(estimate!.priceEstimate!.surgeConfirmationURL, "https://api.uber.com/v1/surge-confirmations/7d604f5e")
                XCTAssertEqual(estimate!.priceEstimate!.surgeConfirmationID, "7d604f5e")
                
                XCTAssertNotNil(estimate!.distanceEstimate)
                XCTAssertEqual(estimate!.distanceEstimate!.distance, 2.1)
                XCTAssertEqual(estimate!.distanceEstimate!.duration, 540)
                XCTAssertEqual(estimate!.distanceEstimate!.distanceUnit, "mile")
            }
        }
    }
    
    /**
     Tests mapping of GET v1/places/{place_id} endpoint
     */
    func testGetPlace() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("place", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                guard let place = ModelMapper<Place>().mapFromJSON(JSONString) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(place.address, "685 Market St, San Francisco, CA 94103, USA")
                return
            }
        }
        
        XCTAssert(false)
    }
    
    /**
     Tests mapping of GET /v1/payment-methods endpoint.
     */
    func testGetPaymentMethods() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("getPaymentMethods", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                guard let paymentMethods = ModelMapper<PaymentMethods>().mapFromJSON(JSONString) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(paymentMethods.lastUsed, "f53847de-8113-4587-c307-51c2d13a823c")
                
                guard let payments = paymentMethods.list else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(payments.count, 4)
                XCTAssertEqual(payments[0].methodID, "5f384f7d-8323-4207-a297-51c571234a8c")
                XCTAssertEqual(payments[1].methodID, "f33847de-8113-4587-c307-51c2d13a823c")
                XCTAssertEqual(payments[2].methodID, "f43847de-8113-4587-c307-51c2d13a823c")
                XCTAssertEqual(payments[3].methodID, "f53847de-8113-4587-c307-51c2d13a823c")
                
                XCTAssertEqual(payments[0].type, "baidu_wallet")
                XCTAssertEqual(payments[1].type, "alipay")
                XCTAssertEqual(payments[2].type, "visa")
                XCTAssertEqual(payments[3].type, "business_account")
                
                XCTAssertEqual(payments[0].paymentDescription, "***53")
                XCTAssertEqual(payments[1].paymentDescription, "ga***@uber.com")
                XCTAssertEqual(payments[2].paymentDescription, "***23")
                XCTAssertEqual(payments[3].paymentDescription, "Late Night Ride")
                
                return
            }
        }
        
        XCTAssert(false)
    }
    
    /**
     Tests mapping of GET /v1/requests/{request_id}/receipt endpoint.
     */
    func testGetRideReceipt() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("rideReceipt", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                guard let receipt = ModelMapper<RideReceipt>().mapFromJSON(JSONString) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(receipt.requestID, "b5512127-a134-4bf4-b1ba-fe9f48f56d9d")
                
                guard let charges = receipt.charges else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(charges.count, 3)
                XCTAssertEqual(charges[0].name, "Base Fare")
                XCTAssertEqual(charges[0].amount, 2.20)
                XCTAssertEqual(charges[0].type, "base_fare")
                XCTAssertEqual(charges[1].name, "Distance")
                XCTAssertEqual(charges[1].amount, 2.75)
                XCTAssertEqual(charges[1].type, "distance")
                XCTAssertEqual(charges[2].name, "Time")
                XCTAssertEqual(charges[2].amount, 3.57)
                XCTAssertEqual(charges[2].type, "time")
                
                guard let surgeCharge = receipt.surgeCharge else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(surgeCharge.name, "Surge x1.5")
                XCTAssertEqual(surgeCharge.amount, 4.26)
                XCTAssertEqual(surgeCharge.type, "surge")
                
                guard let chargeAdjustments = receipt.chargeAdjustments else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(chargeAdjustments.count, 3)
                XCTAssertEqual(chargeAdjustments[0].name, "Promotion")
                XCTAssertEqual(chargeAdjustments[0].amount, -2.43)
                XCTAssertEqual(chargeAdjustments[0].type, "promotion")
                XCTAssertEqual(chargeAdjustments[1].name, "Booking Fee")
                XCTAssertEqual(chargeAdjustments[1].amount, 1.00)
                XCTAssertEqual(chargeAdjustments[1].type, "booking_fee")
                XCTAssertEqual(chargeAdjustments[2].name, "Rounding Down")
                XCTAssertEqual(chargeAdjustments[2].amount, 0.78)
                XCTAssertEqual(chargeAdjustments[2].type, "rounding_down")
                
                XCTAssertEqual(receipt.normalFare, "$8.52")
                XCTAssertEqual(receipt.subtotal, "$12.78")
                XCTAssertEqual(receipt.totalCharged, "$5.92")
                XCTAssertEqual(receipt.totalOwed, 0.0)
                XCTAssertEqual(receipt.currencyCode, "USD")
                XCTAssertEqual(receipt.duration, "00:11:35")
                XCTAssertEqual(receipt.distance, "1.49")
                XCTAssertEqual(receipt.distanceLabel, "miles")
                
                return
            }
        }
        
        XCTAssert(false)
    }
    
    func testGetRideReceipt_withNullSurge_withTotalOwed() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("rideReceiptNullSurgeTotalOwed", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                guard let receipt = ModelMapper<RideReceipt>().mapFromJSON(JSONString) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(receipt.requestID, "b5512127-a134-4bf4-b1ba-fe9f48f56d9d")
                
                guard let charges = receipt.charges else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(charges.count, 3)
                XCTAssertEqual(charges[0].name, "Base Fare")
                XCTAssertEqual(charges[0].amount, 2.20)
                XCTAssertEqual(charges[0].type, "base_fare")
                XCTAssertEqual(charges[1].name, "Distance")
                XCTAssertEqual(charges[1].amount, 2.75)
                XCTAssertEqual(charges[1].type, "distance")
                XCTAssertEqual(charges[2].name, "Time")
                XCTAssertEqual(charges[2].amount, 3.57)
                XCTAssertEqual(charges[2].type, "time")
                
                XCTAssertNil(receipt.surgeCharge)
                
                guard let chargeAdjustments = receipt.chargeAdjustments else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(chargeAdjustments.count, 3)
                XCTAssertEqual(chargeAdjustments[0].name, "Promotion")
                XCTAssertEqual(chargeAdjustments[0].amount, -2.43)
                XCTAssertEqual(chargeAdjustments[0].type, "promotion")
                XCTAssertEqual(chargeAdjustments[1].name, "Booking Fee")
                XCTAssertEqual(chargeAdjustments[1].amount, 1.00)
                XCTAssertEqual(chargeAdjustments[1].type, "booking_fee")
                XCTAssertEqual(chargeAdjustments[2].name, "Rounding Down")
                XCTAssertEqual(chargeAdjustments[2].amount, 0.78)
                XCTAssertEqual(chargeAdjustments[2].type, "rounding_down")
                
                XCTAssertEqual(receipt.normalFare, "$8.52")
                XCTAssertEqual(receipt.subtotal, "$12.78")
                XCTAssertEqual(receipt.totalCharged, "$5.92")
                XCTAssertEqual(receipt.totalOwed, 0.50)
                XCTAssertEqual(receipt.currencyCode, "USD")
                XCTAssertEqual(receipt.duration, "00:11:35")
                XCTAssertEqual(receipt.distance, "1.49")
                XCTAssertEqual(receipt.distanceLabel, "miles")
                
                return
            }
        }
        
        XCTAssert(false)
    }
    
    /**
     Test bad JSON for GET /v1/reqeuests/{request_id}/receipt
     */
    func testGetRideReceiptBadJSON() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("rideReceipt", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                var JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                JSONString = JSONString.stringByReplacingOccurrencesOfString("[", withString: "")
                let receipt = ModelMapper<RideReceipt>().mapFromJSON(JSONString)
                XCTAssertNil(receipt)
                return
            }
        }
        
        XCTAssert(false)
    }
    
    /**
     Tests mapping of GET /v1/requests/{request_id}/map endpoint.
     */
    func testGetRideMap() {
        let bundle = NSBundle(forClass: ObjectMappingTests.self)
        if let path = bundle.pathForResource("rideMap", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let JSONString = NSString(data: jsonData, encoding:  NSUTF8StringEncoding)!
                guard let map = ModelMapper<RideMap>().mapFromJSON(JSONString) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(map.path, "https://trip.uber.com/abc123")
                XCTAssertEqual(map.requestID, "b5512127-a134-4bf4-b1ba-fe9f48f56d9d")
                
                return
            }
        }
        
        XCTAssert(false)
    }
}
