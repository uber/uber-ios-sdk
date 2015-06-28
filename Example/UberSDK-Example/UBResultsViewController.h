//
//  UBModelViewController.h
//  UberSDK-Example
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UberSDK/UberSDK.h>

@interface UBResultsViewController : UITableViewController

@property (nonatomic, readonly) id result;

- (id)initWithResult:(id)result;

@end
