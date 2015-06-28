//
//  UBLocation.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents a location in the UBRide object.
 */
@interface UBRideLocation : MTLModel <MTLJSONSerializing>

/// The current latitude of the vehicle.
@property (nonatomic, readonly) NSNumber *latitude;
/// The current longitude of the vehicle.
@property (nonatomic, readonly) NSNumber *longitude;
/// The current bearing of the vehicle in degrees (0-359).
@property (nonatomic, readonly) NSNumber *bearing;

@end
