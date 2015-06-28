//
//  UBTripViewController.h
//  UberSDK-Example
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBRideViewController : UIViewController

@property (nonatomic) NSURL *surgeConfirmationURL;

- (id)initWithAccessToken:(NSString *)accessToken;

@end
