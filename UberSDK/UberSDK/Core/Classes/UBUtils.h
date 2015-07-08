//
//  UBUtils.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define keypath(OBJ, PATH) \
    (((void)(NO && ((void)OBJ.PATH, NO)), # PATH))
#define instanceKeypath(CLASS, PATH) \
    (((void)(NO && ((void)((CLASS *)NULL).PATH, NO)), # PATH))

/**
 Uber iOS SDK error codes
 */
typedef NS_ENUM(NSInteger, UBErrorCode)
{
    UBErrorCodeInvalidParam,            // invalid request params
    UBErrorCodeUnableToParseResponse,   // unable to parse server response
    UBErrorNetwork,                     // error receiving a response from Uber's servers
    UBErrorUnableToAuthenticate,        // unable to authenticate
};

/**
 Uber iOS SDK error domain
 */
FOUNDATION_EXPORT NSString *const UBClientErrorDomain;

@interface UBUtils : NSObject

+ (NSError *)errorWithCode:(UBErrorCode)errorCode description:(NSString *)description;
+ (NSArray *)modelsFromJSON:(NSArray *)json withClass:(Class)class error:(NSError **)error;
+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSDictionary *)query;
+ (NSDictionary *)validatedJSONFromData:(NSData *)data
                               response:(NSURLResponse *)response
                          responseError:(NSError *)responseError
                                  error:(NSError **)error;

+ (NSURLRequest *)POSTRequestWithUrl:(NSURL *)url params:(NSDictionary *)params isJSON:(BOOL)isJSON;
+ (NSURLRequest *)PUTRequestWithUrl:(NSURL *)url params:(NSDictionary *)params;
+ (NSURLRequest *)DELETERequestWithUrl:(NSURL *)url;

@end
