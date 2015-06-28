//
//  UBSurgeConfirmation.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents an surge confirmation.
 */
@interface UBSurgeConfirmation : MTLModel <MTLJSONSerializing>

/// The URL a user must visit to accept surge pricing.
@property (nonatomic, readonly) NSURL *confirmationURL;
/// The surge confirmation identifier used to make a Request after a user has accepted surge pricing.
@property (nonatomic, readonly) NSString *confirmationId;

@end
