//
//  UBRideEstimateTrip.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRideEstimateTrip.h"

#import "UBUtils.h"

@implementation UBRideEstimateTrip

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRideEstimateTrip, distanceUnit) : @"distance_unit",
              @instanceKeypath(UBRideEstimateTrip, durationEstimate) : @"duration_estimate",
              @instanceKeypath(UBRideEstimateTrip, distanceEstimate) : @"distance_estimate"
              };
}

@end
