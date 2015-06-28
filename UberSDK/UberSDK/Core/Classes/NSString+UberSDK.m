//
//  NSString+UberSDK.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "NSString+UberSDK.h"

@implementation NSString (UberSDK)

- (NSString *)ub_urlEncodedQueryStringComponent
{
    static NSString * const UBCharactersToBeEscapedInQueryString = @":/?&=;+@#$,*";
    NSMutableCharacterSet *allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:UBCharactersToBeEscapedInQueryString];
    
    return [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
}

- (NSString *)ub_urlDecodedQueryStringComponent
{
    return [[self stringByReplacingOccurrencesOfString:@"+"
                                            withString:@" "]
            stringByRemovingPercentEncoding];
}

- (NSDictionary *)ub_urlQueryParameters
{
    NSArray *args = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:args.count];
    
    for (NSString *arg in args) {
        if (arg.length == 0) {
            // Probably just a sloppy string concatentation
            continue;
        }
        
        NSArray *parts = [arg componentsSeparatedByString:@"="];
        NSString *rawKey, *value;
        if (parts.count == 1) {
            rawKey = arg;
            value = @"";
        }
        else {
            rawKey = parts[0];
            value = parts[1];
        }
        
        if (rawKey && value) {
            rawKey = [rawKey ub_urlDecodedQueryStringComponent];
            value = [value ub_urlDecodedQueryStringComponent];
            
            if (value != nil) {
                NSScanner *keyScanner = [NSScanner scannerWithString:rawKey];
                NSString *key;
                [keyScanner scanUpToString:@"[" intoString:&key];
                if ([keyScanner isAtEnd]) {
                    result[key] = value;
                }
                else {
                    [keyScanner scanString:@"[" intoString:NULL];
                    NSMutableDictionary *dictionaryRef = result;
                    while (![keyScanner isAtEnd]) {
                        NSString *innerKey;
                        [keyScanner scanUpToString:@"]" intoString:&innerKey];
                        [keyScanner scanString:@"]" intoString:NULL];
                        
                        id currentValue = dictionaryRef[key];
                        if (innerKey.length == 0) {
                            // Array
                            if ([currentValue isKindOfClass:[NSArray class]]) {
                                [currentValue addObject:value];
                            }
                            else {
                                dictionaryRef[key] = [NSMutableArray arrayWithObject:value];
                            }
                            
                            dictionaryRef = nil;
                            
                            // Cannot nest in an array
                            break;
                        }
                        else {
                            // Dictionary
                            if (![currentValue isKindOfClass:[NSDictionary class]]) {
                                dictionaryRef[key] = [NSMutableDictionary dictionary];
                            }
                            
                            dictionaryRef = dictionaryRef[key];
                            key = innerKey;
                            [keyScanner scanString:@"[" intoString:NULL];
                        }
                    }
                    if ([dictionaryRef isKindOfClass:[NSDictionary class]]) {
                        dictionaryRef[key] = value;
                    }
                }
            }
        }
    }
    
    return result;
}

@end
