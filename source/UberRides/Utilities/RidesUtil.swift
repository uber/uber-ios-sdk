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
    case UberBlack
    case UberWhite
    case BlackHighlighted
    case WhiteHighlighted
}

class ColorUtil {
    static func colorForUberButtonColor(color: UberButtonColor) -> UIColor {
        let hexCode = hexCodeFromColor(color)
        let scanner = NSScanner(string: hexCode)
        var color: UInt32 = 0
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        
        let redValue = CGFloat(Int(color >> 16)&mask)/255.0
        let greenValue = CGFloat(Int(color >> 8)&mask)/255.0
        let blueValue = CGFloat(Int(color)&mask)/255.0
        
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    private static func hexCodeFromColor(color: UberButtonColor) -> String {
        switch color {
        case .UberBlack:
            return "000000"
        case .UberWhite:
            return "FFFFFF"
        case .BlackHighlighted:
            return "282727"
        case .WhiteHighlighted:
            return "E5E5E4"
        }
    }
}

class FontUtil {
    static func loadFontWithName(name: String, familyName: String) -> Bool {
        if let path = NSBundle(forClass: FontUtil.self).pathForResource(name, ofType: "otf") {
            if let inData = NSData(contentsOfFile: path) {
                var error: Unmanaged<CFError>?
                let cfdata = CFDataCreate(nil, UnsafePointer<UInt8>(inData.bytes), inData.length)
                if let provider = CGDataProviderCreateWithCFData(cfdata) {
                    let font = CGFontCreateWithDataProvider(provider)
                    if (CTFontManagerRegisterGraphicsFont(font, &error)) {
                        return true
                    } else {
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
        var localizationBundle = NSBundle(forClass: self)
        if let frameworkPath = NSBundle.mainBundle().privateFrameworksPath, let frameworkBundle = NSBundle(path: "\(frameworkPath)/UberRides.framework") {
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
    static func parseAuthenticationErrorFromURL(url: NSURL) -> NSError {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
        if let params = components.allItems() {
            for param in params {
                if param.name == "error" {
                    guard let rawValue = param.value, let error = RidesAuthenticationErrorFactory.createRidesAuthenticationError(rawValue: rawValue) else {
                        return RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .InvalidRequest)
                    }
                    return error
                }
            }
        }
        return RidesAuthenticationErrorFactory.errorForType(ridesAuthenticationErrorType: .InvalidRequest)
    }
    
    static func parseRideWidgetErrorFromURL(url: NSURL) -> NSError {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
        if let fragment = components.fragment {
            components.fragment = nil
            components.query = fragment
            for item in components.queryItems! where item.name == ErrorKey {
                if let value = item.value {
                    return RideRequestViewErrorFactory.errorForString(value)
                }
            }
        }
        
        return RideRequestViewErrorFactory.errorForType(.Unknown)
    }
}

class RequestURLUtil {
    
    private enum LocationType: String {
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
    
    static func buildRequestQueryParameters(rideParameters: RideParameters) -> [NSURLQueryItem] {
        
        var queryItems = [NSURLQueryItem]()
        queryItems.append(NSURLQueryItem(name: RequestURLUtil.actionKey, value: RequestURLUtil.setPickupValue))
        queryItems.append(NSURLQueryItem(name: RequestURLUtil.clientIDKey, value: Configuration.getClientID()))
        
        if let productID = rideParameters.productID {
            queryItems.append(NSURLQueryItem(name: RequestURLUtil.productIDKey, value: productID))
        }
        
        if let location = rideParameters.pickupLocation {
            queryItems.appendContentsOf(addLocation(LocationType.Pickup, location: location, nickname: rideParameters.pickupNickname, address: rideParameters.pickupAddress))
        } else {
            queryItems.append(NSURLQueryItem(name: LocationType.Pickup.rawValue, value: RequestURLUtil.currentLocationValue))
        }
        
        if let location = rideParameters.dropoffLocation {
            queryItems.appendContentsOf(addLocation(LocationType.Dropoff, location: location, nickname: rideParameters.dropoffNickname, address: rideParameters.dropoffAddress))
        }
        
        queryItems.append(NSURLQueryItem(name: RequestURLUtil.userAgentKey, value: rideParameters.userAgent))
        
        return queryItems
    }
    
    private static func addLocation(locationType: LocationType, location: CLLocation, nickname: String?, address: String?) -> [NSURLQueryItem] {
        var queryItems = [NSURLQueryItem]()
        
        let locationPrefix = locationType.rawValue
        let latitudeString = "\(location.coordinate.latitude)"
        let longitudeString = "\(location.coordinate.longitude)"
        queryItems.append(NSURLQueryItem(name: locationPrefix + RequestURLUtil.latitudeKey, value: latitudeString))
        queryItems.append(NSURLQueryItem(name: locationPrefix + RequestURLUtil.longitudeKey, value: longitudeString))
        if let nickname = nickname {
            queryItems.append(NSURLQueryItem(name: locationPrefix + RequestURLUtil.nicknameKey, value: nickname))
        }
        if let address = address {
            queryItems.append(NSURLQueryItem(name: locationPrefix + RequestURLUtil.formattedAddressKey, value: address))
        }
        
        return queryItems
    }
}

/**
 Extension for NSURLComponents to easily extract key value pairs from the fragment
 
 Adds functionality to extract key value pairs (as NSURLQueryItem) from the fragment
 Adds functionality to extract key value pairs (as NSURLQueryItem) from both fragment and query
 */
extension NSURLComponents
{
    /**
     Converts key value pairs in the fragment into NSURLQueryItems
     This is done by setting the query to the value of the fragment, calling .queryItems
     then restoring the original value of query
     - returns: An array of NSURLQueryItems, or nil if there was no fragment
     */
    func fragmentItems() -> [NSURLQueryItem]?
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
    func allItems() -> [NSURLQueryItem]?
    {
        var finalItemArray = [NSURLQueryItem]()
        if let queryItems = self.queryItems {
            finalItemArray.appendContentsOf(queryItems)
        }
        if let fragmentItems = self.fragmentItems() {
            finalItemArray.appendContentsOf(fragmentItems)
        }
        guard finalItemArray.count > 0 else {
            return nil
        }
        return finalItemArray
    }
}
