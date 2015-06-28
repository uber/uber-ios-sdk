//
//  MTLModel+UberSDK_Example.m
//  UberSDK-Example
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import "MTLModel+UberSDK_Example.h"

#import <objc/runtime.h>

@implementation MTLModel (UberSDK_Example)

- (NSArray *)propertyNames
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

@end
