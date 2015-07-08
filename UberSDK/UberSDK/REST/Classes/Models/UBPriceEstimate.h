//
//  UBPriceEstimate.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mantle.h>

/**
 Represents a price estimate for an Uber ride.
 */
@interface UBPriceEstimate : MTLModel <MTLJSONSerializing>

/**
 Unique identifier representing a specific product for a given latitude & longitude.
 For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles.
 */
@property (nonatomic, readonly) NSString *productId;
/// ISO 4217 currency code.
@property (nonatomic, readonly) NSString *currencyCode;
/// Display name of product.
@property (nonatomic, readonly) NSString *displayName;
/**
 Formatted string of estimate in local currency of the start location.
 Estimate could be a range, a single number (flat rate) or "Metered" for TAXI.
 */
@property (nonatomic, readonly) NSString *estimate;
/// Lower bound of the estimated price.
@property (nonatomic, readonly) NSNumber *lowEstimate;
/// Upper bound of the estimated price.
@property (nonatomic, readonly) NSNumber *highEstimate;
/**
 Expected surge multiplier. Surge is active if surge_multiplier is greater than 1.
 Price estimate already factors in the surge multiplier.
 */
@property (nonatomic, readonly) NSNumber *surgeMultiplier;
/// Expected activity duration (in seconds). Always show duration in minutes.
@property (nonatomic, readonly) NSNumber *duration;
/// Expected activity distance (in miles).
@property (nonatomic, readonly) NSNumber *distance;

@end
