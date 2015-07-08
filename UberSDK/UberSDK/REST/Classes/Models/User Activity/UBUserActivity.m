//
//  UBTripHistory.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBUserActivity.h"

#import "UBUtils.h"

@implementation UBUserActivity

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBUserActivity, requestId) : @"request_id",
              @instanceKeypath(UBUserActivity, productId) : @"product_id",
              @instanceKeypath(UBUserActivity, status) : @"status",
              @instanceKeypath(UBUserActivity, distance) : @"distance",
              @instanceKeypath(UBUserActivity, startTime) : @"start_time",
              @instanceKeypath(UBUserActivity, endTime) : @"end_time",
              @instanceKeypath(UBUserActivity, requestTime) : @"request_time",
              @instanceKeypath(UBUserActivity, startCity) : @"start_city",
              };
}

+ (NSValueTransformer *)startCityJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:UBUserActivityCity.class];
}

@end
