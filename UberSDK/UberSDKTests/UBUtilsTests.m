//
//  UBUtilsTests.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "UberSDK.h"
#import "UBUtils.h"

@interface UBUtilsTests : XCTestCase

@end

@implementation UBUtilsTests

- (void)testErrorWithCode
{
    UBErrorCode errorCode = UBErrorCodeInvalidParam;
    NSString *description = @"some_description";
    
    NSError *error = [UBUtils errorWithCode:errorCode description:nil];
    XCTAssertEqual(error.domain, UBClientErrorDomain);
    XCTAssertEqual(error.code, errorCode);
    XCTAssertNil([error.userInfo objectForKey:NSLocalizedDescriptionKey]);
    
    error = [UBUtils errorWithCode:errorCode description:description];
    XCTAssertEqual(error.domain, UBClientErrorDomain);
    XCTAssertEqual(error.code, errorCode);
    XCTAssertEqual([error.userInfo objectForKey:NSLocalizedDescriptionKey], description);
}

- (void)testModelsFromJSON
{
    NSArray *rawCharges = @[
                            @{
                                @"@name":@"charge1",
                                @"@amount":@"1.0",
                                @"@type":@"type1"
                                }
                            ,@{
                                @"@name":@"charge2",
                                @"@amount":@"2.0",
                                @"@type":@"type2"
                                }
                            ];
    
    // no model
    XCTAssertNil([UBUtils modelsFromJSON:nil withClass:[UBRideReceiptCharge class] error:nil]);
    
    // no class
    XCTAssertNil([UBUtils modelsFromJSON:nil withClass:[UBRideReceiptCharge class] error:nil]);
    
    // charges
    NSError *error;
    NSArray *charges = [UBUtils modelsFromJSON:rawCharges withClass:[UBRideReceiptCharge class] error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(charges.count, 2);
    XCTAssertEqualObjects([[charges objectAtIndex:0] class], [UBRideReceiptCharge class]);
    XCTAssertEqualObjects([[charges objectAtIndex:1] class], [UBRideReceiptCharge class]);
}

- (void)testURLWithHost
{
    NSString *host = @"http://example.com";
    NSString *path = @"/v1/some_path";
    NSDictionary *query = @{
                            @"foo": @"bar",
                            @"test": @"this needs encoding"
                            };
    
    // no host
    XCTAssertNil([UBUtils URLWithHost:nil path:nil query:nil]);
    
    // full url
    NSURL *url = [UBUtils URLWithHost:host path:path query:query];
    NSString *rawUrl = [NSString stringWithFormat:@"%@%@?foo=bar&test=this needs encoding", host, path];
    NSURL *testUrl = [NSURL URLWithString:[rawUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(url, testUrl);
    
    // fix no leading slash
    url = [UBUtils URLWithHost:host path:[path substringFromIndex:1] query:query];
    XCTAssertEqualObjects(url, testUrl);
    
    // host-only
    url = [UBUtils URLWithHost:host path:nil query:nil];
    testUrl = [NSURL URLWithString:host];
    XCTAssertEqualObjects(url, testUrl);
    
    // no query
    url = [UBUtils URLWithHost:host path:path query:nil];
    testUrl = [NSURL URLWithString:[host stringByAppendingString:path]];
    XCTAssertEqualObjects(url, testUrl);
}

- (void)testPOSTRequest
{
    // no url
    XCTAssertNil([UBUtils POSTRequestWithUrl:nil params:nil isJSON:YES]);
    
    NSURL *url = [NSURL URLWithString:@"http://example.com"];
    NSDictionary *params = @{@"foo": @"bar"};
    NSString *method = @"POST";
    NSDictionary *headersJSON = @{@"Content-Type": @"application/json"};
    NSDictionary *headersForm = @{@"Content-Type": @"application/x-www-form-urlencoded"};
    
    // no params
    NSURLRequest *request = [UBUtils POSTRequestWithUrl:url params:nil isJSON:YES];
    XCTAssertEqualObjects(request.HTTPMethod, method);
    XCTAssertNil(request.HTTPBody);
    
    // JSON params
    request = [UBUtils POSTRequestWithUrl:url params:params isJSON:YES];
    XCTAssertEqualObjects(request.HTTPMethod, method);
    XCTAssertEqualObjects([request allHTTPHeaderFields], headersJSON);
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];
    XCTAssertEqualObjects(json, params);
    
    // form params
    request = [UBUtils POSTRequestWithUrl:url params:params isJSON:NO];
    XCTAssertEqualObjects(request.HTTPMethod, method);
    XCTAssertEqualObjects([request allHTTPHeaderFields], headersForm);
    
    NSString *formString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(formString, @"foo=bar");
}

- (void)testPUTRequest
{
    // no url
    XCTAssertNil([UBUtils PUTRequestWithUrl:nil params:nil]);
    
    NSURL *url = [NSURL URLWithString:@"http://example.com"];
    NSDictionary *params = @{@"foo": @"bar"};
    NSString *method = @"PUT";
    NSDictionary *headers = @{@"Content-Type": @"application/json"};
    
    // no params
    NSURLRequest *request = [UBUtils PUTRequestWithUrl:url params:nil];
    XCTAssertEqualObjects(request.HTTPMethod, method);
    XCTAssertNil(request.HTTPBody);
    
    // url and params
    request = [UBUtils PUTRequestWithUrl:url params:params];
    XCTAssertEqualObjects(request.HTTPMethod, method);
    XCTAssertEqualObjects([request allHTTPHeaderFields], headers);
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];
    XCTAssertEqualObjects(json, params);
}

- (void)testDELETERequest
{
    // no url
    XCTAssertNil([UBUtils DELETERequestWithUrl:nil]);
    
    // url
    NSURL *url = [NSURL URLWithString:@"http://example.com"];
    XCTAssertEqualObjects([UBUtils DELETERequestWithUrl:url].HTTPMethod, @"DELETE");
}

@end
