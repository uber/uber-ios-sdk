//
//  UBUserProfile.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents a profile of an Uber user.
 */
@interface UBUserProfile : MTLModel <MTLJSONSerializing>

/// Unique identifier of the Uber user.
@property (nonatomic, readonly) NSString *uuid;
/// First name of the Uber user.
@property (nonatomic, readonly) NSString *firstName;
/// Last name of the Uber user.
@property (nonatomic, readonly) NSString *lastName;
/// Email address of the Uber user.
@property (nonatomic, readonly) NSString *email;
/// Image URL of the Uber user.
@property (nonatomic, readonly) NSURL *pictureURL;
/// Promo code of the Uber user.
@property (nonatomic, readonly) NSString *promoCode;

@end

