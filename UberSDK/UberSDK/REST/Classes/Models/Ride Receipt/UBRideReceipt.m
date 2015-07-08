//
//  UBReceipt.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRideReceipt.h"

#import "UBUtils.h"

@implementation UBRideReceipt

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRideReceipt, requestId) : @"request_id",
              @instanceKeypath(UBRideReceipt, charges) : @"charges",
              @instanceKeypath(UBRideReceipt, chargeAdjustments) : @"charge_adjustments",
              @instanceKeypath(UBRideReceipt, surgeCharge) : @"surge_charge",
              @instanceKeypath(UBRideReceipt, normalFare) : @"normal_fare",
              @instanceKeypath(UBRideReceipt, subtotal) : @"subtotal",
              @instanceKeypath(UBRideReceipt, totalCharged) : @"total_charged",
              @instanceKeypath(UBRideReceipt, currencyCode) : @"currency_code",
              @instanceKeypath(UBRideReceipt, duration) : @"duration",
              @instanceKeypath(UBRideReceipt, distance) : @"distance",
              @instanceKeypath(UBRideReceipt, distanceLabel) : @"distance_label",
              };
}

+ (NSValueTransformer *)surgeChargeJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:UBRideReceiptCharge.class];
}

+ (NSValueTransformer *)chargesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:UBRideReceiptCharge.class];
}

+ (NSValueTransformer *)chargeAdjustmentsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:UBRideReceiptCharge.class];
}

@end
