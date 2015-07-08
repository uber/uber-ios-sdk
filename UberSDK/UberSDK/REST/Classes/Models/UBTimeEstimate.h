//
//  UBTimeEstimate.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mantle.h>

/**
 Represents a time estimate for an Uber ride.
 */
@interface UBTimeEstimate : MTLModel <MTLJSONSerializing>

/**
 Unique identifier representing a specific product for a given latitude & longitude.
 For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles.
 */
@property (nonatomic, readonly) NSString *productId;
/// Display name of product.
@property (nonatomic, readonly) NSString *displayName;
/// ETA for the product (in seconds). Always show estimate in minutes.
@property (nonatomic, readonly) NSNumber *estimate;

@end
