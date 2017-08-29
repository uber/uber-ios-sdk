//
//  RideRequestLocation.swift
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

// MARK: RideRequestLocation

/**
 *  Location of a pickup or destination in a ride request.
 */
@objc(UBSDKRideRequestLocation) public class RideRequestLocation: NSObject, Codable {
    
    /// The current bearing in degrees for a moving location.
    @objc public private(set) var bearing: Int
    
    /// ETA is only available when the trips is accepted or arriving. -1 if not available.
    @objc public private(set) var eta: Int
    
    /// The latitude of the location.
    @objc public private(set) var latitude: Double
    
    /// The longitude of the location.
    @objc public private(set) var longitude: Double

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bearing = try container.decodeIfPresent(Int.self, forKey: .bearing) ?? 0
        eta = try container.decodeIfPresent(Int.self, forKey: .eta) ?? -1
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
    }
}
