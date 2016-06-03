//
//  UBSDKRideRequestWidgetExampleViewController.m
//  Obj-C SDK
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UBSDKRideRequestWidgetExampleViewController.h"
#import "UBSDKLocalization.h"

#import <UberRides/UberRides-Swift.h>

#import <CoreLocation/CoreLocation.h>

@interface UBSDKRideRequestWidgetExampleViewController () <UBSDKModalViewControllerDelegate>

@property (nonatomic, readonly, nonnull) UBSDKRideRequestButton *blackRideRequestButton;
@property (nonatomic, readonly, nonnull) UBSDKRideRequestButton *whiteRideRequestButton;
@property (nonatomic, readonly, nullable) CLLocationManager *locationManager;

@end

@implementation UBSDKRideRequestWidgetExampleViewController

#pragma mark - UIViewController

- (id)init {
    self = [super init];
    if (self) {
        [self _initialSetup];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = UBSDKLOC(@"Ride Request Widget");
    
    [self.view addSubview:self.blackRideRequestButton];
    [self.view addSubview:self.whiteRideRequestButton];
    
    [self _addBlackRequestButtonConstraints];
    [self _addWhiteRequestButtonConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - Private

- (void)_initialSetup {
    _blackRideRequestButton = [self _buildRideRequestWidgetButtonWithLoginType:UBSDKLoginTypeNative];
    
    _whiteRideRequestButton = [self _buildRideRequestWidgetButtonWithLoginType:UBSDKLoginTypeImplicit];
    [_whiteRideRequestButton setColorStyle:RequestButtonColorStyleWhite];
    
    _locationManager = [[CLLocationManager alloc] init];
}

- (UBSDKRideRequestButton *)_buildRideRequestWidgetButtonWithLoginType:(UBSDKLoginType)loginType {
    UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] initWithLoginType:loginType];
    UBSDKRideRequestViewRequestingBehavior *requestBehavior = [[UBSDKRideRequestViewRequestingBehavior alloc] initWithPresentingViewController:self loginManager:loginManager];
    requestBehavior.modalRideRequestViewController.delegate = self;
    
    
    UBSDKRideParameters *rideParameters = [self _buildRideParameters];
    
    return [[UBSDKRideRequestButton alloc] initWithRideParameters:rideParameters requestingBehavior:requestBehavior];
}

- (UBSDKRideParameters *)_buildRideParameters {
    UBSDKRideParametersBuilder *parameterBuilder = [[UBSDKRideParametersBuilder alloc] init];
    [parameterBuilder setPickupToCurrentLocation];
    return [parameterBuilder build];
}

- (void)_addBlackRequestButtonConstraints {
    self.blackRideRequestButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Center the button in the view
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.blackRideRequestButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.blackRideRequestButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.topView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [self.view addConstraints:@[centerXConstraint, centerYConstraint]];
}

- (void)_addWhiteRequestButtonConstraints {
    self.whiteRideRequestButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Center the button in the view
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.whiteRideRequestButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.whiteRideRequestButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [self.view addConstraints:@[centerXConstraint, centerYConstraint]];
}

#pragma mark - <UBSDKModalViewControllerDelegate>

- (void)modalViewControllerDidDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"did dismiss");
}

- (void)modalViewControllerWillDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"will dismiss");
}

@end
