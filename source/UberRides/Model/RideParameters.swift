//
//  RideParameters.swift
//  UberRides
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

import MapKit

/// Object to represent the parameters needed to request a ride.
@objc(UBSDKRideParameters) public class RideParameters : NSObject {
    
    /// ProductID to use for the ride
    public var productID: String?
    
    /// The pickup location to use for the ride
    public let pickupLocation: CLLocation?

    /// The nickname of the pickup location of the ride
    public var pickupNickname: String?
    
    /// The address of the pickup location of the ride
    public var pickupAddress: String?
    
    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    public let pickupPlaceID: String?
    
    /// The dropoff location to use for the ride
    public let dropoffLocation: CLLocation?
    
    /// The nickname of the dropoff location for the ride
    public var dropoffNickname: String?
    
    /// The adress of the dropoff location of the ride
    public var dropoffAddress: String?
    
    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    public let dropoffPlaceID: String?
    
    /// The unique identifier of the payment method selected by a user.
    public var paymentMethod: String?
    
    /// The unique identifier of the surge session for a user.
    public var surgeConfirmationID: String?

    /// The source to use for attributing the ride
    public var source: String?

    convenience override init() {
        self.init(pickupLocation: nil, dropoffLocation: nil, pickupPlaceID: nil, dropoffPlaceID: nil)
    }

    convenience init(pickupLocation: CLLocation?, dropoffLocation: CLLocation?) {
        self.init(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation, pickupPlaceID: nil, dropoffPlaceID: nil)
    }

    convenience init(pickupPlaceID: String?, dropoffPlaceID: String?) {
        self.init(pickupLocation: nil, dropoffLocation: nil, pickupPlaceID: pickupPlaceID, dropoffPlaceID: dropoffPlaceID)
    }

    private init(pickupLocation: CLLocation?,
                 dropoffLocation: CLLocation?,
                 pickupPlaceID: String?,
                 dropoffPlaceID: String?) {
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.pickupPlaceID = pickupPlaceID
        self.dropoffPlaceID = dropoffPlaceID

        super.init()
    }

    var userAgent: String {
        var userAgentString: String = ""
        if let versionNumber: String = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            userAgentString = "rides-ios-v\(versionNumber)"
            if let source = source {
                userAgentString = "\(userAgentString)-\(source)"
            }
        }
        return userAgentString
    }
}
