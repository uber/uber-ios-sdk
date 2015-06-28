//
//  UBCity.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBUserActivityCity.h"

#import "UBUtils.h"

@implementation UBUserActivityCity

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBUserActivityCity, latitude) : @"latitude",
             @instanceKeypath(UBUserActivityCity, longitude) : @"longitude",
             @instanceKeypath(UBUserActivityCity, displayName) : @"display_name",
             };
}

@end
