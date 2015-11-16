//
//  RequestDeeplink.swift
//  Rides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//

import Foundation
import UIKit

// RequestDeeplink builds and executes a deeplink to the native Uber app.
internal class RequestDeeplink {
    private var parameters: [QueryParameter]
    private var clientID: String
    private var deeplinkURI: String?
    
    internal init(withClientID: String) {
        clientID = withClientID
        parameters = [QueryParameter(parameterName: .clientID, parameterValue: clientID)]
    }
    
    /**
     Build a deeplink URI.
     */
    internal func build() -> String {
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
    internal func execute() {
        let deeplinkNSURL = NSURL(string: deeplinkURI!)
        let appstoreNSURL = NSURL(string: "https://m.uber.com/sign-up?client_id=" + clientID)
        
        print(deeplinkNSURL!)
        if UIApplication.sharedApplication().canOpenURL(deeplinkNSURL!) {
            UIApplication.sharedApplication().openURL(deeplinkNSURL!)
        } else {
            UIApplication.sharedApplication().openURL(appstoreNSURL!)
        }
    }
    
    /**
     Set the user's current location as a default pickup location.
     */
    internal func setPickupLocationToCurrentLocation() {
        parameters.append(QueryParameter(parameterName: .action, parameterValue: "setPickup"))
        parameters.append(QueryParameter(parameterName: .pickupDefault, parameterValue: "my_location"))
    }
    
    /**
     Set deeplink pickup location information.
     */
    internal func setPickupLocation(latitude lat: String, longitude: String, nickname: String? = nil, address: String? = nil) {
        parameters.append(QueryParameter(parameterName: .action, parameterValue: "setPickup"))
        parameters.append(QueryParameter(parameterName: .pickupLatitude, parameterValue: lat))
        parameters.append(QueryParameter(parameterName: .pickupLongitude, parameterValue: longitude))
        
        if nickname != nil {
            parameters.append(QueryParameter(parameterName: .pickupNickname, parameterValue: nickname!))
        }
        if address != nil {
            parameters.append(QueryParameter(parameterName: .pickupAddress, parameterValue: address!))
        }
    }
    
    /**
     Set deeplink dropoff location information.
     */
    internal func setDropoffLocation(latitude lat: String, longitude: String, nickname: String? = nil, address: String? = nil) {
        parameters.append(QueryParameter(parameterName: .dropoffLatitude, parameterValue: lat))
        parameters.append(QueryParameter(parameterName: .dropoffLongitude, parameterValue: longitude))
        
        if nickname != nil {
            parameters.append(QueryParameter(parameterName: .dropoffNickname, parameterValue: nickname!))
        }
        if address != nil {
            parameters.append(QueryParameter(parameterName: .dropoffAddress, parameterValue: address!))
        }
    }
    
    /**
     Add a specific product ID to the deeplink. You can see product ID's for a given
     location with the Rides API `GET /v1/products` endpoint.
     */
    internal func setProductID(productID: String) {
        parameters.append(QueryParameter(parameterName: .productID, parameterValue: productID))
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


// Store information about the name and value of a query parameter.
private class QueryParameter: NSObject {
    
    private let name: QueryParameterName
    private let value: String
    
    private init(parameterName: QueryParameterName, parameterValue: String) {
        name = parameterName
        value = parameterValue
        super.init()
    }
    
    private func toString() -> String {
        let customAllowedChars =  NSCharacterSet(charactersInString: " =\"#%/<>?@\\^`{|}!$&'()*+,:;[]%").invertedSet
        let encodeValue = value.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedChars)!
        return "\(encodeName())=\(encodeValue)"
    }
    
    private func encodeName() -> String {
        switch name {
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
