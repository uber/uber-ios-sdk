//
//  UBSurgeConfirmation.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBSurgeConfirmation.h"

#import "UBUtils.h"

@implementation UBSurgeConfirmation

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBSurgeConfirmation, confirmationURL) : @"href",
              @instanceKeypath(UBSurgeConfirmation, confirmationId) : @"surge_confirmation_id"
              };
}

+ (NSValueTransformer *)confirmationURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}


@end
