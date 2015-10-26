//
//  UberDeeplink.swift
//  sdk
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//

import Foundation
import UIKit

/// UberDeeplink builds and executes a deeplink to the native Uber app.
public class UberDeeplink {
    private var parameters: [QueryParameter]
    private var clientID: String
    private var deeplinkURI: String?
    
    public init(clientID: String) {
        parameters = [QueryParameter(name: .clientID, value: clientID)]
        self.clientID = clientID
    }
    
    /**
    Build a deeplink URI.
    */
    public func build() -> String {
        if !PickupLocationSet() {
            setPickupLocationToCurrentLocation()
        }
        
        let deeplink = "uber://?"
        var parameterStrings: [String] = []
        for parameter in parameters {
            parameterStrings.append(parameter.toString())
        }
        deeplinkURI = deeplink + parameterStrings.joinWithSeparator("&")
        return deeplinkURI!
    }
    
    /**
    Execute deeplink to launch the Uber app. Redirect to the app store if the app is not installed.
    */
    public func execute() {
        let deeplinkNSURL = NSURL(string: deeplinkURI!)
        let appstoreNSURL = NSURL(string: "https://m.uber.com/sign-up?client_id=" + clientID)
        
        if UIApplication.sharedApplication().canOpenURL(deeplinkNSURL!) {
            UIApplication.sharedApplication().openURL(deeplinkNSURL!)
        } else {
            UIApplication.sharedApplication().openURL(appstoreNSURL!)
        }
    }
    
    /**
    Set the user's current location as a default pickup location.
    */
    public func setPickupLocationToCurrentLocation() {
        parameters.append(QueryParameter(name: .action, value: "setPickup"))
        parameters.append(QueryParameter(name: .pickupDefault, value: "my_location"))
    }
    
    /**
    Set deeplink pickup location information.
    
    - parameter latitude:  The latitude coordinate for pickup
    - parameter longitude: The longitude coordinate for pickup
    - parameter nickname:  Optional pickup location name
    - parameter address:   Optional pickup location address
    */
    public func setPickupLocation(latitude: String, longitude: String, nickname: String? = nil, address: String? = nil) {
        parameters.append(QueryParameter(name: .action, value: "setPickup"))
        parameters.append(QueryParameter(name: .pickupLatitude, value: latitude))
        parameters.append(QueryParameter(name: .pickupLongitude, value: longitude))
        
        if nickname != nil {
            parameters.append(QueryParameter(name: .pickupNickname, value: nickname!))
        }
        if address != nil {
            parameters.append(QueryParameter(name: .pickupAddress, value: address!))
        }
    }
    
    /**
    Set deeplink dropoff location information.
    
    - parameter latitude:  The latitude coordinate for dropoff
    - parameter longitude: The longitude coordinate for dropoff
    - parameter nickname:  Optional dropoff location name
    - parameter address:   Optional dropoff location address
    */
    public func setDropoffLocation(latitude: String, longitude: String, nickname: String? = nil, address: String? = nil) {
        parameters.append(QueryParameter(name: .dropoffLatitude, value: latitude))
        parameters.append(QueryParameter(name: .dropoffLongitude, value: longitude))
        
        if nickname != nil {
            parameters.append(QueryParameter(name: .dropoffNickname, value: nickname!))
        }
        if address != nil {
            parameters.append(QueryParameter(name: .dropoffAddress, value: address!))
        }
    }
    
    /**
    Add a specific product ID to the deeplink. You can see product ID's for a given
    location with the Rides API `GET /v1/products` endpoint.
    
    - parameter productID: Unique identifier of the product to populate in pickup
    */
    public func setProductID(productID: String) {
        parameters.append(QueryParameter(name: .productID, value: productID))
    }
    
    /**
    Return true if deeplink has set pickup latitude and longitude, false otherwise.
    */
    internal func PickupLocationSet() -> Bool {
        var hasLatitude = false
        var hasLongitude = false
        
        for parameter in parameters {
            if parameter.name == .pickupLatitude {
                hasLatitude = true
            } else if parameter.name == .pickupLongitude {
                hasLongitude = true
            }
        }
        
        if hasLatitude && hasLongitude {
            return true
        } else {
            return false
        }
    }
}

/**
QueryParameterName is a set of query parameters than can be sent
in a deeplink. `clientID` is a required query parameter.

Optional query parameters can be used to automatically pass additional
information, like a user's destination, over to the native Uber App.
*/
private enum QueryParameterName: Int {
    case action
    case clientID
    case productID
    case pickupDefault
    case pickupLatitude
    case pickupLongitude
    case pickupNickname
    case pickupAddress
    case dropoffLatitude
    case dropoffLongitude
    case dropoffNickname
    case dropoffAddress
}


/// Store information about the name and value of a query parameter.
private class QueryParameter: NSObject {
    
    private let name: QueryParameterName
    private let value: String
    
    private init(name: QueryParameterName, value: String) {
        self.name = name
        self.value = value
        super.init()
    }
    
    private func toString() -> String {
        let customAllowedChars =  NSCharacterSet(charactersInString: " =\"#%/<>?@\\^`{|}!$&'()*+,:;[]%").invertedSet
        let encodeValue = self.value.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedChars)!
        return "\(encodeName())=\(encodeValue)"
    }
    
    private func encodeName() -> String {
        switch self.name {
        case .action:
            return "action"
        case .clientID:
            return "client_id"
        case .productID:
            return "product_id"
        case .pickupDefault:
            return "pickup"
        case .pickupLatitude:
            return "pickup[latitude]"
        case .pickupLongitude:
            return "pickup[longitude]"
        case .pickupNickname:
            return "pickup[nickname]"
        case .pickupAddress:
            return "pickup[formatted_address]"
        case .dropoffLatitude:
            return "dropoff[latitude]"
        case .dropoffLongitude:
            return "dropoff[longitude]"
        case .dropoffNickname:
            return "dropoff[nickname]"
        case .dropoffAddress:
            return "dropoff[formatted_address]"
        }
    }
}
