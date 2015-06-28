//
//  UBUserActivity.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "MTLModel.h"

#import "UBUserActivityCity.h"

#import <Mantle.h>

/**
 Represents a user's (trip) activity.
 */
@interface UBUserActivity : MTLModel <MTLJSONSerializing>

/// Unique activity identifier.
@property (nonatomic, readonly) NSString *requestId;
/**
 Unique identifier representing a specific product for a given latitude & longitude.
 For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles.
 */
@property (nonatomic, readonly) NSString *productId;
/// Status of the activity. Only returns completed for now.
@property (nonatomic, readonly) NSString *status;
/// Length of activity in miles.
@property (nonatomic, readonly) NSNumber *distance;
/// Unix timestamp of activity start time.
@property (nonatomic, readonly) NSNumber *startTime;
/// Unix timestamp of activity end time.
@property (nonatomic, readonly) NSNumber *endTime;
/// Unix timestamp of activity request time.
@property (nonatomic, readonly) NSNumber *requestTime;
/// Details about the city the activity started in.
@property (nonatomic, readonly) UBUserActivityCity *startCity;

@end

