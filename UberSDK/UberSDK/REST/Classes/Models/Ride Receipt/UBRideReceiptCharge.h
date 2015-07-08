//
//  UBCharge.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents a charge in the UBRideReceipt object.
 */
@interface UBRideReceiptCharge : MTLModel <MTLJSONSerializing>

/// The name of the charge.
@property (nonatomic, readonly) NSString *name;
/// The type of the charge.
@property (nonatomic, readonly) NSString *type;
/// The amount of the charge.
@property (nonatomic, readonly) NSString *amount;

@end
