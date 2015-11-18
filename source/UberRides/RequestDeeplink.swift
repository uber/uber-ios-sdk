//
//  RequestDeeplink.swift
//  Rides
//

/*
* Copyright © 2015 Uber Technologies, Inc. All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/


import Foundation
import UIKit

// RequestDeeplink builds and executes a deeplink to the native Uber app.
public class RequestDeeplink: NSObject {
    private var parameters: [QueryParameter]
    private var clientID: String
    private var deeplinkURI: String?
    private var source: RequestDeeplink.SourceParameter
    
    public init(withClientID: String, fromSource: SourceParameter = .deeplink) {
        clientID = withClientID
        source = fromSource
        parameters = [QueryParameter(parameterName: .clientID, parameterValue: clientID)]
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
        let deeplinkURL = createURL(deeplinkURI!)
        let appstoreURL = createURL("https://m.uber.com/sign-up?client_id=" + clientID)

        if UIApplication.sharedApplication().canOpenURL(deeplinkURL) {
            UIApplication.sharedApplication().openURL(deeplinkURL)
        } else {
            UIApplication.sharedApplication().openURL(appstoreURL)
        }
    }
    
    /**
     Set the user's current location as a default pickup location.
     */
    public func setPickupLocationToCurrentLocation() {
        parameters.append(QueryParameter(parameterName: .action, parameterValue: "setPickup"))
        parameters.append(QueryParameter(parameterName: .pickupDefault, parameterValue: "my_location"))
    }
    
    /**
     Set deeplink pickup location information.
     */
    public func setPickupLocation(latitude lat: String, longitude: String, nickname: String? = nil, address: String? = nil) {
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
    public func setDropoffLocation(latitude lat: String, longitude: String, nickname: String? = nil, address: String? = nil) {
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
    public func setProductID(productID: String) {
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
    
    /**
     Possible sources for the deeplink.
     */
    @objc public enum SourceParameter: Int {
        case button
        case deeplink
    }
    
    /**
     Create an NSURL from a String. Add parameter for tracking and affiliation program.
     */
    private func createURL(var url: String) -> NSURL {
        switch source {
        case .button:
            url += "&user-agent=rides-button-v0.1.0"
        case .deeplink:
            url += "user-agent=rides-deeplink-v0.1.0"
        }
        return NSURL(string: url)!
    }
}


// Store information about the name and value of a query parameter.
private class QueryParameter: NSObject {
    
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
