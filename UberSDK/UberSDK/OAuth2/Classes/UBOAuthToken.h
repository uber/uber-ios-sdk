//
//  UBOAuthToken.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 OAuth login server base URL
 */
FOUNDATION_EXPORT NSString *const UBLoginHost;

@interface UBOAuthToken : NSObject <NSCoding>

/// OAuth access token
@property (nonatomic, readonly) NSString *accessToken;

/// OAuth refresh token
@property (nonatomic, readonly) NSString *refreshToken;

/// Token expiration date.
@property (nonatomic, readonly) NSDate *expirationDate;

/// Client Id
@property (nonatomic) NSString *clientId;

/// Client secret
@property (nonatomic) NSString *clientSecret;

/// OAuth redirect URL
@property (nonatomic) NSURL *redirectURL;

/**
 Initialize the token.
 
 @param accessToken OAuth access token
 @param refreshToken refresh token
 @param expiration token expiration date
 @return token object
 */
- (id)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiration:(NSDate *)expiration;

/**
 Initialize token with JSON.
 
 @param json block
 @return token object
 */
- (id)initWithJSON:(NSDictionary *)json;

/**
 Check token expiry.
 @return TRUE if token is expired, FALSE otherwise.
 */
- (BOOL)isExpired;

/**
 Checks if it is possible to refresh this token.
 
 @return YES if refresh can be attempted, NO otherwise
 */
- (BOOL)canRefresh;

/**
 Revokes the OAuth token.
 
 @param clientId client Id
 @param secret client secret
 @param completion The completion handler to call when the revoke request is complete.
 */
- (void)revoke:(void (^)(NSError *error))completion;

/**
 Refreshes the OAuth token.
 
 @param clientId client Id
 @param secret client secret
 @param redirectURL redirect URL
 @param completion The completion handler to call when the revoke request is complete.
 */
- (void)refresh:(void (^)(NSError *error))completion;

@end
