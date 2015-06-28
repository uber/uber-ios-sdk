//
//  UBDriver.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents a driver in the UBRide object.
 */
@interface UBRideDriver : MTLModel <MTLJSONSerializing>

/// The first name of the driver.
@property (nonatomic, readonly) NSString *name;
/// The driver's star rating out of 5 stars.
@property (nonatomic, readonly) NSNumber *rating;
/// The formatted phone number for contacting the driver.
@property (nonatomic, readonly) NSString *phoneNumber;
/// The URL to the photo of the driver.
@property (nonatomic, readonly) NSURL *pictureURL;

@end
