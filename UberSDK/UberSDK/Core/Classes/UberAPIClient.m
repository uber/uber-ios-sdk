//
//  UBClient.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UberAPIClient.h"

#import "UBOAuthToken.h"
#import "UBPromotion.h"
#import "UBUserProfile.h"
#import "UBRide.h"
#import "UBSurgeConfirmation.h"
#import "UBRideEstimate.h"
#import "UBRideReceipt.h"
#import "UBProduct.h"
#import "UBPriceEstimate.h"
#import "UBTimeEstimate.h"
#import "UBUserActivity.h"
#import "UBUtils.h"

#import <UIKit/UIKit.h>

NSString *const UberSDKVersion = @"1.0.0";

NSString *const UBClientErrorDomain = @"UBClientErrorDomain";

NSString *const UBAPIHostProduction = @"https://api.uber.com";
NSString *const UBAPIHostSandbox = @"https://sandbox-api.uber.com";

static BOOL _isSandbox = YES;

@interface UberAPIClient ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) UBOAuthToken *oauthToken;

@end

@implementation UberAPIClient

#pragma mark - Initialization

- (id)initWithServerToken:(NSString *)serverToken
{
    NSParameterAssert(serverToken.length);
    
    self = [super init];
    if (self) {
        _serverToken = serverToken;
        _session = [self sessionWithServerToken:_serverToken];
    }
    
    return self;
}

- (id)initWithOAuthToken:(UBOAuthToken *)oauthToken
{
    NSParameterAssert(oauthToken.accessToken.length);
    
    self = [super init];
    if (self) {
        _oauthToken = oauthToken;
        _session = [self sessionWithAccessToken:_oauthToken.accessToken];
    }
    
    return self;
}

- (id)initWithAccessToken:(NSString *)accessToken
{
    UBOAuthToken *oauthToken = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:nil expiration:nil];
    return [self initWithOAuthToken:oauthToken];
}

#pragma mark - Public

+ (BOOL)isSandbox
{
    return _isSandbox;
}

+ (void)sandbox:(BOOL)sandbox
{
    _isSandbox = sandbox;
}

#pragma mark - Private

+ (NSString *)uberUserAgent
{
    return [NSString stringWithFormat:@"Uber iOS SDK/%@ %@/%@ (%@; iOS %@; Scale/%0.2f)",
            // TODO: figure out a better place to store the version string
            UberSDKVersion,
            [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey]
            ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey],
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey],
            [[UIDevice currentDevice] model],
            [[UIDevice currentDevice] systemVersion],
            [[UIScreen mainScreen] scale]];
}

+ (NSString *)apiHost
{
    return [self isSandbox] ? UBAPIHostSandbox : UBAPIHostProduction;
}

- (NSURLSession *)sessionWithHeaders:(NSDictionary *)headers
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPAdditionalHeaders = headers;
    
    return [NSURLSession sessionWithConfiguration:configuration
                                         delegate:nil
                                    delegateQueue:nil];
}

- (NSURLSession *)sessionWithServerToken:(NSString *)serverToken
{
    NSDictionary *headers = @{
                              @"User-Agent": UberSDKVersion,
                              @"Accept": @"application/json",
                              @"Authorization": [NSString stringWithFormat:@"Token %@", _serverToken]
                              };
    
    return [self sessionWithHeaders:headers];
}

- (NSURLSession *)sessionWithAccessToken:(NSString *)accessToken
{
    NSDictionary *headers = @{
                              @"User-Agent": UberSDKVersion,
                              @"Accept": @"application/json",
                              @"Authorization": [NSString stringWithFormat:@"Bearer %@", accessToken]
                              };
    
    return [self sessionWithHeaders:headers];
}

- (void)refreshTokenIfNeeded:(void (^)(NSError *error))completion
{
    if ([self.oauthToken canRefresh] && [self.oauthToken isExpired]) {
        [self.oauthToken refresh:^(NSError *error) {
            if (error) {
                completion(error);
            } else {
                [self.session finishTasksAndInvalidate];
                self.session = [self sessionWithAccessToken:self.oauthToken.accessToken];

                completion(nil);
            }
        }];
    } else {
        completion(nil);
    }
}

#pragma mark - Product Endpoints

- (void)productsWithCoordinate:(CLLocationCoordinate2D)coordinate
                    completion:(void (^)(NSArray *products, NSError *error))completion
{
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid location"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSDictionary *params = @{@"latitude": [NSNumber numberWithDouble:coordinate.latitude],
                                     @"longitude": [NSNumber numberWithDouble:coordinate.longitude]
                                     };
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:@"v1/products" query:params];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSArray *products;
                
                NSError *validationError;
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    products = [UBUtils modelsFromJSON:[json objectForKey:@"products"] withClass:UBProduct.class error:&validationError];
                }
                
                if (validationError) {
                    completion(nil, validationError);
                    return;
                } else {
                    completion(products, nil);
                }
            }];
            [sessionTask resume];
        }
    }];
}

- (void)priceEstimatesWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                            endCoordinate:(CLLocationCoordinate2D)endCoordinate
                               completion:(void (^)(NSArray *prices, NSError *error))completion
{
    if (!CLLocationCoordinate2DIsValid(startCoordinate)) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid start location"]);
        }
        
        return;
    } else if (!CLLocationCoordinate2DIsValid(endCoordinate)) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid end location"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSDictionary *params = @{
                                     @"start_latitude": [NSNumber numberWithDouble:startCoordinate.latitude],
                                     @"start_longitude": [NSNumber numberWithDouble:startCoordinate.longitude],
                                     @"end_latitude": [NSNumber numberWithDouble:endCoordinate.latitude],
                                     @"end_longitude": [NSNumber numberWithDouble:endCoordinate.longitude]
                                     };
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:@"v1/estimates/price" query:params];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSArray *prices;
                
                NSError *validationError;
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    prices = [UBUtils modelsFromJSON:[json objectForKey:@"prices"] withClass:UBPriceEstimate.class error:&validationError];
                }
                
                if (validationError) {
                    completion(nil, validationError);
                    return;
                } else {
                    completion(prices, nil);
                }
            }];
            [sessionTask resume];
        }
    }];
}

- (void)timeEstimatesWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                              completion:(void (^)(NSArray *, NSError *))completion
{
    if (!CLLocationCoordinate2DIsValid(startCoordinate)) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid start location"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSDictionary *params = @{
                                     @"start_latitude": [NSNumber numberWithDouble:startCoordinate.latitude],
                                     @"start_longitude": [NSNumber numberWithDouble:startCoordinate.longitude]
                                     };
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:@"v1/estimates/time" query:params];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSArray *times;
                
                NSError *validationError;
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    times = [UBUtils modelsFromJSON:[json objectForKey:@"times"] withClass:UBTimeEstimate.class error:&validationError];
                }
                
                if (validationError) {
                    completion(nil, validationError);
                    return;
                }  else {
                    completion(times, nil);
                }
            }];
            [sessionTask resume];
        }
    }];
}

- (void)promotionWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                       endCoordinate:(CLLocationCoordinate2D)endCoordinate
                          completion:(void (^)(UBPromotion *promotion, NSError *error))completion
{
    if (!CLLocationCoordinate2DIsValid(startCoordinate)) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid start location"]);
        }
        
        return;
    } else if (!CLLocationCoordinate2DIsValid(endCoordinate)) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid end location"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSDictionary *params = @{
                                     @"start_latitude": [NSNumber numberWithDouble:startCoordinate.latitude],
                                     @"start_longitude": [NSNumber numberWithDouble:startCoordinate.longitude],
                                     @"end_latitude": [NSNumber numberWithDouble:endCoordinate.latitude],
                                     @"end_longitude": [NSNumber numberWithDouble:endCoordinate.longitude]
                                     };
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:@"v1/promotions" query:params];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                UBPromotion *promotion;
                
                NSError *validationError;
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    promotion = [MTLJSONAdapter modelOfClass:UBPromotion.class fromJSONDictionary:json error:&validationError];
                }
                
                if (validationError) {
                    completion(nil, validationError);
                    return;
                } else {
                    completion(promotion, nil);
                }
            }];
            [sessionTask resume];
        }
    }];
}

#pragma mark User Endpoints

- (void)userActivityWithOffset:(NSInteger)offset
                         limit:(NSInteger)limit
                    completion:(void (^)(NSArray *userActivities,
                                         NSInteger offset,
                                         NSInteger limit,
                                         NSInteger count,
                                         NSError *error))completion;
{
    if (offset < 0) {
        offset = 0;
    } else if (limit < 1) {
        limit = 5;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, 0, 0, 0, error);
        } else {
            
            NSDictionary *params = @{
                                     @"offset": [NSNumber numberWithDouble:offset],
                                     @"limit": [NSNumber numberWithDouble:limit]
                                     };
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:@"v1.2/history" query:params];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSArray *userActivity;
                NSInteger offset = 0;
                NSInteger limit = 0;
                NSInteger count = 0;
                
                NSError *validationError;
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    offset = [[json objectForKey:@"offset"] integerValue];
                    limit = [[json objectForKey:@"limit"] integerValue];
                    count = [[json objectForKey:@"count"] integerValue];
                    
                    userActivity = [UBUtils modelsFromJSON:[json objectForKey:@"history"] withClass:UBUserActivity.class error:&validationError];
                }
                
                if (validationError) {
                    completion(nil, offset, limit, count, validationError);
                    return;
                }  else {
                    completion(userActivity, offset, limit, count, nil);
                }
            }];
            [sessionTask resume];
        }
    }];
}

- (void)userProfile:(void (^)(UBUserProfile *userProfile, NSError *error))completion
{
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:@"v1/me" query:nil];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                UBUserProfile *profile;
                
                NSError *validationError;
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    profile = [MTLJSONAdapter modelOfClass:UBUserProfile.class fromJSONDictionary:json error:&validationError];
                }
                
                if (validationError) {
                    completion(nil, validationError);
                    return;
                } else {
                    completion(profile, nil);
                }
            }];
            
            [sessionTask resume];
        }
    }];
}

#pragma mark Request Endpoints

- (void)requestRideWithProductId:(NSString *)productId
                 startCoordinate:(CLLocationCoordinate2D)start
                   endCoordinate:(CLLocationCoordinate2D)end
             surgeConfirmationId:(NSString *)surgeConfirmationId
                      completion:(void (^)(UBRide *request, UBSurgeConfirmation *surgeConfirmation, NSError *error))completion
{
    if (!productId.length || !CLLocationCoordinate2DIsValid(start)) {
        if (completion) {
            completion(nil, nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid params"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, nil, error);
        } else {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           productId, @"product_id",
                                           @(start.latitude), @"start_latitude",
                                           @(start.longitude), @"start_longitude",
                                           nil];
            if (CLLocationCoordinate2DIsValid(end)) {
                [params setObject:@(end.latitude) forKey:@"end_latitude"];
                [params setObject:@(end.longitude) forKey:@"end_longitude"];
            }
            if (surgeConfirmationId.length) {
                [params setObject:surgeConfirmationId forKey:@"surge_confirmation_id"];
            }
            
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:@"v1/requests" query:nil];
            NSURLRequest *request = [UBUtils POSTRequestWithUrl:url params:params isJSON:YES];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                UBRide *uberRequest = nil;
                UBSurgeConfirmation *surgeConfirmation = nil;
                NSError *validationError = nil;
                
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    uberRequest = [MTLJSONAdapter modelOfClass:UBRide.class fromJSONDictionary:json error:&validationError];
                } else if ([[json objectForKey:@"meta"] objectForKey:@"surge_confirmation"]) {
                    surgeConfirmation = [MTLJSONAdapter modelOfClass:UBSurgeConfirmation.class
                                                  fromJSONDictionary:[[json objectForKey:@"meta"] objectForKey:@"surge_confirmation"]
                                                               error:&validationError];
                }
                
                completion(uberRequest, surgeConfirmation, validationError);
            }];
            [sessionTask resume];
        }
    }];
}

- (void)rideDetailsWithRequestId:(NSString *)requestId completion:(void (^)(UBRide *request, NSError *error))completion
{
    if (!requestId.length) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"no request id"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSString *endpoint = [NSString stringWithFormat:@"v1/requests/%@", requestId];
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:endpoint query:nil];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                UBRide *uberRequest = nil;
                
                NSError *validationError;
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    uberRequest = [MTLJSONAdapter modelOfClass:UBRide.class fromJSONDictionary:json error:&validationError];
                }
                
                if (validationError) {
                    completion(nil, validationError);
                    return;
                } else {
                    completion(uberRequest, nil);
                }
            }];
            [sessionTask resume];
        }
    }];
}

- (void)requestEstimateWithProductId:(NSString *)productId
                                             startCoordinate:(CLLocationCoordinate2D)start
                                               endCoordinate:(CLLocationCoordinate2D)end
                                        completion:(void (^)(UBRideEstimate *estimate, NSError *error))completion
{
    if (!productId.length || !CLLocationCoordinate2DIsValid(start)) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid params"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           productId, @"product_id",
                                           @(start.latitude), @"start_latitude",
                                           @(start.longitude), @"start_longitude",
                                           nil];
            if (CLLocationCoordinate2DIsValid(end)) {
                [params setObject:@(end.latitude) forKey:@"end_latitude"];
                [params setObject:@(end.longitude) forKey:@"end_longitude"];
            }
            
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:@"v1/requests/estimate" query:nil];
            NSURLRequest *request = [UBUtils POSTRequestWithUrl:url params:params isJSON:YES];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                UBRideEstimate *estimate = nil;
                NSError *validationError = nil;
                
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    estimate = [MTLJSONAdapter modelOfClass:UBRideEstimate.class fromJSONDictionary:json error:&validationError];
                }
                
                completion(estimate, validationError);
            }];
            [sessionTask resume];
        }
    }];
}

- (void)cancelRideWithRequestId:(NSString *)requestId completion:(void (^)(NSError *error))completion
{
    if (!requestId.length) {
        if (completion) {
            completion([UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"no request id"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(error);
        } else {
            NSString *endpoint = [NSString stringWithFormat:@"v1/requests/%@", requestId];
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:endpoint query:nil];
            NSURLRequest *request = [UBUtils DELETERequestWithUrl:url];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    completion(error);
                } else {
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    if (statusCode < 200 || statusCode >= 300) {
                        error = [UBUtils errorWithCode:UBErrorNetwork
                                           description:[NSString stringWithFormat:@"network error:%ld (%@)",
                                                        (long)statusCode,
                                                        [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]]];
                        
                        completion(error);
                    }
                    completion(nil);
                }
            }];
            [sessionTask resume];
        }
    }];
}

- (void)rideMapWithRequestId:(NSString *)requestId completion:(void (^)(NSURL *rideMapURL, NSError *error))completion
{
    if (!requestId.length) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"no request id"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSString *endpoint = [NSString stringWithFormat:@"v1/requests/%@/map", requestId];
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:endpoint query:nil];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSURL *mapURL = nil;
                NSError *validationError = nil;
                
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    mapURL = [NSURL URLWithString:[json objectForKey:@"href"]];
                }
                
                completion(mapURL, validationError);
            }];
            [sessionTask resume];
        }
    }];
}

- (void)rideReceiptWithRequestId:(NSString *)requestId completion:(void (^)(UBRideReceipt *receipt, NSError *error))completion
{
    if (!requestId.length) {
        if (completion) {
            completion(nil, [UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"no request id"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSString *endpoint = [NSString stringWithFormat:@"v1/requests/%@/receipt", requestId];
            NSURL *url = [UBUtils URLWithHost:[UberAPIClient apiHost] path:endpoint query:nil];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                UBRideReceipt *receipt = nil;
                NSError *validationError = nil;
                
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
                if (!validationError) {
                    receipt = [MTLJSONAdapter modelOfClass:UBRideReceipt.class fromJSONDictionary:json error:&validationError];
                }
                
                completion(receipt, validationError);
            }];
            
            [sessionTask resume];
        }
    }];
}

#pragma mark - Sandbox Endpoints

- (void)updateSandboxRideWithRequestId:(NSString *)requestId status:(NSString *)status completion:(void (^)(NSError *error))completion
{
    if (!requestId.length || !status.length) {
        if (completion) {
            completion([UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid params"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(error);
        } else {
            NSDictionary *params = @{@"status": status};
            NSString *endpoint = [NSString stringWithFormat:@"v1/sandbox/requests/%@", requestId];
            NSURL *url = [UBUtils URLWithHost:UBAPIHostSandbox path:endpoint query:nil];
            NSURLRequest *request = [UBUtils PUTRequestWithUrl:url params:params];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    completion(error);
                } else {
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    if (statusCode < 200 || statusCode >= 300) {
                        error = [UBUtils errorWithCode:UBErrorNetwork
                                           description:[NSString stringWithFormat:@"network error:%ld (%@)",
                                                        (long)statusCode,
                                                        [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]]];
                        
                        completion(error);
                    }
                    completion(nil);
                }
            }];
            [sessionTask resume];
        }
    }];
}

- (void)updateSandboxProductWithProductId:(NSString *)productId
                     driversAvailable:(BOOL)driversAvailable
                                surge:(double)surge
                           completion:(void (^)(NSError *error))completion
{
    if (!productId.length) {
        if (completion) {
            completion([UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"no product id"]);
        }
        
        return;
    }
    
    [self refreshTokenIfNeeded:^(NSError *error) {
        if (error) {
            completion(error);
        } else {
            NSDictionary *params = @{
                                     @"drivers_available": [NSNumber numberWithBool:driversAvailable],
                                     @"surge_multiplier": [NSNumber numberWithDouble:surge]
                                     };
            NSString *endpoint = [NSString stringWithFormat:@"v1/sandbox/products/%@", productId];
            NSURL *url = [UBUtils URLWithHost:UBAPIHostSandbox path:endpoint query:nil];
            NSURLRequest *request = [UBUtils PUTRequestWithUrl:url params:params];
            NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    completion(error);
                } else {
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    if (statusCode < 200 || statusCode >= 300) {
                        error = [UBUtils errorWithCode:UBErrorNetwork
                                           description:[NSString stringWithFormat:@"network error:%ld (%@)",
                                                        (long)statusCode,
                                                        [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]]];
                        
                        completion(error);
                    }
                    completion(nil);
                }
            }];
            
            [sessionTask resume];
        }
    }];
}

@end
