//
//  UBSDKExampleTableViewController.m
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

#import "UBSDKExampleTableViewController.h"

#import "UBSDKDeeplinkExampleViewController.h"
#import "UBSDKExampleTableViewCell.h"
#import "UBSDKImplicitGrantExampleViewController.h"
#import "UBSDKLocalization.h"
#import "UBSDKRideRequestWidgetExampleViewController.h"
#import "UBSDKNativeLoginExampleViewController.h"

#import <UberRides/UberRides-Swift.h>

@interface UBSDKExampleTableViewController ()

@property (nonatomic, readonly, nonnull) NSDictionary<NSNumber *, NSArray<UBSDKExampleTableViewCell *> *> *tableViewCellMap;

@end

@implementation UBSDKExampleTableViewController

#pragma mark - UIViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
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

#pragma mark - Private

- (void)_initialSetup {
    _tableViewCellMap = [self _buildTableCellMap];
}

- (NSDictionary<NSNumber *, NSArray<UBSDKExampleTableViewCell *> *> *)_buildTableCellMap {
    NSMutableDictionary<NSNumber *, NSArray<UBSDKExampleTableViewCell *> *> *tableCellMap = [NSMutableDictionary dictionary];
    
    NSMutableArray<UBSDKExampleTableViewCell *> *sectionOneExampleCells = [NSMutableArray array];
    
    [sectionOneExampleCells addObject:[self _createDeeplinkExampleCell]];
    [sectionOneExampleCells addObject:[self _createRideRequestWidgetButtonExampleCell]];
    [sectionOneExampleCells addObject:[self _createImplicitGrantExampleCell]];
    [sectionOneExampleCells addObject:[self _createNativeLoginExampleCell]];

    [tableCellMap setObject:sectionOneExampleCells forKey:@(0)];
    
    NSMutableArray<UBSDKExampleTableViewCell *> *sectionTwoExampleCells= [NSMutableArray array];
    
    [sectionTwoExampleCells addObject:[self _createLogoutExampleCell]];
     
     [tableCellMap setObject:sectionTwoExampleCells forKey:@(1)];
    
    return tableCellMap;
}

- (UBSDKExampleTableViewCell *)_createDeeplinkExampleCell {
    UBSDKExampleTableViewController __weak *weakSelf = self;
    void (^behaviorBlock)() = ^void() {
        UBSDKDeeplinkExampleViewController *deeplinkExampleViewController = [[UBSDKDeeplinkExampleViewController alloc] init];
        [weakSelf.navigationController pushViewController:deeplinkExampleViewController animated:YES];
    };
    UBSDKExampleTableViewCell *deeplinkExampleCell = [[UBSDKExampleTableViewCell alloc] initWithBehaviorBlock:behaviorBlock];
    deeplinkExampleCell.textLabel.text = UBSDKLOC(@"Deeplink Request Buttons");
    return deeplinkExampleCell;
}

- (UBSDKExampleTableViewCell *)_createRideRequestWidgetButtonExampleCell {
    UBSDKExampleTableViewController __weak *weakSelf = self;
    void (^behaviorBlock)() = ^void() {
        UBSDKRideRequestWidgetExampleViewController *rideRequestWidgetExampleViewController = [[UBSDKRideRequestWidgetExampleViewController alloc] init];
        [weakSelf.navigationController pushViewController:rideRequestWidgetExampleViewController animated:YES];
    };
    UBSDKExampleTableViewCell *rideRequestWidgetExampleCell = [[UBSDKExampleTableViewCell alloc] initWithBehaviorBlock:behaviorBlock];
    rideRequestWidgetExampleCell.textLabel.text = UBSDKLOC(@"Ride Request Widget Button");
    return rideRequestWidgetExampleCell;
}

- (UBSDKExampleTableViewCell *)_createImplicitGrantExampleCell {
    UBSDKExampleTableViewController __weak *weakSelf = self;
    void (^behaviorBlock)() = ^void() {
        UBSDKImplicitGrantExampleViewController *implicitGrantExampleViewController = [[UBSDKImplicitGrantExampleViewController alloc] init];
        [weakSelf.navigationController pushViewController:implicitGrantExampleViewController animated:YES];
    };
    UBSDKExampleTableViewCell *implicitGrantExampleCell = [[UBSDKExampleTableViewCell alloc] initWithBehaviorBlock:behaviorBlock];
    implicitGrantExampleCell.textLabel.text = UBSDKLOC(@"Implicit Grant / Login Manager");
    return implicitGrantExampleCell;
}

- (UBSDKExampleTableViewCell *)_createNativeLoginExampleCell {
    UBSDKExampleTableViewController __weak *weakSelf = self;
    void (^behaviorBlock)() = ^void() {
        UBSDKNativeLoginExampleViewController *nativeLoginExampleViewController = [[UBSDKNativeLoginExampleViewController alloc] init];
        [weakSelf.navigationController pushViewController:nativeLoginExampleViewController animated:YES];
    };
    UBSDKExampleTableViewCell *nativeLoginExampleCell = [[UBSDKExampleTableViewCell alloc] initWithBehaviorBlock:behaviorBlock];
    nativeLoginExampleCell.textLabel.text = @"Native Login";
    return nativeLoginExampleCell;
}

- (UBSDKExampleTableViewCell *)_createLogoutExampleCell {
    void (^behaviorBlock)() = ^void() {
        [UBSDKTokenManager deleteToken];
    };
    UBSDKExampleTableViewCell *logoutExampleCell = [[UBSDKExampleTableViewCell alloc] initWithBehaviorBlock:behaviorBlock];
    logoutExampleCell.textLabel.text = UBSDKLOC(@"Logout");
    logoutExampleCell.textLabel.textColor = [UIColor redColor];
    logoutExampleCell.accessoryType = UITableViewCellAccessoryNone;
    return logoutExampleCell;
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger index = indexPath.row;
    
    NSArray<UBSDKExampleTableViewCell *> *sectionCells = self.tableViewCellMap[@(section)];
    if (sectionCells && index < sectionCells.count) {
        return sectionCells[index];
    }

    return [[UBSDKExampleTableViewCell alloc] initWithBehaviorBlock:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger index = indexPath.row;
    
    NSArray<UBSDKExampleTableViewCell *> *sectionCells = self.tableViewCellMap[@(section)];
    if (sectionCells && index < sectionCells.count) {
        [sectionCells[index] executeBehaviorBlock];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableViewCellMap.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewCellMap[@(section)].count;
}

@end
