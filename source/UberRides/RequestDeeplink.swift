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
    private var parameters: QueryParameters
    private var clientID: String
    private var deeplinkURI: String?
    private var source: RequestDeeplink.SourceParameter
    
    public init(withClientID: String, fromSource: SourceParameter = .Deeplink) {
        parameters = QueryParameters()
        clientID = withClientID
        source = fromSource
        parameters.setParameter(.ClientID, parameterValue: clientID)
    }
    
    /**
     Build a deeplink URI.
     */
    public func build() -> String {
        if !pickupLocationSet() {
            setPickupLocationToCurrentLocation()
        }
        
        if !parameters.pendingChanges {
            return deeplinkURI!
        }
        
        let components = NSURLComponents()
        components.scheme = "uber"
        components.host = ""
        components.queryItems = parameters.getQueryItems()
        
        parameters.pendingChanges = false;
        
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
        parameters.setParameter(.Action, parameterValue: "setPickup")
        parameters.setParameter(.PickupDefault, parameterValue: "my_location")
        parameters.deleteParameters([.PickupLatitude, .PickupLongitude, .PickupAddress, .PickupNickname])
    }
    
    /**
     Set deeplink pickup location information.
     
     - parameter latitude: The latitude coordinate for pickup.
     - parameter longitude: The longitude coordinate for pickup.
     - parameter nickname: A URL-encoded string of the pickup location name. (Optional)
     - parameter address:  A URL-encoded string of the pickup address. (Optional)
     */
    public func setPickupLocation(latitude latitude: Double, longitude: Double, nickname: String? = nil, address: String? = nil) {
        parameters.deleteParameters([.PickupNickname, .PickupAddress])
        parameters.setParameter(.Action, parameterValue: "setPickup")
        parameters.setParameter(.PickupLatitude, parameterValue: "\(latitude)")
        parameters.setParameter(.PickupLongitude, parameterValue: "\(longitude)")
        
        if nickname != nil {
            parameters.setParameter(.PickupNickname, parameterValue: nickname!)
        }
        if address != nil {
            parameters.setParameter(.PickupAddress, parameterValue: address!)
        }
        
        parameters.deleteParameters([.PickupDefault])
    }
    
    /**
     Set deeplink dropoff location information.
     
     - parameter latitude: The latitude coordinate for dropoff.
     - parameter longitude: The longitude coordinate for dropoff.
     - parameter nickname: A URL-encoded string of the dropoff location name. (Optional)
     - parameter address:  A URL-encoded string of the dropoff address. (Optional)
     */
    public func setDropoffLocation(latitude latitude: Double, longitude: Double, nickname: String? = nil, address: String? = nil) {
        parameters.deleteParameters([.DropoffNickname, .DropoffAddress])
        parameters.setParameter(.DropoffLatitude, parameterValue: "\(latitude)")
        parameters.setParameter(.DropoffLongitude, parameterValue: "\(longitude)")
        
        if nickname != nil {
            parameters.setParameter(.DropoffNickname, parameterValue: nickname!)
        }
        if address != nil {
            parameters.setParameter(.DropoffAddress, parameterValue: address!)
        }
    }
    
    /**
     Add a specific product ID to the deeplink. You can see product ID's for a given
     location with the Rides API `GET /v1/products` endpoint.
     */
    public func setProductID(productID: String) {
        parameters.setParameter(.ProductID, parameterValue: productID)
    }
    
    /**
     Return true if deeplink has set pickup latitude and longitude, false otherwise.
     */
    internal func pickupLocationSet() -> Bool {
        return (parameters.doesParameterExist(.PickupLatitude) && parameters.doesParameterExist(.PickupLongitude)) || parameters.doesParameterExist(.PickupDefault)
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
    func createURL(var url: String) -> NSURL {
        switch source {
        case .Button:
            url += "&user-agent=rides-button-v0.1.0"
        case .Deeplink:
            url += "&user-agent=rides-deeplink-v0.1.0"
        }
        return NSURL(string: url)!
    }
}


// Store mapping of parameter names to values
private class QueryParameters: NSObject {
    private var params = [String: String]()
    private var pendingChanges: Bool
    
    private override init() {
        pendingChanges = false;
    }
    
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
    
    /**
     Adds a query parameter. If parameterName has already been assigned a value,
     its overwritten with parameterValue.
     */
    private func setParameter(parameterName: QueryParameterName, parameterValue: String) {
        params[stringFromParameterName(parameterName)] = stringFromParameterValue(parameterValue)
        pendingChanges = true
    }
    
    /**
     Removes key-value pair of all query parameters in array of parameter names.
    */
    private func deleteParameters(parameters: Array<QueryParameterName>) {
        for name in parameters {
            params.removeValueForKey(stringFromParameterName(name))
        }
        pendingChanges = true
    }
    
    /**
     - returns: An array containing an NSURLQueryItem for every parameter
     */
    private func getQueryItems() -> Array<NSURLQueryItem> {
        var queryItems = [NSURLQueryItem]()
        
        for (parameterName, parameterValue) in params {
            let queryItem = NSURLQueryItem(name: parameterName, value: parameterValue)
            queryItems.append(queryItem)
        }
        
        return queryItems
    }
    
    /**
     - returns: true if given query parameter has been set; false otherwise.
     */
    private func doesParameterExist(parameterName: QueryParameterName) -> Bool {
        return params[stringFromParameterName(parameterName)] != nil
    }
    
    private func stringFromParameterName(name: QueryParameterName) -> String {
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
    
    private func stringFromParameterValue(value: String) -> String {
        let customAllowedChars =  NSCharacterSet(charactersInString: " =\"#%/<>?@\\^`{|}!$&'()*+,:;[]%").invertedSet
        return value.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedChars)!
    }
}
