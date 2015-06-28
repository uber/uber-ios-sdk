//
//  UBEndpointsViewController.m
//  UberSDK-Example
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import "UBEndpointsViewController.h"
#import "UBResultsViewController.h"
#import "UBRideViewController.h"

@interface UBEndpointsViewController () <UBOAuthWebViewControllerDelegate>

@property (nonatomic) UIView *overlay;

@property (nonatomic) NSString *clientId;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSString *serverToken;
@property (nonatomic) NSString *oauthRedirect;
@property (nonatomic) NSString *surgeRedirect;

@property (nonatomic) UBOAuthToken *oauthToken;

@end


@implementation UBEndpointsViewController

#pragma mark - Lifecycle

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _clientId = @"your_client_id";
        /*
         Note, leaving your client secret inside the application might cause security issues.
         We recommend performing OAuth2 server-side if possible.
         */
        _clientSecret = @"your_client_secret";
        _serverToken = @"your_server_token";
        _oauthRedirect = @"your_oauth_redirect_uri";
        _surgeRedirect = @"your_surge_redirect_uri";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // development mode
    [UberAPIClient sandbox:YES];
    
    // create the busy-spinner overlay
    self.overlay = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.overlay.backgroundColor = [UIColor blackColor];
    self.overlay.alpha = 0.5;
    self.overlay.hidden = YES;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.tintColor = [UIColor whiteColor];
    [spinner startAnimating];
    
    [self.overlay addSubview:spinner];
    spinner.center = CGPointMake(self.overlay.frame.size.width/2, self.overlay.frame.size.height/2);
    [self.view insertSubview:self.overlay aboveSubview:self.tableView];
}

#pragma mark - Private

- (void)showResult:(id)result withError:(NSError *)error
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        UBResultsViewController *vc = [[UBResultsViewController alloc] initWithResult:result];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Table view data source

typedef NS_ENUM(NSInteger, Row) {
    RowProducts = 0,
    RowPriceEstimate = 1,
    RowTimeEstimate = 2,
    RowPromotion = 3,
    
    RowAuthorize = 0,
    RowRevoke = 1,
    RowRefresh = 2,
    
    RowUserActivity = 0,
    RowUserProfile = 1,
    
    RowRideSimulator = 0
};

typedef NS_ENUM(NSInteger, Section) {
    SectionServerToken = 0,
    SectionOAuth = 1,
    SectionAccessToken = 2,
    SectionRideSimulator = 3,
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionServerToken:
            return 4;
        case SectionOAuth:
            return 3;
        case SectionAccessToken:
            return 2;
        case SectionRideSimulator:
            return 1;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SectionServerToken:
            return @"Server Token Endpoints";
        case SectionOAuth:
            return @"OAuth";
        case SectionAccessToken:
            return @"OAuth-Only Endpoints";
        case SectionRideSimulator:
            return @"Trip Simulator";
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *genericCell = @"genericCell";
    NSString *detailCell = @"detailCell";
    
    UITableViewCell *cell;
    if (indexPath.section == SectionOAuth) {
        cell = [tableView dequeueReusableCellWithIdentifier:genericCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:genericCell];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:detailCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:detailCell];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    if (indexPath.section == SectionServerToken) {
        switch (indexPath.row) {
            case RowProducts:
            {
                cell.textLabel.text = @"Product Types";
                cell.detailTextLabel.text = nil;
                break;
            }
            case RowPriceEstimate:
            {
                cell.textLabel.text = @"Price Estimates";
                cell.detailTextLabel.text = nil;
                break;
            }
            case RowTimeEstimate:
            {
                cell.textLabel.text = @"Time Estimates";
                cell.detailTextLabel.text = nil;
                break;
            }
            case RowPromotion:
            {
                cell.textLabel.text = @"Promotions";
                cell.detailTextLabel.text = nil;
                break;
            }
        }
    } else if (indexPath.section == SectionOAuth) {
        switch (indexPath.row) {
            case RowAuthorize:
            {
                cell.textLabel.text = @"Authorize";
                cell.detailTextLabel.text = self.oauthToken.accessToken.length ? self.oauthToken.accessToken : @"no token";
                break;
            }
            case RowRevoke:
            {
                cell.textLabel.text = @"Revoke";
                cell.detailTextLabel.text = nil;
                break;
            }
            case RowRefresh:
            {
                cell.textLabel.text = @"Refresh";
                cell.detailTextLabel.text = nil;
                break;
            }
        }
    } else if (indexPath.section == SectionAccessToken) {
        switch (indexPath.row) {
            case RowUserActivity:
            {
                cell.textLabel.text = @"Trip History";
                cell.detailTextLabel.text = nil;
                break;
            }
            case RowUserProfile:
            {
                cell.textLabel.text = @"Profile";
                cell.detailTextLabel.text = nil;
                break;
            }
        }
    } else if (indexPath.section == SectionRideSimulator) {
        switch (indexPath.row) {
            case RowRideSimulator:
            {
                cell.textLabel.text = @"Trip Simulator";
                cell.detailTextLabel.text = nil;
                break;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Uber HQ
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(37.7757102, -122.4181719);
    // SFO
    CLLocationCoordinate2D end = CLLocationCoordinate2DMake(37.6217788, -122.3782269);
#pragma mark Server Token
    if (indexPath.section == SectionServerToken) {
        UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:_serverToken];
        
        switch (indexPath.row) {
            case RowProducts:
            {
                self.overlay.hidden = NO;
                [client productsWithCoordinate:start completion:^(NSArray *products, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.overlay.hidden = YES;
                        [self showResult:products withError:error];
                    });
                }];
                break;
            }
            case RowPriceEstimate:
            {
                self.overlay.hidden = NO;
                [client priceEstimatesWithStartCoordinate:start endCoordinate:end completion:^(NSArray *prices, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.overlay.hidden = YES;
                        [self showResult:prices withError:error];
                    });
                }];
                break;
            }
            case RowTimeEstimate:
            {
                self.overlay.hidden = NO;
                [client timeEstimatesWithStartCoordinate:start completion:^(NSArray *times, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.overlay.hidden = YES;
                        [self showResult:times withError:error];
                    });
                }];
                break;
            }
            case RowPromotion:
            {
                self.overlay.hidden = NO;
                [client promotionWithStartCoordinate:start endCoordinate:end completion:^(UBPromotion *promotion, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.overlay.hidden = YES;
                        [self showResult:promotion withError:error];
                    });
                }];
                break;
            }
        }
#pragma mark OAuth
    } else if (indexPath.section == SectionOAuth) {
        switch (indexPath.row) {
            case RowAuthorize:
            {
                UBOAuthWebViewController *vc = [[UBOAuthWebViewController alloc] initWithClientId:self.clientId
                                                                                           secret:self.clientSecret
                                                                                      redirectURL:[NSURL URLWithString:self.oauthRedirect]
                                                                                           scopes:@[UBScopeRequest, UBScopeRequestReceipt, UBScopeProfile, UBScopeHistory]];
                vc.delegate = self;
                UINavigationController *nVc = [[UINavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nVc animated:YES completion:nil];
                
                break;
            }
            case RowRevoke:
            {
                [self.oauthToken revoke:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                            message:error.localizedDescription
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        } else {
                            self.oauthToken = nil;
                            [self.tableView reloadData];
                        }
                    });
                }];
                
                break;
            }
            case RowRefresh:
            {
                [self.oauthToken refresh:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                            message:error.localizedDescription
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        } else {
                            [self.tableView reloadData];
                        }
                    });
                }];
                
                break;
            }
        }
#pragma mark Access Token
    } else if (indexPath.section == SectionAccessToken) {
        if (!self.oauthToken) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Token"
                                                            message:@"No OAuth token. Re-authorize"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            UberAPIClient *client = [[UberAPIClient alloc] initWithOAuthToken:self.oauthToken];
            
            switch (indexPath.row) {
                case RowUserActivity:
                {
                    self.overlay.hidden = NO;
                    [client userActivityWithOffset:0
                                             limit:5
                                        completion:^(NSArray *userActivities, NSInteger offset, NSInteger limit, NSInteger count, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.overlay.hidden = YES;
                            [self showResult:userActivities withError:error];
                        });
                    }];
                    break;
                }
                case RowUserProfile:
                {
                    self.overlay.hidden = NO;
                    [client userProfile:^(UBUserProfile *userProfile, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.overlay.hidden = YES;
                            [self showResult:userProfile withError:error];
                        });
                    }];
                    
                    break;
                }
            }
        }
#pragma mark - Trip Simulator
    } else if (indexPath.section == SectionRideSimulator) {
        switch (indexPath.row) {
            case RowRideSimulator:
            {
                if (!self.oauthToken) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Token"
                                                                    message:@"No OAuth token. Re-authorize"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                } else {
                    UBRideViewController *vc = [[UBRideViewController alloc] initWithAccessToken:self.oauthToken.accessToken];
                    vc.surgeConfirmationURL = [NSURL URLWithString:self.surgeRedirect];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
                break;
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UBOauthWebViewController

- (void)uberOAuthWebViewController:(UBOAuthWebViewController *)viewController didFailWithError:(NSError *)error
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)uberOAuthWebViewController:(UBOAuthWebViewController *)viewController didSucceedWithToken:(UBOAuthToken *)token
{
    self.oauthToken = token;
    [self.tableView reloadData];
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)uberOAuthWebViewControllerDidCancel:(UBOAuthWebViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
