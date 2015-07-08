//
//  UBVehicle.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents a vehicle in the UBRide object.
 */
@interface UBRideVehicle : MTLModel <MTLJSONSerializing>

/// The vehicle make or brand.
@property (nonatomic, readonly) NSString *make;
/// The vehicle model or type.
@property (nonatomic, readonly) NSString *model;
/// The license plate number of the vehicle.
@property (nonatomic, readonly) NSString *licensePlate;
/// The URL to a stock photo of the vehicle (may be null).
@property (nonatomic, readonly) NSURL *pictureURL;

@end
