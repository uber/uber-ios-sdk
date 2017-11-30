//
//  DistanceEstimate.swift
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

// MARK: DistanceEstimate

import UberCore

/**
 *  Estimate information on an Uber trip.
 */
@objc(UBSDKDistanceEstimate) public class DistanceEstimate: NSObject, Codable {
    
    /// Expected activity distance.
    @nonobjc public private(set) var distance: Double?

    /// Expected activity distance.
    @objc(distance) public var objc_distance: NSNumber? {
        if let distance = distance {
            return NSNumber(value: distance)
        } else {
            return nil
        }
    }
    
    /// The unit of distance (mile or km).
    @objc public private(set) var distanceUnit: String?

    /// Expected activity duration (in seconds).
    @nonobjc public private(set) var duration: Int?

    /// Expected activity duration (in seconds).
    @objc(duration) public var objc_duration: NSNumber? {
        if let duration = duration {
            return NSNumber(value: duration)
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case distance        = "distance_estimate"
        case distanceUnit    = "distance_unit"
        case duration        = "duration_estimate"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        distanceUnit = try container.decodeIfPresent(String.self, forKey: .distanceUnit)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
    }
}
