//
//  UBOAuthToken.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBOAuthToken.h"

#import "UBUtils.h"

NSString *const UBLoginHost = @"https://login.uber.com";

@interface UBOAuthToken ()

@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSString *refreshToken;
@property (nonatomic) NSDate *expirationDate;

@end


@implementation UBOAuthToken

#pragma mark - Initialization 

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _accessToken = [aDecoder decodeObjectForKey:@keypath(self, accessToken)];
        _refreshToken = [aDecoder decodeObjectForKey:@keypath(self, refreshToken)];
        _expirationDate = [aDecoder decodeObjectForKey:@keypath(self, expirationDate)];
        _clientId = [aDecoder decodeObjectForKey:@keypath(self, clientId)];
        _clientSecret = [aDecoder decodeObjectForKey:@keypath(self, clientSecret)];
        _redirectURL = [aDecoder decodeObjectForKey:@keypath(self, redirectURL)];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.accessToken forKey:@keypath(self, accessToken)];
    [aCoder encodeObject:self.refreshToken forKey:@keypath(self, refreshToken)];
    [aCoder encodeObject:self.expirationDate forKey:@keypath(self, expirationDate)];
    [aCoder encodeObject:self.clientId forKey:@keypath(self, clientId)];
    [aCoder encodeObject:self.clientSecret forKey:@keypath(self, clientSecret)];
    [aCoder encodeObject:self.redirectURL forKey:@keypath(self, redirectURL)];
}

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        [self updateWithJSON:json];
    }
    
    return self;
}

- (id)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiration:(NSDate *)expiration
{
    NSParameterAssert(accessToken.length);
    
    self = [super init];
    if (self) {
        _accessToken = accessToken;
        _refreshToken = refreshToken;
        _expirationDate = expiration;
    }
    
    return self;
}

#pragma mark - Private

- (void)updateWithJSON:(NSDictionary *)json
{
    _accessToken = [json objectForKey:@"access_token"];
    _refreshToken = [json objectForKey:@"refresh_token"];
    
    NSNumber *expiresIn = [json objectForKey:@"expires_in"];
    if (expiresIn) {
        _expirationDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
    }
}

#pragma mark - Public

- (BOOL)isExpired
{
    return self.expirationDate.timeIntervalSinceNow < 0;
}

- (BOOL)canRefresh
{
    return self.refreshToken.length && self.clientId.length && self.clientSecret.length && self.redirectURL;
}

- (void)revoke:(void (^)(NSError *error))completion
{
    if (!self.clientId.length || !self.clientSecret.length) {
        if (completion) {
            completion([UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid credentials"]);
        }
        
        return;
    }
    
    if (!self.accessToken.length) {
        if (completion) {
            completion([UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"no access token"]);
        }
        
        return;
    }
    
    NSDictionary *params = @{
                             @"client_id": self.clientId,
                             @"client_secret": self.clientSecret,
                             @"token": self.accessToken
                             };
    NSURL *url = [UBUtils URLWithHost:UBLoginHost path:@"oauth/revoke" query:nil];
    NSURLRequest *request = [UBUtils POSTRequestWithUrl:url params:params isJSON:NO];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(error);
        } else {
            completion(nil);
        }
    }];
    [sessionTask resume];
}

- (void)refresh:(void (^)(NSError *error))completion
{
    if (!self.clientId.length || !self.clientSecret.length || !self.redirectURL) {
        if (completion) {
            completion([UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"invalid credentials"]);
        }
        
        return;
    }
    
    if (!self.refreshToken.length) {
        if (completion) {
            completion([UBUtils errorWithCode:UBErrorCodeInvalidParam description:@"no refresh token"]);
        }
        
        return;
    }
    
    NSDictionary *params = @{
                             @"client_id": self.clientId,
                             @"client_secret": self.clientSecret,
                             @"grant_type": @"refresh_token",
                             @"redirect_uri": self.redirectURL.absoluteString,
                             @"refresh_token": self.refreshToken
                             };
    NSURL *url = [UBUtils URLWithHost:UBLoginHost path:@"oauth/token" query:nil];
    NSURLRequest *request = [UBUtils POSTRequestWithUrl:url params:params isJSON:NO];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(error);
        } else {
            NSError *validationError;
            NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&validationError];
            if (validationError) {
                completion(validationError);
            } else {
                [self updateWithJSON:json];
                
                completion(nil);
            }
        }
    }];
    [sessionTask resume];
}

#pragma mark - Override

- (NSString *)description {
    return [NSString stringWithFormat:@"access token:%@ refresh token:%@ expiration:%@",
            self.accessToken,
            self.refreshToken,
            self.expirationDate];
}

@end

