//
//  RidesUtil.swift
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
import CoreLocation

@objc enum UberButtonColor: Int {
    case uberBlack
    case uberWhite
    case blackHighlighted
    case whiteHighlighted
}

class ColorUtil {
    static func colorForUberButtonColor(_ color: UberButtonColor) -> UIColor {
        let hexCode = hexCodeFromColor(color)
        let scanner = Scanner(string: hexCode)
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        
        let redValue = CGFloat(Int(color >> 16)&mask)/255.0
        let greenValue = CGFloat(Int(color >> 8)&mask)/255.0
        let blueValue = CGFloat(Int(color)&mask)/255.0
        
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    fileprivate static func hexCodeFromColor(_ color: UberButtonColor) -> String {
        switch color {
        case .uberBlack:
            return "000000"
        case .uberWhite:
            return "FFFFFF"
        case .blackHighlighted:
            return "282727"
        case .whiteHighlighted:
            return "E5E5E4"
        }
    }
}

class FontUtil {
    static func loadFontWithName(_ name: String, familyName: String) -> Bool {
        if let path = Bundle(for: FontUtil.self).path(forResource: name, ofType: "otf") {
            if let inData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                var error: Unmanaged<CFError>?
                let cfdata = CFDataCreate(nil, (inData as NSData).bytes.bindMemory(to: UInt8.self, capacity: inData.count), inData.count)
                if let provider = CGDataProvider(data: cfdata!) {
                    if let font = CGFont(provider) as CGFont? {
                        if (CTFontManagerRegisterGraphicsFont(font, &error)) {
                            return true
                        }
                        print("Failed to load font with error: \(error)")
                    }
                }
            }
        }
        return false
    }
}

class LocalizationUtil {
    static func localizedString(forKey key: String, comment: String) -> String {
        var localizationBundle = Bundle(for: self)
        if let frameworkPath = Bundle.main.privateFrameworksPath, let frameworkBundle = Bundle(path: "\(frameworkPath)/UberRides.framework") {
            localizationBundle = frameworkBundle
        }
        return NSLocalizedString(key, bundle: localizationBundle, comment: comment)
    }
}

class OAuthUtil {
    
    static let ErrorKey = "error"
    
    /**
     Parses a URL returned from an authentication request to find the error described in the query parameters.
     
     - parameter url: the URL to be parsed, most likely from a webview.
     
     - returns: an NSError, who's code contains the RidesAuthenticationErrorType that occured. If none recognized, defaults to InvalidRequest.
     */
    static func parseAuthenticationErrorFromURL(_ url: URL) -> NSError {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let params = components.allItems() {
            for param in params {
                if param.name == "error" {
                    guard let rawValue = param.value, let error = RidesAuthenticationErrorFactory.createRidesAuthenticationError(rawValue: rawValue) else {
                        return RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest)
                    }
                    return error
                }
            }
        }
        return RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .invalidRequest)
    }
    
    static func parseRideWidgetErrorFromURL(_ url: URL) -> NSError {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let fragment = components.fragment {
            components.fragment = nil
            components.query = fragment
            for item in components.queryItems! where item.name == ErrorKey {
                if let value = item.value {
                    return RideRequestViewErrorFactory.errorForString(value)
                }
            }
        }
        
        return RideRequestViewErrorFactory.errorForType(.unknown)
    }
}

class RequestURLUtil {
    
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
    static let userAgentKey = "user-agent"
    
    static func buildRequestQueryParameters(_ rideParameters: RideParameters) -> [URLQueryItem] {
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: RequestURLUtil.actionKey, value: RequestURLUtil.setPickupValue))
        queryItems.append(URLQueryItem(name: RequestURLUtil.clientIDKey, value: Configuration.getClientID()))
        
        if let productID = rideParameters.productID {
            queryItems.append(URLQueryItem(name: RequestURLUtil.productIDKey, value: productID))
        }
        
        if let location = rideParameters.pickupLocation {
            queryItems.append(contentsOf: addLocation(LocationType.Pickup, location: location, nickname: rideParameters.pickupNickname, address: rideParameters.pickupAddress))
        } else {
            queryItems.append(URLQueryItem(name: LocationType.Pickup.rawValue, value: RequestURLUtil.currentLocationValue))
        }
        
        if let location = rideParameters.dropoffLocation {
            queryItems.append(contentsOf: addLocation(LocationType.Dropoff, location: location, nickname: rideParameters.dropoffNickname, address: rideParameters.dropoffAddress))
        }
        
        queryItems.append(URLQueryItem(name: RequestURLUtil.userAgentKey, value: rideParameters.userAgent))
        
        return queryItems
    }
    
    fileprivate static func addLocation(_ locationType: LocationType, location: CLLocation, nickname: String?, address: String?) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        let locationPrefix = locationType.rawValue
        let latitudeString = "\(location.coordinate.latitude)"
        let longitudeString = "\(location.coordinate.longitude)"
        queryItems.append(URLQueryItem(name: locationPrefix + RequestURLUtil.latitudeKey, value: latitudeString))
        queryItems.append(URLQueryItem(name: locationPrefix + RequestURLUtil.longitudeKey, value: longitudeString))
        if let nickname = nickname {
            queryItems.append(URLQueryItem(name: locationPrefix + RequestURLUtil.nicknameKey, value: nickname))
        }
        if let address = address {
            queryItems.append(URLQueryItem(name: locationPrefix + RequestURLUtil.formattedAddressKey, value: address))
        }
        
        return queryItems
    }
}

/**
 Extension for NSURLComponents to easily extract key value pairs from the fragment
 
 Adds functionality to extract key value pairs (as NSURLQueryItem) from the fragment
 Adds functionality to extract key value pairs (as NSURLQueryItem) from both fragment and query
 */
extension URLComponents
{
    /**
     Converts key value pairs in the fragment into NSURLQueryItems
     This is done by setting the query to the value of the fragment, calling .queryItems
     then restoring the original value of query
     - returns: An array of NSURLQueryItems, or nil if there was no fragment
     */
    mutating func fragmentItems() -> [URLQueryItem]?
    {
        objc_sync_enter(self)
        let holdQuery = self.query
        self.query = self.fragment
        let fragmentItems = self.queryItems
        self.query = holdQuery
        objc_sync_exit(self)
        return fragmentItems
    }
    
    /**
     Converts key value pairs in the fragment into NSURLQueryItems and appends them
     to the NSURLQuery items returned from .queryItems
     - returns: An array of NSURLQueryItems, or nil if there was no fragment and no query
     */
    mutating func allItems() -> [URLQueryItem]?
    {
        var finalItemArray = [URLQueryItem]()
        if let queryItems = self.queryItems {
            finalItemArray.append(contentsOf: queryItems)
        }
        if let fragmentItems = self.fragmentItems() {
            finalItemArray.append(contentsOf: fragmentItems)
        }
        guard finalItemArray.count > 0 else {
            return nil
        }
        return finalItemArray
    }
}
