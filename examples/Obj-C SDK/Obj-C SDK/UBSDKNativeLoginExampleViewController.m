//
//  UBSDKNativeLoginExampleViewController.m
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

#import "UBSDKNativeLoginExampleViewController.h"

#import "UBSDKLocalization.h"

#import <UberRides/UberRides-Swift.h>

@interface UBSDKNativeLoginExampleViewController() <UBSDKLoginButtonDelegate>

@property (nonatomic, readonly, nonnull) UBSDKLoginManager *loginManager;
@property (nonatomic, readonly, nonnull) UBSDKLoginButton *blackLoginButton;
@property (nonatomic, readonly, nonnull) UBSDKLoginButton *whiteLoginButton;

@end

@implementation UBSDKNativeLoginExampleViewController

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
    self.navigationItem.title = @"SSO";
    
    [self.view addSubview:self.blackLoginButton];
    [self.view addSubview:self.whiteLoginButton];
    [self _addBlackLoginButtonConstraints];
    [self _addWhiteLoginButtonConstraints];
}

#pragma mark - Private

- (void)_initialSetup {
    _loginManager = [[UBSDKLoginManager alloc] initWithLoginType:UBSDKLoginTypeNative];
    
    NSArray<UBSDKRidesScope *> *scopes = @[UBSDKRidesScope.Profile, UBSDKRidesScope.Places, UBSDKRidesScope.Request];
    
    _blackLoginButton = ({
        UBSDKLoginButton *loginButton = [[UBSDKLoginButton alloc] initWithFrame:CGRectZero scopes:scopes loginManager:_loginManager];
        loginButton.presentingViewController = self;
        [loginButton sizeToFit];
        loginButton.delegate = self;
        loginButton;
    });
    
    _whiteLoginButton = ({
        UBSDKLoginButton *loginButton = [[UBSDKLoginButton alloc] initWithFrame:CGRectZero scopes:scopes loginManager:_loginManager];
        loginButton.colorStyle = RequestButtonColorStyleWhite;
        loginButton.presentingViewController = self;
        [loginButton sizeToFit];
        loginButton.delegate = self;
        loginButton;
    });
}

- (void)_addBlackLoginButtonConstraints {
    self.blackLoginButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.blackLoginButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.topView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.blackLoginButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.topView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.blackLoginButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.topView
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:-20];
    
    [self.view addConstraints:@[centerXConstraint, centerYConstraint, widthConstraint]];
}

- (void)_addWhiteLoginButtonConstraints {
    self.whiteLoginButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.whiteLoginButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.whiteLoginButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.whiteLoginButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomView
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:-20];
    
    [self.view addConstraints:@[centerXConstraint, centerYConstraint, widthConstraint]];
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

#pragma mark - UBSDKLoginButtonDelegate

- (void)loginButton:(UBSDKLoginButton *)button didLogoutWithSuccess:(BOOL)success {
    if (success) {
        [self _showMessage:UBSDKLOC(@"Logout")];
    }
}

- (void)loginButton:(UBSDKLoginButton *)button didCompleteLoginWithToken:(UBSDKAccessToken *)accessToken error:(NSError *)error {
    if (accessToken) {
        [self _showMessage:UBSDKLOC(@"Saved access token!")];
    } else {
        [self _showMessage:error.localizedDescription];
    }
}

@end
