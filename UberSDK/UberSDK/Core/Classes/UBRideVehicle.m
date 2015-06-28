//
//  UBVehicle.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRideVehicle.h"

#import "UBUtils.h"

@implementation UBRideVehicle

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRideVehicle, make) : @"make",
              @instanceKeypath(UBRideVehicle, model) : @"model",
              @instanceKeypath(UBRideVehicle, licensePlate) : @"license_plate",
              @instanceKeypath(UBRideVehicle, pictureURL) : @"picture_url"
              };
}

+ (NSValueTransformer *)pictureURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
