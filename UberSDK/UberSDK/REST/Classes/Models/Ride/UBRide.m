//
//  UBRequest.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRide.h"

#import "UBUtils.h"

@implementation UBRide

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRide, requestId) : @"request_id",
              @instanceKeypath(UBRide, status) : @"status",
              @instanceKeypath(UBRide, eta) : @"eta",
              @instanceKeypath(UBRide, surgeMultiplier) : @"surge_multiplier",
              @instanceKeypath(UBRide, driver) : @"driver",
              @instanceKeypath(UBRide, vehicle) : @"vehicle",
              @instanceKeypath(UBRide, location) : @"location"
              };
}

+ (NSValueTransformer *)driverJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:UBRideDriver.class];
}

+ (NSValueTransformer *)vehicleJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:UBRideVehicle.class];
}

+ (NSValueTransformer *)locationJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:UBRideLocation.class];
}

@end
