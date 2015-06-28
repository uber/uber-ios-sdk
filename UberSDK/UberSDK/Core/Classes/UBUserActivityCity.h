//
//  UBCity.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import <Mantle.h>

/**
 Represents a city in user's activity.
 */
@interface UBUserActivityCity : MTLModel <MTLJSONSerializing>

/// Latitude of the center of the start_city.
@property (nonatomic, readonly) NSNumber *latitude;
/// Longitude of the center of the start_city.
@property (nonatomic, readonly) NSNumber *longitude;
/// The name of the start_city
@property (nonatomic, readonly) NSString *displayName;

@end

