//
//  NSString+UberSDK.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UberSDK)

/**
 Encodes either a key or value of a query string for a GET-style URL., e.g., ?key=value&arrayKey[]=value1&arrayKey[]=value2.
 
 This goes beyond encoding with the built-in character set `URLQueryAllowedCharacterSet`. There's no harm in encoding more characters than necessary, apart from legibility and payload size.
 
 @return The URL-encoded value.
 */
- (NSString *)ub_urlEncodedQueryStringComponent;

/**
 Decodes a URL-encoded query string. It URL-decodes and substitutes "+" with spaces.
 
 @return The URL-decoded string.
 */
- (NSString *)ub_urlDecodedQueryStringComponent;

/**
 Decodes a URL query string formatted as for an HTTP GET request into an NSDictionary.
 
 If using this with an NSURL, you should pass in the `query` property directly, without URL-decoding it yourself.
 
 Values are one of the following types: NSDictionary, NSArray, NSString. Note that numbers are not automatically converted to NSNumbers since, unlike JSON, there is no concept of a type in a URL query.
 
 @return The decoded NSDictionary.
 */
- (NSDictionary *)ub_urlQueryParameters;

@end
