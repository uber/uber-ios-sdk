//
//  UBRideEstimateTrip.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents the trip in the UBRideEstimate object.
 */
@interface UBRideEstimateTrip : MTLModel <MTLJSONSerializing>

/// Expected activity distance.
@property (nonatomic, readonly) NSString *distanceUnit;
/// Expected activity duration (in minutes).
@property (nonatomic, readonly) NSNumber *durationEstimate;
/// The unit of distance (mile or km).
@property (nonatomic, readonly) NSNumber *distanceEstimate;

@end
