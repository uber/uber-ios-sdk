//
//  UBPriceDetail.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mantle.h>

/**
 Represents price detail for a UBProduct.
 */
@interface UBProductPriceDetail : MTLModel <MTLJSONSerializing>

/// The unit of distance used to calculate the fare (either mile or km).
@property (nonatomic, readonly) NSString *distanceUnit;
/// ISO 4217 currency code.
@property (nonatomic, readonly) NSString *currencyCode;
/// The minimum price of a trip.
@property (nonatomic, readonly) NSNumber *minimum;
/// The base price.
@property (nonatomic, readonly) NSNumber *base;
/// The charge per minute (if applicable for the product type).
@property (nonatomic, readonly) NSNumber *costPerMinute;
/// The charge per distance unit (if applicable for the product type).
@property (nonatomic, readonly) NSNumber *costPerDistance;
/// The fee if a rider cancels the trip after the grace period.
@property (nonatomic, readonly) NSNumber *cancellationFee;
/// Array containing additional fees added to the price of a product.
@property (nonatomic, readonly) NSArray *serviceFees;

@end
