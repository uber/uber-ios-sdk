//
//  UberAPIClient.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "UBUtils.h"

@class UBOAuthToken;
@class UBPromotion;
@class UBUserProfile;
@class UBRide;
@class UBSurgeConfirmation;
@class UBRideEstimate;
@class UBRideReceipt;

typedef void (^OAuthauthorizationBlock)(BOOL success, NSError *error);

@interface UberAPIClient : NSObject

@property (nonatomic, readonly) NSURLSession *session;

@property (nonatomic, readonly) NSString *serverToken;
@property (nonatomic, readonly) UBOAuthToken *oauthToken;

/**
 Initialize client with a server token.
 You can get your token here: https://developer.uber.com/
 
 @param Uber server token
 @return An instance of the Uber client for the specified token, or nil of an invalid token is supplied.
 */
- (id)initWithServerToken:(NSString *)serverToken;

/**
 Initialize client with a UBOAuthToken object.
 
 @param oauthToken Uber access token
 @return An instance of the Uber client for the specified OAuth token, or nil of an invalid token is supplied.
 */
- (id)initWithOAuthToken:(UBOAuthToken *)oauthToken;

/**
 Initialize client with an OAuth access token.
 
 Note, clients instantiated in this way (as opposed to initWithOAuthToken:) will not perform an automatic token refresh.
 You can get your token here: https://developer.uber.com/
 
 @param accessToken OAuth access token
 @return An instance of the Uber client for the specified OAuth token, or nil of an invalid token is supplied.
 */
- (id)initWithAccessToken:(NSString *)accessToken;

/**
 Returns state of sandbox mode.
 
 @return YES if in currently in sandbox mode, NO otherwise
 */
+ (BOOL)isSandbox;

/**
 Sets state of sandbox mode.
 
 @param sandbox set to YES to enable sandbox mode, NO for production mode
 */
+ (void)sandbox:(BOOL)sandbox;

/**
 Returns a list of Uber products at the specified location. (Uber Black, UberX, UberChopper etc.)
 
 @param coordinate The location for the available product listing.
 @param completion The completion handler to call when the load request is complete. Returns a list of UBProduct objects or the appropriate error if the request failed.
 */
- (void)productsWithCoordinate:(CLLocationCoordinate2D)coordinate
                    completion:(void (^)(NSArray *products, NSError *error))completion;

/**
 Returns a list of Uber price estimates for the specified route.
 
 @param startCoordinate Start of the route.
 @param endCoordinate End of the route.
 @param completion The completion handler to call when the load request is complete. Returns a list of UBPriceEstimate objects or the appropriate error if the request failed.
 */
- (void)priceEstimatesWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                            endCoordinate:(CLLocationCoordinate2D)endCoordinate
                               completion:(void (^)(NSArray *priceEstimates, NSError *error))completion;

/**
 Returns a list of estimated ETAs for specific Uber products.
 
 @param startCoordinate Desired pickup location.
 @param completion The completion handler to call when the load request is complete. Returns a list of UBTimeEstimate objects or the appropriate error if the request failed.
 */
- (void)timeEstimatesWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                              completion:(void (^)(NSArray *timeEstimates, NSError *error))completion;

/**
 Returns the active promotion (if any) at the specified route.
 
 @param startCoordinate Start of the route.
 @param endCoordinate End of the route;
 @param completion The completion handler to call when the load request is complete. Returns a UBPromotion object or the appropriate error if the request failed.
 */
- (void)promotionWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                       endCoordinate:(CLLocationCoordinate2D)endCoordinate
                          completion:(void (^)(UBPromotion *promotion, NSError *error))completion;

/**
 Returns the user's ride activity.
 
 @param offset Offset the list of returned results by this amount. Default is zero.
 @param end Number of items to retrieve. Default is 5, maximum is 50.
 @param completion The completion handler to call when the load request is complete. Returns a list of UBUserActivity objects or the appropriate error if the request failed.
 */
- (void)userActivityWithOffset:(NSInteger)offset
                         limit:(NSInteger)limit
                    completion:(void (^)(NSArray *userActivities,
                                         NSInteger offset,
                                         NSInteger limit,
                                         NSInteger count,
                                         NSError *error))completion;

/**
 Returns the user's profile.
 
 @param completion The completion handler to call when the load request is complete. Returns a UBUserProfile object or the appropriate error if the request failed.
 */
- (void)userProfile:(void (^)(UBUserProfile *userProfile, NSError *error))completion;

/**
 Requests a product with a specific id.
 
 @param productId product id of the desired product
 @param startCoordinate pickup location
 @param endCoordinate dropoff location
 @param surgeConfirmationId required to confirm a surge screen
 @param completion The completion handler to call when the load request is complete. Returns a UBRide object or the appropriate error if the request failed. Also returns a UBSurgeConfirmation object if surge confirmation is required.
 */
- (void)requestRideWithProductId:(NSString *)productId
                 startCoordinate:(CLLocationCoordinate2D)startCoordinate
                   endCoordinate:(CLLocationCoordinate2D)endCoordinate
             surgeConfirmationId:(NSString *)surgeConfirmationId
                      completion:(void (^)(UBRide *ride, UBSurgeConfirmation *surgeConfirmation, NSError *error))completion;

/**
 Returns details about the specified request
 
 @param requestId request id
 @param completion The completion handler to call when the load request is complete. Returns a UBRide object or the appropriate error if the request failed.
 */
- (void)rideDetailsWithRequestId:(NSString *)requestId
                      completion:(void (^)(UBRide *ride, NSError *error))completion;

/**
 Provides a cost and distance estimate for the specified product.
 
 @param productId product id of the desired product
 @param startCoordinate pickup location
 @param endCoordinate dropoff location
 @param completion The completion handler to call when the load request is complete. Returns a UBRideEstimate object or the appropriate error if the request failed.
 */
- (void)requestEstimateWithProductId:(NSString *)productId
                     startCoordinate:(CLLocationCoordinate2D)start
                       endCoordinate:(CLLocationCoordinate2D)end
                          completion:(void (^)(UBRideEstimate *estimate, NSError *error))completion;

/**
 Cancel the specified request.
 
 @param requestId request id
 @param completion The completion handler to call when the load request is complete. Returns an NSError object if an error has occured, or nil
    if request was sucessfull.
 */
- (void)cancelRideWithRequestId:(NSString *)requestId completion:(void (^)(NSError *error))completion;

/**
 Returns a URL to a map for the specified ride.
 
 @param requestId request id
 @param completion The completion handler to call when the load request is complete. Returns an NSURL object for the map or the appropriate error if the request failed.
 */
- (void)rideMapWithRequestId:(NSString *)requestId completion:(void (^)(NSURL *rideMapURL, NSError *error))completion;

/**
 Returns a URL receipt for the specified ride.
 
 @param requestId request id
 @param completion The completion handler to call when the load request is complete. Returns an UBReceipt object for the map or the appropriate error if the request failed.
 */
- (void)rideReceiptWithRequestId:(NSString *)requestId completion:(void (^)(UBRideReceipt *receipt, NSError *error))completion;

#pragma mark - Sandbox

/**
 Sandbox-only.
 
 Modifies the state of the specified request.
 
 @param requestId request id
 @param completion The completion handler to call when the load request is complete. Returns an NSError object if an error has occured, or nil
 if request was sucessfull.
 */
- (void)updateSandboxRideWithRequestId:(NSString *)requestId status:(NSString *)status completion:(void (^)(NSError *error))completion;

/**
 Sandbox-only.
 
 Modifies the driver avaibility or surge rate for the specified product.
 
 @param productId product id
 @param driversAvailable desired driver availibility
 @param surge desired surge rate
 @param completion The completion handler to call when the load request is complete. Returns an NSError object if an error has occured, or nil
 if request was sucessfull.
 */
- (void)updateSandboxProductWithProductId:(NSString *)productId
                         driversAvailable:(BOOL)driversAvailable
                                    surge:(double)surge
                               completion:(void (^)(NSError *error))completion;


@end
