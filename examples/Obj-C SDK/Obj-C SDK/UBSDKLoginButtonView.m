//
//  UBSDKLoginButtonView.m
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

#import "UBSDKLoginButtonView.h"

#import "UBSDKLocalization.h"

@interface UBSDKLoginButtonView()

@property (nonatomic, nonnull) UBSDKLoginManager *loginManager;
@property (nonatomic, readonly, nonnull) NSArray<UBSDKRidesScope *> *scopes;

@end

@implementation UBSDKLoginButtonView

#pragma mark - UBSDKLoginButtonView

- (instancetype)initWithFrame:(CGRect)frame scopes:(NSArray<UBSDKRidesScope *> *)scopes loginType:(UBSDKLoginType)loginType {
    self = [super initWithFrame:frame];
    if (self) {
        _scopes = scopes;
        _loginManager = [[UBSDKLoginManager alloc] initWithLoginType:loginType];
        _loginButton = ({
            UBSDKLoginButton *loginButton = [[UBSDKLoginButton alloc] initWithFrame:CGRectZero scopes:scopes loginManager:_loginManager];
            [loginButton sizeToFit];
            loginButton;
        });
        [self addSubview:_loginButton];
        [self _addLoginButtonConstraints];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Private

- (void)_addLoginButtonConstraints {
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20];
    
    [self addConstraints:@[centerXConstraint, centerYConstraint, widthConstraint]];
}

@end
