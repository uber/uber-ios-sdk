//
//  UBPromotion.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mantle.h>

/**
 Represents an Uber promotion in the specified region.
 */
@interface UBPromotion : MTLModel <MTLJSONSerializing>

/// A localized string we recommend to use when offering the promotion to users.
@property (nonatomic, readonly) NSString *displayText;
/// The value of the promotion that is available to a user in this location in the local currency.
@property (nonatomic, readonly) NSString *localizedValue;
/// The type of the promo which is either "trip_credit" or "account_credit".
@property (nonatomic, readonly) NSString *type;

@end
