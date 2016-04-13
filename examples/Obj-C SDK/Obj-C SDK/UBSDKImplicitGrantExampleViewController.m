//
//  UBSDKImplicitGrantExampleViewController.m
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

#import "UBSDKImplicitGrantExampleViewController.h"

#import "UBSDKLocalization.h"

#import <UberRides/UberRides-Swift.h>

@interface UBSDKImplicitGrantExampleViewController ()

@property (nonatomic, readonly, nonnull) UBSDKLoginManager *loginManager;
@property (nonatomic, readonly, nonnull) UIButton *loginButton;

@end

@implementation UBSDKImplicitGrantExampleViewController

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
    self.navigationItem.title = UBSDKLOC(@"Implicit Grant / Login Manager");

    [self.view addSubview:self.loginButton];
    [self _addLoginButtonConstraints];
}

#pragma mark - Private

- (void)_initialSetup {
    _loginManager = [[UBSDKLoginManager alloc] init];
    
    _loginButton = ({
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [loginButton setTitle:UBSDKLOC(@"Login") forState:UIControlStateNormal];
        [loginButton sizeToFit];
        [loginButton addTarget:self action:@selector(_loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        loginButton;
    });
}

- (void)_addLoginButtonConstraints {
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    [self.view addConstraints:@[centerXConstraint, centerYConstraint]];
}

- (void)_showMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

- (void)_loginButtonAction:(UIButton *)button {
    NSArray<UBSDKRidesScope *> *requestedScopes = @[ UBSDKRidesScope.RideWidgets, UBSDKRidesScope.Profile, UBSDKRidesScope.Places ];
    
    [self.loginManager loginWithRequestedScopes:requestedScopes presentingViewController:self completion:^(UBSDKAccessToken * _Nullable accessToken, NSError * _Nullable error) {
        if (accessToken) {
            [self _showMessage:UBSDKLOC(@"Saved access token!")];
        } else {
            [self _showMessage:error.localizedDescription];
        }
    }];
}

@end
