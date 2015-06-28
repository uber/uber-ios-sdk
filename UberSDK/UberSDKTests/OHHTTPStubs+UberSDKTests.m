//
//  OHHTTPStubs+UberSDKTests.m
//  UberSDK
//
//  Created by George Polak on 6/27/15.
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "OHHTTPStubs+UberSDKTests.h"

@implementation OHHTTPStubs (UberSDKTests)

+ (void)ub_stubResponseWithEndpoint:(NSString *)endpoint file:(NSString *)file
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return !endpoint ||
        ((
          [request.URL.host isEqualToString:@"api.uber.com"]
          || [request.URL.host isEqualToString:@"sandbox-api.uber.com"]
          || [request.URL.host isEqualToString:@"login.uber.com"]
          )
         && [request.URL.path isEqualToString:endpoint]);
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if (!file) {
            OHHTTPStubsResponse *response = [[OHHTTPStubsResponse alloc] init];
            response.statusCode = 204;
            
            return response;
        } else {
            NSString *fixture = OHPathForFile(file, self.class);
            return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                    statusCode:200
                                                       headers:@{@"Content-Type":@"application/json"}];
        }
    }];
}

@end
