//
//  UBRideEstimate.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import "UBRideEstimatePrice.h"
#import "UBRideEstimateTrip.h"

#import <Mantle.h>

/**
 Represents a ride estimate.
 */
@interface UBRideEstimate : MTLModel <MTLJSONSerializing>

/// Details of the estimated fare. If end location is omitted, only the minimum is returned.
@property (nonatomic, readonly) UBRideEstimatePrice *price;
/// Details of the estimated distance. null if end location is omitted.
@property (nonatomic, readonly) UBRideEstimateTrip *trip;
/// The estimated time of vehicle arrival in minutes. null if there are no cars available.
@property (nonatomic, readonly) NSNumber *pickupEstimate;

@end
