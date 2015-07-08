//
//  UBOAuthTokenTests.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OHHTTPStubs.h>

#import "UBOAuthToken.h"
#import "OHHTTPStubs+UberSDKTests.h"

@interface UBOAuthTokenTests : XCTestCase

@end

@implementation UBOAuthTokenTests

- (void)tearDown
{
    [super tearDown];
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testInit
{
    // no token
    XCTAssertThrows([[UBOAuthToken alloc] initWithAccessToken:nil refreshToken:nil expiration:nil]);
    
    NSString *accessToken = @"access_token";
    NSString *refreshToken = @"refresh_token";
    NSDate *expiration = [NSDate distantFuture];
    NSString *clientId = @"client_id";
    NSString *clientSecret = @"client_secret";
    NSURL *redirectURL = [NSURL URLWithString:@"http://example.com"];
    
    // init
    UBOAuthToken *token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = clientId;
    token.clientSecret = clientSecret;
    token.redirectURL = redirectURL;
    
    XCTAssertEqualObjects(token.accessToken, accessToken);
    XCTAssertEqualObjects(token.refreshToken, refreshToken);
    XCTAssertEqualObjects(token.expirationDate, expiration);
    XCTAssertEqualObjects(token.clientId, clientId);
    XCTAssertEqualObjects(token.clientSecret, clientSecret);
    XCTAssertEqualObjects(token.redirectURL, redirectURL);
}

- (void)testInitWithJSON
{
    NSString *accessToken = @"12345";
    NSString *refreshToken = @"67890";
    NSNumber *expiry = @(2592000);
    
    NSDictionary *json = @{
                           @"access_token": accessToken,
                           @"refresh_token": refreshToken,
                           @"expires_in": expiry
                           };
    
    UBOAuthToken *token = [[UBOAuthToken alloc] initWithJSON:json];
    XCTAssertEqualObjects(token.accessToken, accessToken);
    XCTAssertEqualObjects(token.refreshToken, refreshToken);
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:[expiry doubleValue]];
    XCTAssertEqualWithAccuracy([token.expirationDate timeIntervalSinceReferenceDate],
                               [expirationDate timeIntervalSinceReferenceDate],
                               1.0);
}

- (void)testIsExpired
{
    NSString *accessToken = @"access_token";
    NSString *refreshToken = @"refresh_token";
    
    // init
    NSDate *expiration = [NSDate distantFuture];
    UBOAuthToken *token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    XCTAssertFalse([token isExpired]);
    
    expiration = [NSDate distantPast];
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    XCTAssertTrue([token isExpired]);
}

- (void)testCanRefresh
{
    NSString *accessToken = @"access_token";
    NSString *refreshToken = @"refresh_token";
    NSDate *expiration = [NSDate distantFuture];
    NSString *clientId = @"client_id";
    NSString *clientSecret = @"client_secret";
    NSURL *redirectURL = [NSURL URLWithString:@"http://example.com"];
    
    // no refresh token
    UBOAuthToken *token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:nil expiration:expiration];
    XCTAssertFalse([token canRefresh]);
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:@"" expiration:expiration];
    XCTAssertFalse([token canRefresh]);
    
    // no client id
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = nil;
    XCTAssertFalse([token canRefresh]);
    token.clientId = @"";
    XCTAssertFalse([token canRefresh]);
    
    // no client secret
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = clientId;
    token.clientSecret = nil;
    XCTAssertFalse([token canRefresh]);
    token.clientSecret = @"";
    XCTAssertFalse([token canRefresh]);
    
    // no redirect URL
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = clientId;
    token.clientSecret = clientSecret;
    token.redirectURL = nil;
    XCTAssertFalse([token canRefresh]);
    
    // can refresh
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = clientId;
    token.clientSecret = clientSecret;
    token.redirectURL = redirectURL;
    XCTAssertTrue([token canRefresh]);
}

- (void)testInvalidRefresh
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/oauth/token" file:@"access_token.json"];
    
    NSString *accessToken = @"access_token";
    NSString *refreshToken = @"refresh_token";
    NSDate *expiration = [NSDate distantFuture];
    NSString *clientId = @"client_id";
    NSString *clientSecret = @"client_secret";
    NSURL *redirectURL = [NSURL URLWithString:@"http://example.com"];
    
    // no refresh token
    UBOAuthToken *token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:nil expiration:expiration];
    token.clientId = clientId;
    token.clientSecret = clientSecret;
    token.redirectURL = redirectURL;
    
    XCTestExpectation *expectationToken = [self expectationWithDescription:nil];
    [token refresh:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectationToken fulfill];
    }];
    
    // no client id
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = nil;
    token.clientSecret = clientSecret;
    token.redirectURL = redirectURL;
    
    XCTestExpectation *expectationClientId = [self expectationWithDescription:nil];
    [token refresh:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectationClientId fulfill];
    }];
    
    // no client secret
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = clientId;
    token.clientSecret = nil;
    token.redirectURL = redirectURL;
    
    XCTestExpectation *expectationClientSecret = [self expectationWithDescription:nil];
    [token refresh:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectationClientSecret fulfill];
    }];
    
    // no redirect url
    token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = clientId;
    token.clientSecret = clientSecret;
    token.redirectURL = nil;
    
    XCTestExpectation *expectationRedirectURL = [self expectationWithDescription:nil];
    [token refresh:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectationRedirectURL fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRefresh
{
    [OHHTTPStubs ub_stubResponseWithEndpoint:@"/oauth/token" file:@"access_token.json"];
    
    NSString *accessToken = @"access_token";
    NSString *refreshToken = @"refresh_token";
    NSDate *expiration = [NSDate distantFuture];
    NSString *clientId = @"client_id";
    NSString *clientSecret = @"client_secret";
    NSURL *redirectURL = [NSURL URLWithString:@"http://example.com"];
    
    // no refresh token
    UBOAuthToken *token = [[UBOAuthToken alloc] initWithAccessToken:accessToken refreshToken:refreshToken expiration:expiration];
    token.clientId = clientId;
    token.clientSecret = clientSecret;
    token.redirectURL = redirectURL;
    
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    [token refresh:^(NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertEqualObjects(token.accessToken, @"EE1IDxytP04tJ767GbjH7ED9PpGmYvL");
        XCTAssertEqualObjects(token.refreshToken, @"Zx8fJ8qdSRRseIVlsGgtgQ4wnZBehr");
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:2592000];
        XCTAssertEqualWithAccuracy([token.expirationDate timeIntervalSinceReferenceDate],
                                   [expirationDate timeIntervalSinceReferenceDate],
                                   1.0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
