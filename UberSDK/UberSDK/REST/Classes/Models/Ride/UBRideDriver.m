//
//  UBDriver.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRideDriver.h"

#import "UBUtils.h"

@implementation UBRideDriver

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRideDriver, name) : @"name",
              @instanceKeypath(UBRideDriver, rating) : @"rating",
              @instanceKeypath(UBRideDriver, phoneNumber) : @"phone_number",
              @instanceKeypath(UBRideDriver, pictureURL) : @"picture_url"
              };
}

+ (NSValueTransformer *)pictureURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
