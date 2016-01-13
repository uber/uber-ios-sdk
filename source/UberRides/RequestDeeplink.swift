//
//  RequestDeeplink.swift
//  UberRides
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


import Foundation
import UIKit

// RequestDeeplink builds and executes a deeplink to the native Uber app.
public class RequestDeeplink: NSObject {
    private var parameters: [QueryParameter]
    private var clientID: String
    private var deeplinkURI: String?
    private var source: RequestDeeplink.SourceParameter
    
    public init(withClientID: String, fromSource: SourceParameter = .Deeplink) {
        clientID = withClientID
        source = fromSource
        parameters = [QueryParameter(parameterName: .ClientID, parameterValue: clientID)]
    }
    
    /**
     Build a deeplink URI.
     */
    public func build() -> String {
        if !pickupLocationSet() {
            setPickupLocationToCurrentLocation()
        }
        
        let components = NSURLComponents()
        components.scheme = "uber"
        components.host = ""
        
        var queryItems = [NSURLQueryItem]()
        for parameter in parameters {
            queryItems.append(parameter.toQueryItem())
        }
        components.queryItems = queryItems
        
        deeplinkURI = components.string?.stringByRemovingPercentEncoding
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
        parameters.append(QueryParameter(parameterName: .Action, parameterValue: "setPickup"))
        parameters.append(QueryParameter(parameterName: .PickupDefault, parameterValue: "my_location"))
    }
    
    /**
     Set deeplink pickup location information.
     */
    public func setPickupLocation(latitude lat: String, longitude: String, nickname: String? = nil, address: String? = nil) {
        parameters.append(QueryParameter(parameterName: .Action, parameterValue: "setPickup"))
        parameters.append(QueryParameter(parameterName: .PickupLatitude, parameterValue: lat))
        parameters.append(QueryParameter(parameterName: .PickupLongitude, parameterValue: longitude))
        
        if nickname != nil {
            parameters.append(QueryParameter(parameterName: .PickupNickname, parameterValue: nickname!))
        }
        if address != nil {
            parameters.append(QueryParameter(parameterName: .PickupAddress, parameterValue: address!))
        }
    }
    
    /**
     Set deeplink dropoff location information.
     */
    public func setDropoffLocation(latitude lat: String, longitude: String, nickname: String? = nil, address: String? = nil) {
        parameters.append(QueryParameter(parameterName: .DropoffLatitude, parameterValue: lat))
        parameters.append(QueryParameter(parameterName: .DropoffLongitude, parameterValue: longitude))
        
        if nickname != nil {
            parameters.append(QueryParameter(parameterName: .DropoffNickname, parameterValue: nickname!))
        }
        if address != nil {
            parameters.append(QueryParameter(parameterName: .DropoffAddress, parameterValue: address!))
        }
    }
    
    /**
     Add a specific product ID to the deeplink. You can see product ID's for a given
     location with the Rides API `GET /v1/products` endpoint.
     */
    public func setProductID(productID: String) {
        parameters.append(QueryParameter(parameterName: .ProductID, parameterValue: productID))
    }
    
    /**
     Return true if deeplink has set pickup latitude and longitude, false otherwise.
     */
    internal func pickupLocationSet() -> Bool {
        var hasLatitude = false
        var hasLongitude = false
        
        for parameter in parameters {
            if parameter.name == .PickupLatitude {
                hasLatitude = true
            } else if parameter.name == .PickupLongitude {
                hasLongitude = true
            }
        }
        
        return (hasLatitude && hasLongitude)
    }
    
    /**
     Possible sources for the deeplink.
     */
    @objc public enum SourceParameter: Int {
        case Button
        case Deeplink
    }
    
    /**
     Create an NSURL from a String. Add parameter for tracking and affiliation program.
     */
    private func createURL(var url: String) -> NSURL {
        switch source {
        case .Button:
            url += "&user-agent=rides-button-v0.1.0"
        case .Deeplink:
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
        case Action
        case ClientID
        case ProductID
        case PickupDefault
        case PickupLatitude
        case PickupLongitude
        case PickupNickname
        case PickupAddress
        case DropoffLatitude
        case DropoffLongitude
        case DropoffNickname
        case DropoffAddress
    }
    
    private let name: QueryParameterName
    private let value: String
    
    private init(parameterName: QueryParameterName, parameterValue: String) {
        name = parameterName
        value = parameterValue
        super.init()
    }

    private func toQueryItem() -> NSURLQueryItem {
        let queryItem = NSURLQueryItem(name: stringFromParameterName(), value: stringFromParamaterValue())
        return queryItem
    }
    
    private func stringFromParamaterValue() -> String {
        let customAllowedChars =  NSCharacterSet(charactersInString: " =\"#%/<>?@\\^`{|}!$&'()*+,:;[]%").invertedSet
        return value.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedChars)!
    }
    
    private func stringFromParameterName() -> String {
        switch name {
        case .Action:
            return "action"
        case .ClientID:
            return "client_id"
        case .ProductID:
            return "product_id"
        case .PickupDefault:
            return "pickup"
        case .PickupLatitude:
            return "pickup[latitude]"
        case .PickupLongitude:
            return "pickup[longitude]"
        case .PickupNickname:
            return "pickup[nickname]"
        case .PickupAddress:
            return "pickup[formatted_address]"
        case .DropoffLatitude:
            return "dropoff[latitude]"
        case .DropoffLongitude:
            return "dropoff[longitude]"
        case .DropoffNickname:
            return "dropoff[nickname]"
        case .DropoffAddress:
            return "dropoff[formatted_address]"
        }
    }
}
