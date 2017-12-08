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
import UberCore
@testable import UberRides

class ObjectMappingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }

    /**
     Tests mapping result of GET /v1/product/{product_id} endpoint.
     */
    func testGetProduct() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getProductID", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let product = try? JSONDecoder.uberDecoder.decode(Product.self, from: jsonData)
                XCTAssertNotNil(product)
                XCTAssertEqual(product!.productID, "a1111c8c-c720-46c3-8534-2fcdd730040d")
                XCTAssertEqual(product!.name, "uberX")
                XCTAssertEqual(product!.productDescription, "THE LOW-COST UBER")
                XCTAssertEqual(product!.capacity, 4)
                XCTAssertEqual(product!.imageURL, URL(string: "http://d1a3f4spazzrp4.cloudfront.net/car-types/mono/mono-uberx.png")!)
                
                let priceDetails = product!.priceDetails
                XCTAssertNotNil(priceDetails)
                XCTAssertEqual(priceDetails!.distanceUnit, "mile")
                XCTAssertEqual(priceDetails!.costPerMinute, 0.22)
                XCTAssertEqual(priceDetails!.minimumFee, 7.0)
                XCTAssertEqual(priceDetails!.costPerDistance, 1.15)
                XCTAssertEqual(priceDetails!.baseFee, 2.0)
                XCTAssertEqual(priceDetails!.cancellationFee, 5.0)
                XCTAssertEqual(priceDetails!.currencyCode, "USD")
                
                let serviceFees = priceDetails!.serviceFees
                XCTAssertNotNil(serviceFees)
                XCTAssertEqual(serviceFees?.count, 1)
                XCTAssertEqual(serviceFees?.first?.name, "Booking fee")
                XCTAssertEqual(serviceFees?.first?.fee, 2.0)
            }
        }
    }
    
    /**
     Tests mapping of malformed result of GET /v1/products endpoint.
     */
    func testGetProductBadJSON() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getProductID", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let JSONString = String(data: jsonData, encoding: String.Encoding.utf8)!
                
                // Represent some bad JSON
                let jsonData = JSONString.replacingOccurrences(of: "[", with: "").data(using: .utf8)!

                let product = try? JSONDecoder.uberDecoder.decode(UberProducts.self, from: jsonData)
                XCTAssertNil(product)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1/products/{product_id} endpoint.
     */
    func testGetAllProducts() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getProducts", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let products = try? JSONDecoder.uberDecoder.decode(UberProducts.self, from: jsonData)
                XCTAssertNotNil(products)
                XCTAssertNotNil(products!.list)
                XCTAssertEqual(products!.list!.count, 9)
                XCTAssertEqual(products!.list![0].name, "SELECT")
                XCTAssertEqual(products!.list![1].name, "uberXL")
                XCTAssertEqual(products!.list![2].name, "BLACK")
                XCTAssertEqual(products!.list![3].name, "SUV")
                XCTAssertEqual(products!.list![4].name, "ASSIST")
                XCTAssertEqual(products!.list![5].name, "WAV")
                XCTAssertEqual(products!.list![6].name, "POOL")
                XCTAssertEqual(products!.list![7].name, "uberX")
                XCTAssertEqual(products!.list![8].name, "TAXI")

                /// Assert upfront fare product, POOL
                let uberPool = products?.list?[6]
                XCTAssertEqual(uberPool?.upfrontFareEnabled, true)
                XCTAssertEqual(uberPool?.capacity, 2)
                XCTAssertEqual(uberPool?.productID, "26546650-e557-4a7b-86e7-6a3942445247")
                XCTAssertNil(uberPool?.priceDetails)
                XCTAssertEqual(uberPool?.imageURL, URL(string: "http://d1a3f4spazzrp4.cloudfront.net/car-types/mono/mono-uberx.png")!)
                XCTAssertEqual(uberPool?.cashEnabled, false)
                XCTAssertEqual(uberPool?.isShared, true)
                XCTAssertEqual(uberPool?.name, "POOL")
                XCTAssertEqual(uberPool?.productGroup, ProductGroup.rideshare)
                XCTAssertEqual(uberPool?.productDescription, "Share the ride, split the cost.")

                /// Assert time+distance product, uberX (pulled from Sydney)
                let uberX = products?.list?[7]
                XCTAssertEqual(uberX?.upfrontFareEnabled, false)
                XCTAssertEqual(uberX?.capacity, 4)
                XCTAssertEqual(uberX?.productID, "2d1d002b-d4d0-4411-98e1-673b244878b2")
                XCTAssertEqual(uberX?.imageURL, URL(string: "http://d1a3f4spazzrp4.cloudfront.net/car-types/mono/mono-uberx.png")!)
                XCTAssertEqual(uberX?.cashEnabled, false)
                XCTAssertEqual(uberX?.isShared, false)
                XCTAssertEqual(uberX?.name, "uberX")
                XCTAssertEqual(uberX?.productGroup, ProductGroup.uberX)
                XCTAssertEqual(uberX?.productDescription, "Everyday rides that are always smarter than a taxi")

                XCTAssertEqual(uberX?.priceDetails?.serviceFees?.first?.fee, 0.55)
                XCTAssertEqual(uberX?.priceDetails?.serviceFees?.first?.name, "Booking fee")
                XCTAssertEqual(uberX?.priceDetails?.costPerMinute, 0.4)
                XCTAssertEqual(uberX?.priceDetails?.distanceUnit, "km")
                XCTAssertEqual(uberX?.priceDetails?.minimumFee, 9)
                XCTAssertEqual(uberX?.priceDetails?.costPerDistance, 1.45)
                XCTAssertEqual(uberX?.priceDetails?.baseFee, 2.5)
                XCTAssertEqual(uberX?.priceDetails?.cancellationFee, 10)
                XCTAssertEqual(uberX?.priceDetails?.currencyCode, "AUD")

                /// Assert hail product, TAXI
                let taxi = products?.list?[8]
                XCTAssertEqual(taxi?.upfrontFareEnabled, false)
                XCTAssertEqual(taxi?.capacity, 4)
                XCTAssertEqual(taxi?.productID, "3ab64887-4842-4c8e-9780-ccecd3a0391d")
                XCTAssertNil(uberPool?.priceDetails)
                XCTAssertEqual(taxi?.imageURL, URL(string: "http://d1a3f4spazzrp4.cloudfront.net/car-types/mono/mono-taxi.png")!)
                XCTAssertEqual(taxi?.cashEnabled, false)
                XCTAssertEqual(taxi?.isShared, false)
                XCTAssertEqual(taxi?.name, "TAXI")
                XCTAssertEqual(taxi?.productGroup, ProductGroup.taxi)
                XCTAssertEqual(taxi?.productDescription, "TAXI WITHOUT THE HASSLE")
            }
        }
    }
    
    /**
     Tests mapping of malformed result of GET /v1/products endpoint.
     */
    func testGetAllProductsBadJSON() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getProducts", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let JSONString = String(data: jsonData, encoding: String.Encoding.utf8)!
                
                // Represent some bad JSON
                let jsonData = JSONString.replacingOccurrences(of: "[", with: "").data(using: .utf8)!

                let products = try? JSONDecoder.uberDecoder.decode(UberProducts.self, from: jsonData)
                XCTAssertNil(products)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1.2/estimates/time
     */
    func testGetTimeEstimates() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getTimeEstimates", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let timeEstimates = try? JSONDecoder.uberDecoder.decode(TimeEstimates.self, from: jsonData)
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
     Tests mapping of malformed result of GET /v1.2/estimates/time
     */
    func testGetTimeEstimatesBadJSON() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getTimeEstimates", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let JSONString = String(data: jsonData, encoding: String.Encoding.utf8)!
                
                // Represent some bad JSON
                let jsonData = JSONString.replacingOccurrences(of: "[", with: "").data(using: .utf8)!

                let timeEstimates = try? JSONDecoder.uberDecoder.decode(TimeEstimates.self, from: jsonData)
                XCTAssertNil(timeEstimates)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1.2/estimates/price endpoint.
     */
    func testGetPriceEstimates() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getPriceEstimates", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                var priceEstimates: PriceEstimates?
                do {
                    priceEstimates = try JSONDecoder.uberDecoder.decode(PriceEstimates.self, from: jsonData)
                } catch let e {
                    XCTFail(e.localizedDescription)
                }
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
     Tests mapping of malformed result of GET /v1.2/estimates/price endpoint.
     */
    func testGetPriceEstimatesBadJSON() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getPriceEstimates", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let JSONString = String(data: jsonData, encoding: String.Encoding.utf8)!
                
                // Represent some bad JSON
                let jsonData = JSONString.replacingOccurrences(of: "[", with: "").data(using: .utf8)!

                let priceEstimates = try? JSONDecoder.uberDecoder.decode(PriceEstimates.self, from: jsonData)
                XCTAssertNil(priceEstimates)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1.2/history
     */
    func testGetTripHistory() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getHistory", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let userActivity = try? JSONDecoder.uberDecoder.decode(TripHistory.self, from: jsonData)
                XCTAssertNotNil(userActivity)
                XCTAssertNotNil(userActivity!.history)
                XCTAssertEqual(userActivity!.count, 1)
                XCTAssertEqual(userActivity!.limit, 5)
                XCTAssertEqual(userActivity!.offset, 0)
                
                let history = userActivity!.history
                XCTAssertEqual(history.count, 1)
                XCTAssertEqual(history[0].status, RideStatus.completed)
                XCTAssertEqual(history[0].distance, 1.64691465)
                XCTAssertEqual(history[0].requestTime, Date(timeIntervalSince1970: 1428876188))
                XCTAssertEqual(history[0].startTime, Date(timeIntervalSince1970: 1428876374))
                XCTAssertEqual(history[0].endTime, Date(timeIntervalSince1970: 1428876927))
                XCTAssertEqual(history[0].requestID, "37d57a99-2647-4114-9dd2-c43bccf4c30b")
                XCTAssertEqual(history[0].productID, "a1111c8c-c720-46c3-8534-2fcdd730040d")
                
                XCTAssertNotNil(history[0].startCity)
                
                let city = history[0].startCity
                XCTAssertEqual(city?.name, "San Francisco")
                XCTAssertEqual(city?.latitude, 37.7749295)
                XCTAssertEqual(city?.longitude, -122.4194155)
            }
        }
    }
    
    /**
     Tests mapping of malformed result of GET /v1.2/history endpoint.
     */
    func testGetHistoryBadJSON() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getHistory", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let JSONString = String(data: jsonData, encoding: String.Encoding.utf8)!
                
                // Represent some bad JSON
                let jsonData = JSONString.replacingOccurrences(of: "[", with: "").data(using: .utf8)!

                let userActivity = try? JSONDecoder.uberDecoder.decode(TripHistory.self, from: jsonData)
                XCTAssertNil(userActivity)
            }
        }
    }
    
    /**
     Tests mapping result of GET /v1/me endpoint.
     */
    func testGetUserProfile() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getMe", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let userProfile = try? JSONDecoder.uberDecoder.decode(UserProfile.self, from: jsonData)
                XCTAssertNotNil(userProfile)
                XCTAssertEqual(userProfile!.firstName, "Uber")
                XCTAssertEqual(userProfile!.lastName, "Developer")
                XCTAssertEqual(userProfile!.email, "developer@uber.com")
                XCTAssertEqual(userProfile!.picturePath, "https://profile-picture.jpg")
                XCTAssertEqual(userProfile!.promoCode, "teypo")
                XCTAssertEqual(userProfile!.UUID, "91d81273-45c2-4b57-8124-d0165f8240c0")
                XCTAssertEqual(userProfile!.riderID, "kIN8tMqcXMSJt1VC3HWNF0H4VD1JKlJkY==")
            }
        }
    }
    
     /**
     Tests mapping of malformed result of GET /v1/me endpoint.
     */
    func testGetUserProfileBadJSON() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getMe", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let JSONString = String(data: jsonData, encoding: String.Encoding.utf8)!
                let jsonData = JSONString.replacingOccurrences(of: "{", with: "").data(using: .utf8)!

                let userProfile = try? JSONDecoder.uberDecoder.decode(UserProfile.self, from: jsonData)
                XCTAssertNil(userProfile)
            }
        }
    }
    
    /**
     Tests mapping result of POST /v1/requests
     */
    func testPostRequest() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "postRequests", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let trip = try? JSONDecoder.uberDecoder.decode(Ride.self, from: jsonData) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertNotNil(trip)
                XCTAssertEqual(trip.requestID, "852b8fdd-4369-4659-9628-e122662ad257")
                XCTAssertEqual(trip.status, RideStatus.processing)
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
    func testGetRequestProcessing() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getRequestProcessing", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let trip = try? JSONDecoder.uberDecoder.decode(Ride.self, from: jsonData) else {
                    XCTAssert(false)
                    return
                }

                XCTAssertEqual(trip.requestID, "43faeac4-1634-4a0c-9826-783e3a3d1668")
                XCTAssertEqual(trip.productID, "a1111c8c-c720-46c3-8534-2fcdd730040d")
                XCTAssertEqual(trip.status, RideStatus.processing)
                XCTAssertEqual(trip.isShared, false)

                XCTAssertNil(trip.driverLocation)
                XCTAssertNil(trip.vehicle)
                XCTAssertNil(trip.driver)

                XCTAssertNotNil(trip.pickup)
                XCTAssertEqual(trip.pickup!.latitude, 37.7759792)
                XCTAssertEqual(trip.pickup!.longitude, -122.41823)
                XCTAssertNil(trip.pickup!.eta)

                XCTAssertNotNil(trip.destination)
                XCTAssertEqual(trip.destination!.latitude, 37.7259792)
                XCTAssertEqual(trip.destination!.longitude, -122.42823)
                XCTAssertNil(trip.destination!.eta)
            }
        }
    }

    /**
     Tests mapping result of GET /v1/requests/current or /v1/requests/{request_id}
     */
    func testGetRequestAccepted() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getRequestAccepted", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let trip = try? JSONDecoder.uberDecoder.decode(Ride.self, from: jsonData) else {
                    XCTAssert(false)
                    return
                }

                XCTAssertEqual(trip.requestID, "17cb78a7-b672-4d34-a288-a6c6e44d5315")
                XCTAssertEqual(trip.productID, "a1111c8c-c720-46c3-8534-2fcdd730040d")
                XCTAssertEqual(trip.status, RideStatus.accepted)
                XCTAssertEqual(trip.isShared, false)
                XCTAssertEqual(trip.surgeMultiplier, 1.0)

                XCTAssertNotNil(trip.driverLocation)
                XCTAssertEqual(trip.driverLocation!.latitude, 37.7886532015)
                XCTAssertEqual(trip.driverLocation!.longitude, -122.3961987534)
                XCTAssertEqual(trip.driverLocation!.bearing, 135)

                XCTAssertNotNil(trip.vehicle)
                XCTAssertEqual(trip.vehicle!.make, "Bugatti")
                XCTAssertEqual(trip.vehicle!.model, "Veyron")
                XCTAssertEqual(trip.vehicle!.licensePlate, "I<3Uber")
                XCTAssertEqual(trip.vehicle!.pictureURL, URL(string: "https://d1w2poirtb3as9.cloudfront.net/car.jpeg")!)

                XCTAssertNotNil(trip.driver)
                XCTAssertEqual(trip.driver!.name, "Bob")
                XCTAssertEqual(trip.driver!.pictureURL, URL(string: "https://d1w2poirtb3as9.cloudfront.net/img.jpeg")!)
                XCTAssertEqual(trip.driver!.phoneNumber, "+14155550000")
                XCTAssertEqual(trip.driver!.smsNumber, "+14155550000")
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
     Tests mapping result of GET /v1/requests/current or /v1/requests/{request_id}
     */
    func testGetRequestArriving() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getRequestArriving", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let trip = try? JSONDecoder.uberDecoder.decode(Ride.self, from: jsonData) else {
                    XCTAssert(false)
                    return
                }

                XCTAssertEqual(trip.requestID, "a274f565-cdb7-4a64-947d-042dfd185eed")
                XCTAssertEqual(trip.productID, "a1111c8c-c720-46c3-8534-2fcdd730040d")
                XCTAssertEqual(trip.status, RideStatus.arriving)
                XCTAssertEqual(trip.isShared, false)

                XCTAssertNotNil(trip.driverLocation)
                XCTAssertEqual(trip.driverLocation?.latitude, 37.7751956968)
                XCTAssertEqual(trip.driverLocation?.longitude, -122.4174361781)
                XCTAssertEqual(trip.driverLocation?.bearing, 310)

                XCTAssertNotNil(trip.vehicle)
                XCTAssertEqual(trip.vehicle?.make, "Oldsmobile")
                XCTAssertNil(trip.vehicle?.pictureURL)
                XCTAssertEqual(trip.vehicle?.model, "Alero")
                XCTAssertEqual(trip.vehicle?.licensePlate, "123-XYZ")

                XCTAssertNotNil(trip.driver)
                XCTAssertEqual(trip.driver?.phoneNumber, "+16504886027")
                XCTAssertEqual(trip.driver?.rating, 5)
                XCTAssertEqual(trip.driver?.pictureURL, URL(string: "https://d1w2poirtb3as9.cloudfront.net/4615701cdfbb033148d4.jpeg")!)
                XCTAssertEqual(trip.driver?.name, "Edward")
                XCTAssertEqual(trip.driver?.smsNumber, "+16504886027")

                XCTAssertNotNil(trip.pickup)
                XCTAssertEqual(trip.pickup!.latitude, 37.7759792)
                XCTAssertEqual(trip.pickup!.longitude, -122.41823)
                XCTAssertEqual(trip.pickup!.eta, 1)

                XCTAssertNotNil(trip.destination)
                XCTAssertEqual(trip.destination!.latitude, 37.7259792)
                XCTAssertEqual(trip.destination!.longitude, -122.42823)
                XCTAssertEqual(trip.destination!.eta, 16)
            }
        }
    }

    /**
     Tests mapping result of GET /v1/requests/current or /v1/requests/{request_id}
     */
    func testGetRequestInProgress() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getRequestInProgress", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let trip = try? JSONDecoder.uberDecoder.decode(Ride.self, from: jsonData) else {
                    XCTAssert(false)
                    return
                }

                XCTAssertEqual(trip.requestID, "a274f565-cdb7-4a64-947d-042dfd185eed")
                XCTAssertEqual(trip.productID, "a1111c8c-c720-46c3-8534-2fcdd730040d")
                XCTAssertEqual(trip.status, RideStatus.inProgress)
                XCTAssertEqual(trip.isShared, false)

                XCTAssertNotNil(trip.driverLocation)
                XCTAssertEqual(trip.driverLocation?.latitude, 37.7751956968)
                XCTAssertEqual(trip.driverLocation?.longitude, -122.4174361781)
                XCTAssertEqual(trip.driverLocation?.bearing, 310)

                XCTAssertNotNil(trip.vehicle)
                XCTAssertEqual(trip.vehicle?.make, "Oldsmobile")
                XCTAssertNil(trip.vehicle?.pictureURL)
                XCTAssertEqual(trip.vehicle?.model, "Alero")
                XCTAssertEqual(trip.vehicle?.licensePlate, "123-XYZ")

                XCTAssertNotNil(trip.driver)
                XCTAssertEqual(trip.driver?.phoneNumber, "+16504886027")
                XCTAssertEqual(trip.driver?.rating, 5)
                XCTAssertEqual(trip.driver?.pictureURL, URL(string: "https://d1w2poirtb3as9.cloudfront.net/4615701cdfbb033148d4.jpeg")!)
                XCTAssertEqual(trip.driver?.name, "Edward")
                XCTAssertEqual(trip.driver?.smsNumber, "+16504886027")

                XCTAssertNotNil(trip.pickup)
                XCTAssertEqual(trip.pickup!.latitude, 37.7759792)
                XCTAssertEqual(trip.pickup!.longitude, -122.41823)
                XCTAssertNil(trip.pickup!.eta)

                XCTAssertNotNil(trip.destination)
                XCTAssertEqual(trip.destination!.latitude, 37.7259792)
                XCTAssertEqual(trip.destination!.longitude, -122.42823)
                XCTAssertEqual(trip.destination!.eta, 16)
            }
        }
    }

    /**
     Tests mapping result of GET /v1/requests/current or /v1/requests/{request_id}
     */
    func testGetRequestCompleted() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getRequestCompleted", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let trip = try? JSONDecoder.uberDecoder.decode(Ride.self, from: jsonData) else {
                    XCTAssert(false)
                    return
                }

                XCTAssertEqual(trip.requestID, "a274f565-cdb7-4a64-947d-042dfd185eed")
                XCTAssertEqual(trip.productID, "a1111c8c-c720-46c3-8534-2fcdd730040d")
                XCTAssertEqual(trip.status, RideStatus.completed)
                XCTAssertEqual(trip.isShared, false)

                XCTAssertNil(trip.driverLocation)
                XCTAssertNil(trip.vehicle)
                XCTAssertNil(trip.driver)
                XCTAssertNil(trip.pickup)
                XCTAssertNil(trip.destination)
            }
        }
    }

    /**
     Tests mapping of POST /v1.2/requests/estimate endpoint.
     */
    func testGetRequestEstimate() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "requestEstimate", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                var estimate: RideEstimate?
                do {
                    estimate = try JSONDecoder.uberDecoder.decode(RideEstimate.self, from: jsonData)
                }
                catch let e {
                    XCTFail(e.localizedDescription)
                }
                XCTAssertNotNil(estimate)
                XCTAssertEqual(estimate!.pickupEstimate, 2)

                XCTAssertNotNil(estimate?.fare)
                XCTAssertEqual(estimate?.fare?.breakdown?.first?.name, "Base Fare")
                XCTAssertEqual(estimate?.fare?.breakdown?.first?.type, UpfrontFareComponentType.baseFare)
                XCTAssertEqual(estimate?.fare?.breakdown?.first?.value, 11.95)
                XCTAssertEqual(estimate?.fare?.value, 11.95)
                XCTAssertEqual(estimate?.fare?.fareID, "3d957d6ab84e88209b6778d91bd4df3c12d17b60796d89793d6ed01650cbabfe")
                XCTAssertEqual(estimate?.fare?.expiresAt, Date(timeIntervalSince1970: 1503702982))
                XCTAssertEqual(estimate?.fare?.display, "$11.95")
                XCTAssertEqual(estimate?.fare?.currencyCode, "USD")

                XCTAssertNotNil(estimate!.distanceEstimate)
                XCTAssertEqual(estimate!.distanceEstimate!.distance, 5.35)
                XCTAssertEqual(estimate!.distanceEstimate!.duration, 840)
                XCTAssertEqual(estimate!.distanceEstimate!.distanceUnit, "mile")
            }
        }
    }

    /**
     Tests mapping of POST /v1.2/requests/estimate endpoint for a city w/o upfront pricing.
     */
    func testGetRequestEstimateNoUpfront() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "requestEstimateNoUpfront", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let estimate = try? JSONDecoder.uberDecoder.decode(RideEstimate.self, from: jsonData)
                XCTAssertNotNil(estimate)
                XCTAssertEqual(estimate!.pickupEstimate, 2)

                XCTAssertNotNil(estimate!.priceEstimate)
                XCTAssertEqual(estimate!.priceEstimate?.surgeConfirmationURL, URL(string: "https://api.uber.com/v1/surge-confirmations/7d604f5e"))
                XCTAssertEqual(estimate!.priceEstimate?.surgeConfirmationID, "7d604f5e")

                XCTAssertNotNil(estimate!.distanceEstimate)
                XCTAssertEqual(estimate!.distanceEstimate!.distance, 4.87)
                XCTAssertEqual(estimate!.distanceEstimate!.duration, 660)
                XCTAssertEqual(estimate!.distanceEstimate!.distanceUnit, "mile")
            }
        }
    }
    
    func testGetRequestEstimateNoCars() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "requestEstimateNoCars", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let estimate = try? JSONDecoder.uberDecoder.decode(RideEstimate.self, from: jsonData)
                XCTAssertNotNil(estimate)
                XCTAssertNil(estimate!.pickupEstimate)

                XCTAssertNotNil(estimate!.priceEstimate)
                XCTAssertEqual(estimate!.priceEstimate?.surgeConfirmationURL, URL(string: "https://api.uber.com/v1/surge-confirmations/7d604f5e"))
                XCTAssertEqual(estimate!.priceEstimate?.surgeConfirmationID, "7d604f5e")

                XCTAssertNotNil(estimate!.distanceEstimate)
                XCTAssertEqual(estimate!.distanceEstimate!.distance, 4.87)
                XCTAssertEqual(estimate!.distanceEstimate!.duration, 660)
                XCTAssertEqual(estimate!.distanceEstimate!.distanceUnit, "mile")
            }
        }
    }
    
    /**
     Tests mapping of GET v1/places/{place_id} endpoint
     */
    func testGetPlace() {
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "place", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let place = try? JSONDecoder.uberDecoder.decode(Place.self, from: jsonData) else {
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
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "getPaymentMethods", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let paymentMethods = try? JSONDecoder.uberDecoder.decode(PaymentMethods.self, from: jsonData) else {
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
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "rideReceipt", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let receipt = try? JSONDecoder.uberDecoder.decode(RideReceipt.self, from: jsonData) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(receipt.requestID, "f590713c-fe6b-438b-9da1-8aeeea430657")
                
                let chargeAdjustments = receipt.chargeAdjustments
                
                XCTAssertEqual(chargeAdjustments?.count, 1)
                XCTAssertEqual(chargeAdjustments?.first?.name, "Booking Fee")
                XCTAssertEqual(chargeAdjustments?.first?.type, "booking_fee")

                XCTAssertEqual(receipt.subtotal, "$12.78")
                XCTAssertEqual(receipt.totalCharged, "$5.92")
                XCTAssertEqual(receipt.totalFare, "$12.79")
                XCTAssertEqual(receipt.totalOwed, 0.0)
                XCTAssertEqual(receipt.currencyCode, "USD")
                XCTAssertEqual(receipt.duration?.hour, 0)
                XCTAssertEqual(receipt.duration?.minute, 11)
                XCTAssertEqual(receipt.duration?.second, 32)
                XCTAssertEqual(receipt.distance, "1.87")
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
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "rideReceipt", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let JSONString = String(data: jsonData, encoding:  String.Encoding.utf8)!
                let jsonData = JSONString.replacingOccurrences(of: "[", with: "").data(using: .utf8)!
                let receipt = try? JSONDecoder.uberDecoder.decode(RideReceipt.self, from: jsonData)
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
        let bundle = Bundle(for: ObjectMappingTests.self)
        if let path = bundle.path(forResource: "rideMap", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                guard let map = try? JSONDecoder.uberDecoder.decode(RideMap.self, from: jsonData) else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(map.path, URL(string: "https://trip.uber.com/abc123")!)
                XCTAssertEqual(map.requestID, "b5512127-a134-4bf4-b1ba-fe9f48f56d9d")
                
                return
            }
        }
        
        XCTAssert(false)
    }
}
