//
//  OHHTTPStubs+UberSDKTests.h
//  UberSDK
//
//  Created by George Polak on 6/27/15.
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "OHHTTPStubs.h"

@interface OHHTTPStubs (UberSDKTests)

+ (void)ub_stubResponseWithEndpoint:(NSString *)endpoint file:(NSString *)file;

@end
