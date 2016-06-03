//
//  UBSDKDeeplinkExampleViewController.m
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

#import "UBSDKDeeplinkExampleViewController.h"
#import "UBSDKLocalization.h"

#import <UberRides/UberRides-Swift.h>

#import <CoreLocation/CoreLocation.h>

@interface UBSDKDeeplinkExampleViewController ()

@property (nonatomic, readonly, nullable) UBSDKRideRequestButton *blackRideRequestButton;
@property (nonatomic, readonly, nullable) UBSDKRideRequestButton *whiteRideRequestButton;

@end

@implementation UBSDKDeeplinkExampleViewController

#pragma mark - UIViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _initialSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialSetup];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = UBSDKLOC(@"Deeplink Buttons");
    
    [self.topView addSubview:self.blackRideRequestButton];
    [self.bottomView addSubview:self.whiteRideRequestButton];
    
    [self _addBlackButtonConstraints];
    [self _addWhiteButtonConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.blackRideRequestButton loadRideInformation];
    [self.whiteRideRequestButton loadRideInformation];
}

#pragma mark - Private

- (void)_initialSetup {
    _blackRideRequestButton = [[UBSDKRideRequestButton alloc] init];
    
    _whiteRideRequestButton = ({
        UBSDKRideParameters *rideParameters = [self _buildRideParameters];
        id<UBSDKRideRequesting> deeplinkBehavior = [[UBSDKDeeplinkRequestingBehavior alloc] init];
        UBSDKRideRequestButton *rideRequestButton = [[UBSDKRideRequestButton alloc] initWithRideParameters:rideParameters requestingBehavior:deeplinkBehavior];
        rideRequestButton.colorStyle = RequestButtonColorStyleWhite;
        rideRequestButton;
    });
}

- (UBSDKRideParameters *)_buildRideParameters {
    UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
    [builder setProductID:@"a1111c8c-c720-46c3-8534-2fcdd730040d"];
    
    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:37.770 longitude:-122.466];
    [builder setPickupLocation:pickupLocation nickname:@"California Academy of Sciences"];
    
    CLLocation *dropoffLocation = [[CLLocation alloc] initWithLatitude:37.791 longitude:-122.405];
    [builder setDropoffLocation:dropoffLocation nickname:@"Pier 39"];
    
    return [builder build];
}

- (void)_addBlackButtonConstraints {
    self.blackRideRequestButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.blackRideRequestButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.topView
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
    
    [self.topView addConstraints:@[centerXConstraint, centerYConstraint]];
}

- (void)_addWhiteButtonConstraints {
    self.whiteRideRequestButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.whiteRideRequestButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomView
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
    
    [self.bottomView addConstraints:@[centerXConstraint, centerYConstraint]];
}

@end
