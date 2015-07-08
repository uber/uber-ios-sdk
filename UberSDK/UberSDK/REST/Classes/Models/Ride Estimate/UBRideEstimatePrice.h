//
//  UBRideEstimatePrice.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents the price in the UBRideEstimate object.
 */
@interface UBRideEstimatePrice : MTLModel <MTLJSONSerializing>

/// The URL a user must visit to accept surge pricing.
@property (nonatomic, readonly) NSURL *surgeConfirmationURL;
/// The unique identifier of the surge session for a user. null if no surge is currently in effect.
@property (nonatomic, readonly) NSString *surgeConfirmationId;
/**
 Expected surge multiplier. Surge is active if surge_multiplier is greater than 1.
 Fare estimates below factor in the surge multiplier.
 */
@property (nonatomic, readonly) NSNumber *surgeMultiplier;
/// Upper bound of the estimated price.
@property (nonatomic, readonly) NSNumber *highEstimate;
/// Lower bound of the estimated price.
@property (nonatomic, readonly) NSNumber *lowEstimate;
/// The minimum fare of a trip. Should only be displayed or used if no end location is provided.
@property (nonatomic, readonly) NSNumber *minimum;
/**
 Formatted string of estimate in local currency of the start location.
 Estimate could be a range, a single number (flat rate) or "Metered" for TAXI.
 */
@property (nonatomic, readonly) NSString *display;
/// ISO 4217 currency code.
@property (nonatomic, readonly) NSString *currencyCode;

@end
