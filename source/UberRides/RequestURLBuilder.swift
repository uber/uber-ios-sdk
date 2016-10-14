//
//  RequestURLBuilder.swift
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

import CoreLocation

class RequestURLBuilder {
    
    fileprivate enum LocationType: String {
        case Pickup = "pickup"
        case Dropoff = "dropoff"
    }
    
    static let actionKey = "action"
    static let setPickupValue = "setPickup"
    static let clientIDKey = "client_id"
    static let productIDKey = "product_id"
    static let currentLocationValue = "my_location"
    static let latitudeKey = "[latitude]"
    static let longitudeKey = "[longitude]"
    static let nicknameKey = "[nickname]"
    static let formattedAddressKey = "[formatted_address]"
    static let deeplinkScheme = "uber"
    static let userAgentKey = "user-agent"
    
    fileprivate let clientID: String
    fileprivate var rideParameters: RideParameters?
    
    init() {
        clientID = Configuration.getClientID()
    }
    
    func setRideParameters(_ rideParameters: RideParameters) -> RequestURLBuilder {
        self.rideParameters = rideParameters
        
        return self
    }
    
    func build() -> URL? {
        guard let rideParameters = rideParameters else {
            return nil
        }
        var urlComponents = URLComponents()
        
        urlComponents.scheme = RequestURLBuilder.deeplinkScheme
        urlComponents.host = ""
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: RequestURLBuilder.actionKey, value: RequestURLBuilder.setPickupValue))
        queryItems.append(URLQueryItem(name: RequestURLBuilder.clientIDKey, value: clientID))
        
        if let productID = rideParameters.productID {
            queryItems.append(URLQueryItem(name: RequestURLBuilder.productIDKey, value: productID))
        }
        
        if let location = rideParameters.pickupLocation {
            queryItems.append(contentsOf: addLocation(LocationType.Pickup, location: location, nickname: rideParameters.pickupNickname, address: rideParameters.pickupAddress))
        } else {
            queryItems.append(URLQueryItem(name: LocationType.Pickup.rawValue, value: RequestURLBuilder.currentLocationValue))
        }
        
        if let location = rideParameters.dropoffLocation {
            queryItems.append(contentsOf: addLocation(LocationType.Dropoff, location: location, nickname: rideParameters.dropoffNickname, address: rideParameters.dropoffAddress))
        }
        
        queryItems.append(URLQueryItem(name: RequestURLBuilder.userAgentKey, value: rideParameters.userAgent))
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
    
    fileprivate func addLocation(_ locationType: LocationType, location: CLLocation, nickname: String?, address: String?) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        let locationPrefix = locationType.rawValue
        let latitudeString = "\(location.coordinate.latitude)"
        let longitudeString = "\(location.coordinate.longitude)"
        queryItems.append(URLQueryItem(name: locationPrefix + RequestURLBuilder.latitudeKey, value: latitudeString))
        queryItems.append(URLQueryItem(name: locationPrefix + RequestURLBuilder.longitudeKey, value: longitudeString))
        if let nickname = nickname {
            queryItems.append(URLQueryItem(name: locationPrefix + RequestURLBuilder.nicknameKey, value: nickname))
        }
        if let address = address {
            queryItems.append(URLQueryItem(name: locationPrefix + RequestURLBuilder.formattedAddressKey, value: address))
        }
        
        return queryItems
    }
}
