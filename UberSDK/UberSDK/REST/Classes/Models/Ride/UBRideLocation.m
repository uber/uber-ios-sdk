//
//  UBLocation.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRideLocation.h"

#import "UBUtils.h"

@implementation UBRideLocation

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRideLocation, latitude) : @"latitude",
              @instanceKeypath(UBRideLocation, longitude) : @"longitude",
              @instanceKeypath(UBRideLocation, bearing) : @"bearing"
              };
}

@end
