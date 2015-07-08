//
//  UBCharge.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRideReceiptCharge.h"

#import "UBUtils.h"

@implementation UBRideReceiptCharge

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRideReceiptCharge, name) : @"name",
              @instanceKeypath(UBRideReceiptCharge, type) : @"type",
              @instanceKeypath(UBRideReceiptCharge, amount) : @"amount"
              };
}

@end
