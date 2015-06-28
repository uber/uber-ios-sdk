//
//  UBRide.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import "UBRideDriver.h"
#import "UBRideVehicle.h"
#import "UBRideLocation.h"

#import <Mantle.h>

/**
 Represents an Uber ride (trip).
 */
@interface UBRide : MTLModel <MTLJSONSerializing>

/// The unique ID of the Request.
@property (nonatomic, readonly) NSString *requestId;
/// The status of the Request indicating state.
@property (nonatomic, readonly) NSString *status;
/// The estimated time of vehicle arrival in minutes.
@property (nonatomic, readonly) NSNumber *eta;
/**
 The surge pricing multiplier used to calculate the increased price of a Request.
 A multiplier of 1.0 means surge pricing is not in effect.
 */
@property (nonatomic, readonly) NSNumber *surgeMultiplier;
/// The object that contains driver details.
@property (nonatomic, readonly) UBRideDriver *driver;
/// The object that contains vehicle details.
@property (nonatomic, readonly) UBRideVehicle *vehicle;
/// The object that contains the location information of the vehicle and driver.
@property (nonatomic, readonly) UBRideLocation *location;

@end
