//
//  RideStatus.swift
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

// MARK: RideStatus

/**
 The status of a ride.
 
 - Accepted:           The request was accepted by a driver and "en route" to start location.
 - Arriving:           The driver has arrived or will be shortly.
 - Completed:          Ride has been completed.
 - DriverCanceled:     Ride request has been canceled by the driver.
 - InProgress:         The ride is "en route" from the start location to the end location.
 - NoDriversAvailable: The ride request was unfulfilled because no drivers were available.
 - Processing:         The ride request is matching to the best available driver.
 - RiderCanceled:      The ride request was canceled by rider.
 - Unknown:            An unexpected status.
 */
@objc(UBSDKRideStatus) public enum RideStatus: Int, Codable {
    case accepted
    case arriving
    case completed
    case driverCanceled
    case inProgress
    case noDriversAvailable
    case processing
    case riderCanceled
    case unknown

    public init(from decoder: Decoder) throws {
        let string = try decoder.singleValueContainer().decode(String.self).lowercased()
        switch string {
        case "accepted":
            self = .accepted
        case "arriving":
            self = .arriving
        case "completed":
            self = .completed
        case "driver_canceled":
            self = .driverCanceled
        case "in_progress":
            self = .inProgress
        case "no_drivers_available":
            self = .noDriversAvailable
        case "processing":
            self = .processing
        case "rider_canceled":
            self = .riderCanceled
        default:
            self = .unknown
        }
    }
}
