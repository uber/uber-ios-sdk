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

/// Object to represent the parameters needed to request a ride. Should be built using a RideParametersBuilder
@objc(UBSDKRideParameters) open class RideParameters : NSObject {
    
    /// True if the pickup location should use the device's current location, false if a location has been set
    open let useCurrentLocationForPickup: Bool
    
    /// ProductID to use for the ride
    open let productID: String?
    
    /// The pickup location to use for the ride
    open let pickupLocation: CLLocation?
    
    /// The nickname of the pickup location of the ride
    open let pickupNickname: String?
    
    /// The address of the pickup location of the ride
    open let pickupAddress: String?
    
    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    open let pickupPlaceID: String?
    
    /// The dropoff location to use for the ride
    open let dropoffLocation: CLLocation?
    
    /// The nickname of the dropoff location for the ride
    open let dropoffNickname: String?
    
    /// The adress of the dropoff location of the ride
    open let dropoffAddress: String?
    
    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    open let dropoffPlaceID: String?
    
    /// The unique identifier of the payment method selected by a user.
    open let paymentMethod: String?
    
    /// The unique identifier of the surge session for a user.
    open let surgeConfirmationID: String?
    
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
    
    var source: String?
    
    fileprivate init(dropoffAddress: String?,
        dropoffLocation: CLLocation?,
        dropoffNickname: String?,
        dropoffPlaceID: String?,
        paymentMethod: String?,
        pickupAddress: String?,
        pickupLocation: CLLocation?,
        pickupNickname: String?,
        pickupPlaceID: String?,
        productID: String?,
        source: String?,
        surgeConfirmationID: String?,
        useCurrentLocationForPickup: Bool) {
        
            self.useCurrentLocationForPickup = useCurrentLocationForPickup
            self.productID = productID
            self.pickupLocation = pickupLocation
            self.pickupNickname = pickupNickname
            self.pickupAddress = pickupAddress
            self.pickupPlaceID = pickupPlaceID
            self.dropoffLocation = dropoffLocation
            self.dropoffNickname = dropoffNickname
            self.dropoffAddress = dropoffAddress
            self.dropoffPlaceID = dropoffPlaceID
            self.paymentMethod = paymentMethod
            self.surgeConfirmationID = surgeConfirmationID
            self.source = source
    }
    
}

/// Builder for a RideParameters object.
@objc(UBSDKRideParametersBuilder) open class RideParametersBuilder : NSObject {
    
    fileprivate var useCurrentLocationForPickup: Bool
    fileprivate var productID: String?
    fileprivate var pickupLocation: CLLocation?
    fileprivate var pickupNickname: String?
    fileprivate var pickupAddress: String?
    fileprivate var pickupPlaceID: String?
    fileprivate var dropoffLocation: CLLocation?
    fileprivate var dropoffNickname: String?
    fileprivate var dropoffAddress: String?
    fileprivate var dropoffPlaceID: String?
    fileprivate var paymentMethod: String?
    fileprivate var surgeConfirmationID: String?
    fileprivate var source: String?
    
    @objc public convenience override init() {
        self.init(rideParameters: nil)
    }
    
    @objc public init(rideParameters: RideParameters?) {
        if let rideParameters = rideParameters {
            useCurrentLocationForPickup = rideParameters.useCurrentLocationForPickup
            productID = rideParameters.productID
            pickupLocation = rideParameters.pickupLocation
            pickupNickname = rideParameters.pickupNickname
            pickupAddress = rideParameters.pickupAddress
            pickupPlaceID = rideParameters.pickupPlaceID
            dropoffLocation = rideParameters.dropoffLocation
            dropoffNickname =  rideParameters.dropoffNickname
            dropoffAddress = rideParameters.dropoffAddress
            dropoffPlaceID = rideParameters.dropoffPlaceID
            paymentMethod = rideParameters.paymentMethod
            surgeConfirmationID = rideParameters.surgeConfirmationID
            
            source = rideParameters.source
        } else {
            useCurrentLocationForPickup = true
        }
    }
    
    /**
     Set the product ID for the ride parameters.
     
     - parameter productID: The unique ID of the product being requested.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setProductID(_ productID: String) -> RideParametersBuilder {
        self.productID = productID
        
        return self
    }
    
    /**
     Sets the builder to use your current location for pickup. Will clear any set
     pickupLocation, pickupNickname, and pickupAddress.
     */
    open func setPickupToCurrentLocation() -> RideParametersBuilder {
        useCurrentLocationForPickup = true
        pickupLocation = nil
        pickupNickname = nil
        pickupAddress = nil
        
        return self
    }
    
    /**
     Sets the builder to use the given place ID as the pickup location. This will remove any existing pickup location.
     Please note that place IDs are not supported for RequestDeeplink.
     
     - parameter placeID: the place ID of the pickup location - either "home" or "work".
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setPickupPlaceID(_ placeID: String) -> RideParametersBuilder {
        useCurrentLocationForPickup = false
        pickupPlaceID = placeID
        pickupLocation = nil
        pickupNickname = nil
        pickupAddress = nil
        
        return self
    }
    
    /**
     Set pickup location information for the ride parameters.
     
     - parameter location: CLLocation of pickup.
     - parameter nickname: Optional nickname of pickup location.
     - parameter address:  Optional address of pickup location.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setPickupLocation(_ location: CLLocation, nickname: String?, address: String?) -> RideParametersBuilder {
        useCurrentLocationForPickup = false
        pickupLocation = location
        pickupNickname = nickname
        pickupAddress = address
        
        return self
    }
    
    /**
     Set pickup location information for the ride parameters.
     
     - parameter location: CLLocation of pickup.
     - parameter address:  Optional address of pickup location.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setPickupLocation(_ location: CLLocation, address: String?) -> RideParametersBuilder {
        return self.setPickupLocation(location, nickname: nil, address: address)
    }
    
    /**
     Set pickup location information for the ride parameters.
     
     - parameter location: CLLocation of pickup.
     - parameter nickname: Optional nickname of pickup location.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setPickupLocation(_ location: CLLocation, nickname: String?) -> RideParametersBuilder {
        return self.setPickupLocation(location, nickname: nickname, address: nil)
    }
    
    /**
     Set pickup location information for the ride parameters.
     
     - parameter location: CLLocation of pickup.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setPickupLocation(_ location: CLLocation) -> RideParametersBuilder {
        return self.setPickupLocation(location, nickname: nil, address: nil)
    }
    
    /**
     Set dropoff location information for the ride parameters.
     
     - parameter location: CLLocation of dropoff.
     - parameter nickname: Optional nickname of dropoff location.
     - parameter address:  Optional address of dropoff location.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setDropoffLocation(_ location: CLLocation, nickname: String?, address: String?) -> RideParametersBuilder {
        dropoffLocation = location
        dropoffNickname = nickname
        dropoffAddress = address
        
        return self
    }
    
    /**
     Set dropoff location information for the ride parameters.
     
     - parameter location: CLLocation of dropoff.
     - parameter address:  Optional address of dropoff location.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setDropoffLocation(_ location: CLLocation, address: String?) -> RideParametersBuilder {
        return self.setDropoffLocation(location, nickname: nil, address: address)
    }
    
    /**
     Set dropoff location information for the ride parameters.
     
     - parameter location: CLLocation of dropoff.
     - parameter nickname: Optional nickname of dropoff location.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setDropoffLocation(_ location: CLLocation, nickname: String?) -> RideParametersBuilder {
        return self.setDropoffLocation(location, nickname: nickname, address: nil)
    }
    
    /**
     Set dropoff location information for the ride parameters.
     
     - parameter location: CLLocation of dropoff.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setDropoffLocation(_ location: CLLocation) -> RideParametersBuilder {
        return self.setDropoffLocation(location, nickname: nil, address: nil)
    }
    
    /**
     Sets the builder to use the given place ID as the dropoff location. This will remove any existing dropoff location.
     Please note that place IDs are not supported for RequestDeeplink and the Ride Request Widget.
     
     - parameter placeID: the place ID of the dropoff location - either "home" or "work".
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setDropoffPlaceID(_ placeID: String) -> RideParametersBuilder {
        dropoffPlaceID = placeID
        dropoffLocation = nil
        dropoffNickname = nil
        dropoffAddress = nil
        
        return self
    }
    
    /**
     Sets the builder to use the given payment method for the user. 
     If set, the trip will be requested using this payment method.
     If not set, the trip will be requested using the user’s last used payment method.
     Please note that payment methods are not supported for RequestDeeplink and the Ride Request Widget.
     
     - parameter method: unique identifier of payment method.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setPaymentMethod(_ method: String) -> RideParametersBuilder {
        paymentMethod = method
        
        return self
    }
    
    /**
     Sets the builder to use the surge confirmation ID for making ride requests that have surge.
     Please note surge confirmation is not supported for RequestDeeplink and the Ride Request Widget.
     
     - parameter surgeConfirmation: the unique identifier of the surge session for a user.
     
     - returns: RideParametersBuilder to continue chaining.
     */
    open func setSurgeConfirmationID(_ surgeConfirmation: String) -> RideParametersBuilder {
        surgeConfirmationID = surgeConfirmation
        
        return self
    }
    
    /**
     Set the source to use for attributing the ride
     
     - parameter source: The source string to use
     
     - returns: RideParametersBuilder to continue chaining.
     */
    func setSource(_ source: String?) -> RideParametersBuilder {
        self.source = source
        
        return self
    }
    
    /**
     Build the ride parameter object.
     
     - returns: An initialized RideParameters object
     */
    open func build() -> RideParameters {
        return RideParameters(dropoffAddress: dropoffAddress,
            dropoffLocation: dropoffLocation,
            dropoffNickname: dropoffNickname,
            dropoffPlaceID: dropoffPlaceID,
            paymentMethod: paymentMethod,
            pickupAddress: pickupAddress,
            pickupLocation: pickupLocation,
            pickupNickname: pickupNickname,
            pickupPlaceID: pickupPlaceID,
            productID: productID,
            source: source,
            surgeConfirmationID: surgeConfirmationID,
            useCurrentLocationForPickup: useCurrentLocationForPickup)
    }
    
}
