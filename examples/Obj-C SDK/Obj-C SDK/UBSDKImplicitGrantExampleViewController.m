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
#import "UBSDKLoginButtonView.h"
#import "UBSDKUtility.h"

#import <UberRides/UberRides-Swift.h>

typedef NS_ENUM(NSInteger, ImplicitGrantTableViewSection) {
    ImplicitGrantTableViewSectionProfile,
    ImplicitGrantTableViewSectionPlaces,
    ImplicitGrantTableViewSectionHistory
};

static NSString *const profileCellReuseIdentifier = @"ProfileCell";
static NSString *const placesCellReuseIdentifer = @"PlacesCell";
static NSString *const historyCellReuseIdentifier = @"HistoryCell";

@interface UBSDKImplicitGrantExampleViewController () <UITableViewDelegate, UITableViewDataSource, UBSDKLoginButtonDelegate>

@property (strong, nonatomic) UBSDKUserProfile *profile;
@property (strong, nonatomic) NSMutableDictionary<NSString *, UBSDKPlace *> *places;
@property (strong, nonatomic) NSArray<UBSDKUserActivity *> *history;

@property (nonatomic, readonly, nonnull) UBSDKRidesClient *ridesClient;
@property (weak, nonatomic) UBSDKLoginButtonView *loginButtonView;
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation UBSDKImplicitGrantExampleViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _places = [NSMutableDictionary dictionary];
    _ridesClient = [[UBSDKRidesClient alloc] init];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    NSArray<UBSDKRidesScope *> *requestedScopes = @[ UBSDKRidesScope.RideWidgets, UBSDKRidesScope.Profile, UBSDKRidesScope.Places, UBSDKRidesScope.History ];
    
    UBSDKLoginButtonView *loginButtonView = [[UBSDKLoginButtonView alloc] initWithFrame:self.view.frame
                                                                                       scopes:requestedScopes
                                                                                    loginType:UBSDKLoginTypeImplicit];
    loginButtonView.loginButton.delegate = self;
    loginButtonView.loginButton.presentingViewController = self;
    [self.view addSubview:loginButtonView];
    _loginButtonView = loginButtonView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([UBSDKTokenManager fetchToken]) {
        self.loginButtonView.hidden = YES;
        [self loadUserData];
    }
}


#pragma mark - Private Interface

- (void)resetAccessToken {
    _profile = nil;
    [UBSDKTokenManager deleteToken];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loginButtonView.hidden = NO;
        [self.tableView reloadData];
    });
}


- (void)loadUserData {
    // Examples of various data that can be retrieved
    
    // Retrieves a user profile for the current logged in user
    [self.ridesClient fetchUserProfile:^(UBSDKUserProfile * _Nullable profile, UBSDKResponse *response) {
        if (response.statusCode == 401) {
            [self resetAccessToken];
        } else if (profile) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profile = profile;
                [self.tableView reloadData];
            });
        }
    }];
    
    // Gets the address assigned as the "home" address for current user
    [self.ridesClient fetchPlace:UBSDKPlace.Home completion:^(UBSDKPlace * _Nullable place, UBSDKResponse *response) {
        if (response.statusCode == 401) {
            [self resetAccessToken];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.places setObject:place forKey:UBSDKPlace.Home];
                [self.tableView reloadData];
            });
        }
    }];
    
    // Gets the address assigned as the "work" address for current user
    [self.ridesClient fetchPlace:UBSDKPlace.Work completion:^(UBSDKPlace * _Nullable place, UBSDKResponse *response) {
        if (response.statusCode == 401) {
            [self resetAccessToken];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.places setObject:place forKey:UBSDKPlace.Work];
                [self.tableView reloadData];
            });
        }
    }];
    
    // Gets the last 25 trips that the current user has taken
    [self.ridesClient fetchTripHistoryWithOffset:0 limit:25 completion:^(UBSDKTripHistory * _Nullable tripHistory, UBSDKResponse * _Nonnull response) {
        if (response.statusCode == 401) {
            [self resetAccessToken];
        } else if(!tripHistory || !tripHistory.history) {
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.history = tripHistory.history;
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.profile) {
        return 0;
    }
    
    switch(section) {
        case ImplicitGrantTableViewSectionProfile:
            return 1;
        case ImplicitGrantTableViewSectionPlaces:
            return self.places.allKeys.count;
        case ImplicitGrantTableViewSectionHistory:
            return self.history.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case ImplicitGrantTableViewSectionProfile: {
            if (!self.profile) {
                break;
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:profileCellReuseIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:profileCellReuseIdentifier];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.profile.firstName, self.profile.lastName];
            cell.detailTextLabel.text = self.profile.email;
            
            NSURL *url = [NSURL URLWithString: self.profile.picturePath];
            if (url) {
                [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imageView.image = [UIImage imageWithData:data];
                    });
                }] resume];
            }
            
            return cell;
        }
        case ImplicitGrantTableViewSectionPlaces: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:placesCellReuseIdentifer];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:placesCellReuseIdentifer];
            }
            NSString *placeText;
            UBSDKPlace *place;
            switch (indexPath.row) {
                case 0:
                    if ([self.places objectForKey:UBSDKPlace.Home]) {
                        place = [self.places objectForKey:UBSDKPlace.Home];
                        placeText = UBSDKPlace.Home.capitalizedString;
                        break;
                    }
                case 1:
                    place = [self.places objectForKey:UBSDKPlace.Work];
                    placeText = UBSDKPlace.Work.capitalizedString;
                    break;
            }
            
            NSString *addressText = @"None";
            if (place && place.address) {
                addressText = place.address;
            }
            cell.textLabel.text = placeText;
            cell.detailTextLabel.text = addressText;
            return cell;
        }
        case ImplicitGrantTableViewSectionHistory: {
            UBSDKUserActivity *trip = [self.history objectAtIndex:indexPath.row];
            
            if (!trip) {
                break;
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyCellReuseIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:historyCellReuseIdentifier];
            }
            
            cell.textLabel.text = trip.startCity.name;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ to %@", [dateFormatter stringFromDate:trip.startTime], [dateFormatter stringFromDate:trip.endTime]];
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 75.0;
            
        default:
            return UITableViewAutomaticDimension;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != ImplicitGrantTableViewSectionPlaces) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Update Place Address" message:nil preferredStyle:UIAlertControllerStyleAlert];
    NSString *placeID;
    switch (indexPath.row) {
        case 0:
            if ([self.places objectForKey:UBSDKPlace.Home]) {
                placeID = UBSDKPlace.Home;
                break;
            }
        case 1:
            placeID = UBSDKPlace.Work;
            break;
    }
    
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        UBSDKPlace *place = [self.places objectForKey:placeID];
        if (place && place.address) {
            textField.placeholder = place.address;
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL];
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *addressTextField = (UITextField *)[alertController.textFields objectAtIndex:0];
        
        if (!addressTextField || !addressTextField.text) {
            return;
        }
        
        [self.ridesClient updatePlace:placeID withAddress:addressTextField.text completion:^(UBSDKPlace * _Nullable place, UBSDKResponse * _Nonnull response) {
            [self.places setObject:place forKey:placeID];
            [self.tableView reloadData];
        }];
    }];
    
    [alertController addAction:updateAction];
    [alertController addAction:cancelAction];
    
    [self.view setNeedsLayout];
    [self presentViewController:alertController animated:YES completion:NULL];
}

#pragma mark - UBSDKLoginButtonDelegate

- (void)loginButton:(UBSDKLoginButton *)button didLogoutWithSuccess:(BOOL)success {
    if (success) {
        [UBSDKUtility showMessage:UBSDKLOC(@"Logout") presentingViewController:self completion:^{
            self.loginButtonView.hidden = NO;
        }];
    }
}

- (void)loginButton:(UBSDKLoginButton *)button didCompleteLoginWithToken:(UBSDKAccessToken *)accessToken error:(NSError *)error {
    if (accessToken) {
        [self loadUserData];
        [UBSDKUtility showMessage:UBSDKLOC(@"Saved access token!") presentingViewController:self completion:^{
            self.loginButtonView.hidden = YES;
        }];
    } else {
        [UBSDKUtility showMessage:error.localizedDescription presentingViewController:self completion:nil];
    }
}

@end
