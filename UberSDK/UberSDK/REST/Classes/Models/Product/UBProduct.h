//
//  UBProduct.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mantle.h>

#import "UBProductPriceDetail.h"

/**
 Represents Uber products offered at a given location.
 */
@interface UBProduct : MTLModel <MTLJSONSerializing>

/**
 Unique identifier representing a specific product for a given latitude & longitude.
 For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles.
 */
@property (nonatomic, readonly) NSString *productId;
/// Display name of product.
@property (nonatomic, readonly) NSString *displayName;
/// Description of product.
@property (nonatomic, readonly) NSString *productDescription;
/// Image URL representing the product.
@property (nonatomic, readonly) NSURL *imageURL;
/// Capacity of product. For example, 4 people.
@property (nonatomic, readonly) NSNumber *capacity;
/** The basic price details (not including any surge pricing adjustments).
 If null, the price is a metered fare such as a taxi service.
 */
@property (nonatomic, readonly) UBProductPriceDetail *priceDetail;

@end
