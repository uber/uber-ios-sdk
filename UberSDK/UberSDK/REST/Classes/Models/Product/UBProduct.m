//
//  UBProduct.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBProduct.h"
#import "UBUtils.h"

@implementation UBProduct

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBProduct, productId) : @"product_id",
             @instanceKeypath(UBProduct, displayName) : @"display_name",
             @instanceKeypath(UBProduct, productDescription) : @"description",
             @instanceKeypath(UBProduct, imageURL) : @"image",
             @instanceKeypath(UBProduct, capacity) : @"capacity",
             @instanceKeypath(UBProduct, priceDetail) : @"price_details",
             };
}

+ (NSValueTransformer *)imageURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)priceDetailJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:UBProductPriceDetail.class];
}

@end
