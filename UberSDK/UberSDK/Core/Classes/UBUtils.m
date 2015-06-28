//
//  UBUtils.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBUtils.h"

#import "NSString+UberSDK.h"

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>

@implementation UBUtils

+ (NSError *)errorWithCode:(UBErrorCode)errorCode description:(NSString *)description
{
    NSDictionary *userInfo = nil;
    if (description.length) {
        userInfo = @{NSLocalizedDescriptionKey: description};
    }
    
    return [NSError errorWithDomain:UBClientErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSArray *)modelsFromJSON:(NSArray *)json withClass:(Class)class error:(NSError **)error
{
    if (!json.count || !class) {
        return nil;
    }
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:json.count];
    for (NSDictionary *rawModel in json) {
        NSError *modelError;
        id model = [MTLJSONAdapter modelOfClass:class fromJSONDictionary:rawModel error:&modelError];
        if (modelError) {
            *error = [UBUtils errorWithCode:UBErrorCodeUnableToParseResponse description:modelError.localizedDescription];
            return nil;
        } else {
            [models addObject:model];
        }
    }
    
    return models;
}

+ (NSURL *)URLWithHost:(NSString *)host path:(NSString *)path query:(NSDictionary *)query
{
    if (!host.length) {
        return nil;
    }
    
    if (!path) {
        path = @"";
    } else if (![path hasPrefix:@"/"]) {
        path = [@"/" stringByAppendingString:path];
    }
    
    if (query.count) {
        NSMutableArray *parts = [NSMutableArray array];
        for (id key in query) {
            id value = [query objectForKey:key];
            NSString *part = [NSString stringWithFormat: @"%@=%@",
                              [[key description] ub_urlEncodedQueryStringComponent],
                              [[value description] ub_urlEncodedQueryStringComponent]
                              ];
            [parts addObject:part];
        }
        
        path = [path stringByAppendingFormat:@"?%@", [parts componentsJoinedByString: @"&"]];
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, path]];
}

+ (NSURLRequest *)POSTRequestWithUrl:(NSURL *)url params:(NSDictionary *)params isJSON:(BOOL)isJSON
{
    if (!url) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    if (params.count) {
        if (isJSON) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            NSError *error;
            NSData *json = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
            if (!error) {
                [request setHTTPBody:json];
            }
        } else {
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
        }
    }
    
    return request;
}

+ (NSURLRequest *)PUTRequestWithUrl:(NSURL *)url params:(NSDictionary *)params
{
    if (!url) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    
    if (params.count) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error;
        NSData *json = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        if (!error) {
            [request setHTTPBody:json];
        }
    }
    
    return request;
}



+ (NSURLRequest *)DELETERequestWithUrl:(NSURL *)url
{
    if (!url) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    
    return request;
}

+ (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [obj.description ub_urlEncodedQueryStringComponent]];
        [parameterArray addObject:param];
    }];
    
    return [[parameterArray componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)validatedJSONFromData:(NSData *)data
                               response:(NSURLResponse *)response
                          responseError:(NSError *)responseError
                                  error:(NSError **)error
{
    if (responseError) {
        *error = responseError;
        
        return nil;
    }
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode < 200 || statusCode >= 300) {
            *error = [UBUtils errorWithCode:UBErrorNetwork
                                description:[NSString stringWithFormat:@"network error:%ld (%@)",
                                             (long)statusCode,
                                             [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]]];
        }
    }
    
    NSError *jsonError;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
        // don't mask previous error
        if (!error)
            *error = [UBUtils errorWithCode:UBErrorCodeUnableToParseResponse description:@"unable to parse JSON response"];
        
        return nil;
    }
    
    return (NSDictionary *)json;
}


@end
