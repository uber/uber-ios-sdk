//
//  ViewController.m
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

#import "ViewController.h"
@import UberRides;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create background views
    UIView *topView = [[UIView alloc] init];
    [self.view addSubview:topView];
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    
    // add black request button with default configurations
    RequestButton *blackRequestButton = [[RequestButton alloc] init];
    [topView addSubview:blackRequestButton];
    
    // add white request button and add custom configurations
    RequestButton *whiteRequestButton = [[RequestButton alloc] initWithColorStyle:RequestButtonColorStyleWhite];
    [whiteRequestButton setProductID:@"a1111c8c-c720-46c3-8534-2fcdd730040d"];
    [whiteRequestButton setPickupLocationWithLatitude:@"37.770" longitude:@"-122.466" nickname:@"California Academy of Sciences" address:nil];
    [whiteRequestButton setDropoffLocationWithLatitude:@"37.791" longitude:@"-122.405" nickname:@"Pier 39" address:nil];
    [bottomView addSubview:whiteRequestButton];
    
    // position UIViews and request buttons
    [self setUpBackgroundViewsWithTop:topView andBottom:bottomView];
    [self centerButton:blackRequestButton inView:topView];
    [self centerButton:whiteRequestButton inView:bottomView];
}

// set up two white and black background UIViews with autolayout constraints
- (void)setUpBackgroundViewsWithTop:(UIView*)topView andBottom:(UIView*)bottomView {
    topView.backgroundColor = [UIColor whiteColor];
    bottomView.backgroundColor = [UIColor blackColor];
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // pass views in dictionary
    NSDictionary *views = @{@"top":topView, @"bottom":bottomView};
    
    // position constraints
    NSArray *horizontalTopConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[top]|" options:0 metrics:nil views:views];
    NSArray *horizontalBottomConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottom]|" options:0 metrics:nil views:views];
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[top(bottom)][bottom]|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views];
    
    // add constraints to view
    [self.view addConstraints:horizontalTopConstraint];
    [self.view addConstraints:horizontalBottomConstraint];
    [self.view addConstraints:verticalConstraint];
};

// center button position inside each background UIView
- (void)centerButton:(RequestButton*)button inView:(UIView*)view {
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    // position constraints
    NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    // add constraints to view
    [view addConstraints:[NSArray arrayWithObjects:horizontalConstraint, verticalConstraint, nil]];
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
