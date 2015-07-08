//
//  UBServiceFee.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mantle.h>

/**
 Represents a service fee for a UBProductPriceDetail.
 */
@interface UBPriceDetailServiceFee : MTLModel <MTLJSONSerializing>

/// The name of the service fee.
@property (nonatomic, readonly) NSString *name;
/// The amount of the service fee.
@property (nonatomic, readonly) NSNumber *fee;

@end
