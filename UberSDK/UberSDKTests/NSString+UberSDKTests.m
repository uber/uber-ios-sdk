//
//  NSString+UberSDKTests.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "NSString+UberSDK.h"

@interface NSString_UberSDKTests : XCTestCase

@end

@implementation NSString_UberSDKTests

- (void)testBasicQueryParameters
{
    NSString *queryString = @"a=1&b=2&c=3";
    NSDictionary *expectedDictionary = @{
                                         @"a": @"1",
                                         @"b": @"2",
                                         @"c": @"3"
                                         };
    NSDictionary *queryDictionary = [queryString ub_urlQueryParameters];
    XCTAssertEqualObjects(queryDictionary, expectedDictionary);
}

- (void)testArrayQueryParameters
{
    NSString *queryString = @"a[]=3&a[]=2&a[]=3";
    NSDictionary *expectedDictionary = @{
                                         @"a": @[@"3", @"2", @"3"]
                                         };
    NSDictionary *queryDictionary = [queryString ub_urlQueryParameters];
    XCTAssertEqualObjects(queryDictionary, expectedDictionary);
}

- (void)testHashQueryParameters
{
    NSString *queryString = @"a[x]=1&a[y]=2&a[z]=3";
    NSDictionary *expectedDictionary = @{
                                         @"a": @{
                                                 @"x": @"1",
                                                 @"y": @"2",
                                                 @"z": @"3"
                                                 }
                                         };
    NSDictionary *queryDictionary = [queryString ub_urlQueryParameters];
    XCTAssertEqualObjects(queryDictionary, expectedDictionary);
}

- (void)testNestedHashQueryParameters
{
    NSString *queryString = @"p[a][a]=1&p[b][a]=2&p[a][b]=3&p[c]=9";
    NSDictionary *expectedDictionary = @{
                                         @"p": @{
                                                 @"a": @{
                                                         @"a": @"1",
                                                         @"b": @"3"
                                                         },
                                                 @"b": @{
                                                         @"a": @"2"
                                                         },
                                                 @"c": @"9"
                                                 }
                                         };
    NSDictionary *queryDictionary = [queryString ub_urlQueryParameters];
    XCTAssertEqualObjects(queryDictionary, expectedDictionary);
}

- (void)testNestedHashAndArrayQueryParameters
{
    NSString *queryString = @"p[a][a]=1&p[b][a]=2&p[a][b]=3&p[c][]=9&p[c][]=4&p[c][]=11";
    NSDictionary *expectedDictionary = @{
                                         @"p": @{
                                                 @"a": @{
                                                         @"a": @"1",
                                                         @"b": @"3"
                                                         },
                                                 @"b": @{
                                                         @"a": @"2"
                                                         },
                                                 @"c": @[@"9",@"4",@"11"]
                                                 }
                                         };
    NSDictionary *queryDictionary = [queryString ub_urlQueryParameters];
    XCTAssertEqualObjects(queryDictionary, expectedDictionary);
}

- (void)testURLDecoding
{
    NSString *queryString = @"dakjfhajf+kjha%20h!erjlhr%20asd%3F%3Ffgsdgjlhl%C3%A9fdmnfm%3B%5B%5D%27%3B%27.%0A%0A.%3B%3B.%3B%3B%3B%27%3B.%0A%0Al%3B230485923i5rlknvsd%2Cvblakhfwq%CB%9A%C2%A9%C2%A5%C2%A5%C2%AE%C3%B8%E2%80%A2%C2%A3%E2%84%A2%C3%B7%E2%89%A5A+%2B+B%C3%BC";
    NSString *expectedString = @"dakjfhajf kjha h!erjlhr asd??fgsdgjlhléfdmnfm;[]';'.\n\n.;;.;;;';.\n\nl;230485923i5rlknvsd,vblakhfwq˚©¥¥®ø•£™÷≥A + Bü";
    NSString *decodedString = [queryString ub_urlDecodedQueryStringComponent];
    XCTAssertEqualObjects(decodedString, expectedString);
}


- (void)testQueryComponentEncoding
{
    NSDictionary *keysToExpectedEncodings = @{
                                              @"a": @"a",
                                              @"abc": @"abc",
                                              @"a.b.c.": @"a.b.c.",
                                              @"a[]": @"a%5B%5D",
                                              @"a%5B%5D": @"a%255B%255D",
                                              @"a  b": @"a%20%20b",
                                              @":/?&=;+@#$,*()!": @"%3A%2F%3F%26%3D%3B%2B%40%23%24%2C%2A()!"
                                              };
    [keysToExpectedEncodings enumerateKeysAndObjectsUsingBlock:^(NSString *value, NSString *expectedEncodedValue, __unused BOOL *stop) {
        NSString *encodedValue = [value ub_urlEncodedQueryStringComponent];
        XCTAssertEqualObjects(encodedValue, expectedEncodedValue);
    }];
}

- (void)testUrlQueryParametersDecoding
{
    NSString *value = @"bankname=%D5%D0%C9%CC%D2%F8%D0%D0&card_no=6225ig1S%2BC6Z%2B6U%3D3093&contract_no=201508&front_bank_code=4004&input_charset=1&phone=135vQoPooZSog9Nfx8%2BwPI6IQ%3D%3D0710&puresign_order_no=14422803872307245&sign_method=1&sp_no=3400300001&sp_user_name=5b820a05-a8aa-4533-bde7-aca61358e6ae&version=2&sign=9fb20dbd31b345fc2b9c93b8f8af8ffc";
    
    NSDictionary *decodedDict = [value ub_urlQueryParameters];
    
    XCTAssertEqualObjects(decodedDict[@"bankname"], nil);
    XCTAssertEqualObjects(decodedDict[@"card_no"], @"6225ig1S+C6Z+6U=3093");
    XCTAssertEqualObjects(decodedDict[@"contract_no"], @"201508");
    XCTAssertEqualObjects(decodedDict[@"front_bank_code"], @"4004");
    XCTAssertEqualObjects(decodedDict[@"phone"], @"135vQoPooZSog9Nfx8+wPI6IQ==0710");
    XCTAssertEqualObjects(decodedDict[@"puresign_order_no"], @"14422803872307245");
    XCTAssertEqualObjects(decodedDict[@"sign"], @"9fb20dbd31b345fc2b9c93b8f8af8ffc");
    XCTAssertEqualObjects(decodedDict[@"sign_method"], @"1");
    XCTAssertEqualObjects(decodedDict[@"sp_no"], @"3400300001");
    XCTAssertEqualObjects(decodedDict[@"sp_user_name"], @"5b820a05-a8aa-4533-bde7-aca61358e6ae");
    XCTAssertEqualObjects(decodedDict[@"version"], @"2");
}

@end
