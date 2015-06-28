//
//  UBReceipt.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import "UBRideReceiptCharge.h"

#import <Mantle.h>

/**
 Represents an Uber receipt for a ride.
 */
@interface UBRideReceipt : MTLModel <MTLJSONSerializing>

/// Unique identifier representing a Request.
@property (nonatomic, readonly) NSString *requestId;
/// Describes the charges made against the rider.
@property (nonatomic, readonly) NSArray *charges;
/// Adjustments made to the charges such as promotions, and fees.
@property (nonatomic, readonly) NSArray *chargeAdjustments;
/// Describes the surge charge. May be null if surge pricing was not in effect.
@property (nonatomic, readonly) UBRideReceiptCharge *surgeCharge;
/// The summation of the charges.
@property (nonatomic, readonly) NSString *normalFare;
/// The summation of the normal_fare and surge_charge.
@property (nonatomic, readonly) NSString *subtotal;
/**
 The total amount charged to the users payment method.
 This is the the subtotal (split if applicable) with taxes included.
 */
@property (nonatomic, readonly) NSString *totalCharged;
/**
 The total amount still owed after attempting to charge the user.
 May be null if amount was paid in full.
 */
@property (nonatomic, readonly) NSString *totalOwed;
/// ISO 4217
@property (nonatomic, readonly) NSString *currencyCode;
/// Time duration of the trip in ISO 8061 HH:MM:SS format.
@property (nonatomic, readonly) NSString *duration;
/// Distance of the trip charged.
@property (nonatomic, readonly) NSString *distance;
/// The localized unit of distance.
@property (nonatomic, readonly) NSString *distanceLabel;

@end
