//
//  UBTimeEstimate.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBTimeEstimate.h"

#import "UBUtils.h"

@implementation UBTimeEstimate

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBTimeEstimate, productId) : @"product_id",
             @instanceKeypath(UBTimeEstimate, displayName) : @"display_name",
             @instanceKeypath(UBTimeEstimate, estimate) : @"estimate"
             };
}

@end
