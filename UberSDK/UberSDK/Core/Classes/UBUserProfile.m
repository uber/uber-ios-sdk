//
//  UBUserProfile.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBUserProfile.h"

#import "UBUtils.h"

@implementation UBUserProfile

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBUserProfile, uuid) : @"uuid",
              @instanceKeypath(UBUserProfile, firstName) : @"first_name",
              @instanceKeypath(UBUserProfile, lastName) : @"last_name",
              @instanceKeypath(UBUserProfile, email) : @"email",
              @instanceKeypath(UBUserProfile, pictureURL) : @"picture",
              @instanceKeypath(UBUserProfile, promoCode) : @"promo_code",
              };
}

+ (NSValueTransformer *)pictureURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
