//
//  UBTripViewController.m
//  UberSDK-Example
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import "UBRideViewController.h"

#import "UBResultsViewController.h"

#import <UIActionSheet+BlocksKit.h>
#import <UIAlertView+BlocksKit.h>
#import <NSTimer+BlocksKit.h>
#import <MRProgress.h>

#import <UberSDK/UberSDK.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, UBMapPinType)
{
    UBMapPinTypePickup,
    UBMapPinTypeDropoff,
    UBMapPinTypeCurrentLocation
};

@interface UBMapPin : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) UBMapPinType type;

+ (UBMapPin *)pinWithCoordinate:(CLLocationCoordinate2D)coordinate type:(UBMapPinType)type;

@end

@implementation UBMapPin

+ (UBMapPin *)pinWithCoordinate:(CLLocationCoordinate2D)coordinate type:(UBMapPinType)type
{
    UBMapPin *pin = [[UBMapPin alloc] init];
    pin.coordinate = coordinate;
    pin.type = type;
    
    return pin;
}

@end


@interface UBRideViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UBSurgeConfirmViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic) NSTimer *refreshTimer;

@property (nonatomic) BOOL hasDrivers;
@property (nonatomic) double surge;

@property (nonatomic) UberAPIClient *client;

@property (nonatomic) UBProduct *product;
@property (nonatomic) UBRide *ride;

@property (nonatomic) UBMapPin *startPin;
@property (nonatomic) UBMapPin *endPin;
@property (nonatomic) UBMapPin *currentLocationPin;

@end


@implementation UBRideViewController

#pragma mark - Lifecycle

- (id)initWithAccessToken:(NSString *)accessToken
{
    NSParameterAssert(accessToken.length);
    
    self = [super init];
    if (self) {
        _client = [[UberAPIClient alloc] initWithAccessToken:accessToken];
        
        _hasDrivers = YES;
        _surge = 1.0;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UberAPIClient sandbox:YES];
    
    self.title = @"Ride Simulator";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(-36,0,0,0);
    
    [self initializeState];
    
    // periodically update request state
    self.refreshTimer = [NSTimer bk_scheduledTimerWithTimeInterval:4.0 block:^(NSTimer *timer) {
        if (self.ride) {
            [self.client rideDetailsWithRequestId:self.ride.requestId completion:^(UBRide *ride, NSError *error) {
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.ride = ride;
                        
                        if (self.ride.location) {
                            CLLocationCoordinate2D location = CLLocationCoordinate2DMake([self.ride.location.latitude doubleValue],
                                                                                         [self.ride.location.longitude doubleValue]);
                            if (!self.currentLocationPin) {
                                self.currentLocationPin = [UBMapPin pinWithCoordinate:location type:UBMapPinTypeCurrentLocation];
                            }
                            
                            self.currentLocationPin.coordinate = location;
                            [self.mapView addAnnotation:self.currentLocationPin];
                        } else {
                            [self.mapView removeAnnotation:self.currentLocationPin];
                        }
                        
                        [self refresh];
                    });
                }
            }];
        }
        
        [self refresh];
    } repeats:YES];
}

- (void)dealloc
{
    [self.refreshTimer invalidate];
}

#pragma mark - Private

- (void)refresh {
    self.title = self.ride.status
        ? [NSString stringWithFormat:@"%@: %@", self.product.displayName, self.ride.status]
        : @"no active trip";
    
    [self.tableView reloadData];
}

- (void)reportError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showResult:(id)result withError:(NSError *)error
{
    if (error) {
        [self reportError:error];
    } else {
        UBResultsViewController *vc = [[UBResultsViewController alloc] initWithResult:result];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)changeTripStatus:(NSString *)status
{
    if (!status.length || !self.ride) {
        return;
    }
    
    [self showSpinner];
    [self.client updateSandboxRideWithRequestId:self.ride.requestId status:status completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideSpinner];
            
            if (error) {
                [self reportError:error];
            } else {
                // Note: due to eventual consistency issues, it's possible that the new status will not not be immediately retrieved
                // from the detail request.
                [self.client rideDetailsWithRequestId:self.ride.requestId completion:^(UBRide *ride, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            self.ride = ride;
                            [self refresh];
                        }
                    });
                }];
            }
        });
    }];
}

- (void)requestProductWithSurgeConfirmation:(NSString *)surgeConfirmation
{
    if (!self.product) {
        return;
    }
    
    [self showSpinner];
    [self.client requestRideWithProductId:self.product.productId
                          startCoordinate:self.startPin.coordinate
                            endCoordinate:self.endPin.coordinate
                      surgeConfirmationId:surgeConfirmation
                               completion:^(UBRide *ride, UBSurgeConfirmation *surgeConfirmation, NSError *error) {
                                   
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideSpinner];
            
            if (surgeConfirmation) {
                UBSurgeConfirmViewController *vc = [[UBSurgeConfirmViewController alloc] initWithSurgeConfirmation:surgeConfirmation
                                                                                                       redirectURL:self.surgeConfirmationURL];
                vc.delegate = self;
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc]
                                   animated:YES
                                 completion:nil];
            } else if (error) {
                [self reportError:error];
            } else {
                self.ride = ride;
            }
            
            [self refresh];
        });
    }];
}

- (void)initializeState
{
    self.product = nil;
    self.ride = nil;
    
    self.startPin = [UBMapPin pinWithCoordinate:CLLocationCoordinate2DMake(37.756468,-122.441606) type:UBMapPinTypePickup];
    self.endPin = [UBMapPin pinWithCoordinate:CLLocationCoordinate2DMake(37.785630,-122.397095) type:UBMapPinTypeDropoff];
    self.currentLocationPin = nil;
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(37.7755, -122.4181),
                                                               5000,
                                                               5000)];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.startPin];
    [self.mapView addAnnotation:self.endPin];
}

- (void)showSpinner
{
    [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
}

- (void)hideSpinner
{
    [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *pinId = @"pinId";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:pinId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinId];
        view.draggable = YES;
    }
    
    UBMapPin *pin = (UBMapPin *)annotation;
    switch (pin.type) {
        case UBMapPinTypePickup:
            ((MKPinAnnotationView *)view).pinColor = MKPinAnnotationColorGreen;
            break;
        case UBMapPinTypeDropoff:
            ((MKPinAnnotationView *)view).pinColor = MKPinAnnotationColorRed;
            break;
        case UBMapPinTypeCurrentLocation:
            ((MKPinAnnotationView *)view).pinColor = MKPinAnnotationColorPurple;
            break;
    }
    
    return view;
}

#pragma mark - UITableViewDataSource

typedef NS_ENUM(NSInteger, Section) {
    SectionRequest = 0,
    SectionSandbox = 1
};

typedef NS_ENUM(NSInteger, Row) {
    RowRideRequest = 0,
    RowRideDetails = 1,
    RowRideEstimate = 2,
    RowTripMap = 3,
    RowRideReceipt = 4,
    
    RowSandboxStatus = 0,
    RowSandboxDrivers = 1,
    RowSandboxSurge = 2,
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionRequest:
            return 5;
        case SectionSandbox:
            return 3;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SectionRequest:
            return @"Trip Requests";
        case SectionSandbox:
            return @"Sandbox Simulation";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SectionRequest:
            return 0;
        case SectionSandbox:
            return 20;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    if (indexPath.section == SectionRequest) {
        switch (indexPath.row) {
            case RowRideRequest:
            {
                if (self.ride && self.product) {
                    cell.textLabel.text = @"Cancel Request";
                } else if (self.product) {
                    cell.textLabel.text = @"New Trip";
                } else {
                    cell.textLabel.text = @"Select Product";
                }
                
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            }
            case RowRideDetails:
            {
                cell.textLabel.text = @"Request Details";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case RowRideEstimate:
            {
                cell.textLabel.text = @"Request Estimate";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case RowTripMap:
            {
                cell.textLabel.text = @"Request Map";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case RowRideReceipt:
            {
                cell.textLabel.text = @"Request Receipt";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
        }
    } else if (indexPath.section == SectionSandbox) {
        switch (indexPath.row) {
            case RowSandboxStatus:
            {
                cell.textLabel.text = @"Trip Status";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell.selectionStyle = self.ride ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
                cell.textLabel.enabled = self.ride;
                cell.detailTextLabel.enabled = self.ride;
                
                break;
            }
            case RowSandboxDrivers:
            {
                cell.textLabel.text = @"Drivers Available";
                cell.detailTextLabel.text = self.hasDrivers ? @"yes" : @"no";
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell.selectionStyle = self.product ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
                cell.textLabel.enabled = self.product;
                cell.detailTextLabel.enabled = self.product;
                
                break;
            }
            case RowSandboxSurge:
            {
                cell.textLabel.text = @"Surge";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", self.surge];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell.selectionStyle = self.product ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
                cell.textLabel.enabled = self.product;
                cell.detailTextLabel.enabled = self.product;
                
                break;
            }
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionRequest) {
        switch (indexPath.row) {
#pragma mark Requests
            case RowRideRequest:
            {
                if (self.ride && self.product) {
                    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:nil];
                    sheet.destructiveButtonIndex = [sheet bk_addButtonWithTitle:@"Rider Delete" handler:^{
                        if (self.ride) {
                            [self showSpinner];
                            [self.client cancelRideWithRequestId:self.ride.requestId completion:^(NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self hideSpinner];
                                    
                                    if (error) {
                                        [self reportError:error];
                                    } else {
                                        [self initializeState];
                                    }
                                });
                            }];
                        }
                    }];
                    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
                    [sheet showInView:self.view];
                } else if (self.product) {
                    [self requestProductWithSurgeConfirmation:nil];
                } else {
                    [self showSpinner];
                    [self.client productsWithCoordinate:self.startPin.coordinate completion:^(NSArray *products, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self hideSpinner];
                            
                            if (error) {
                                [self reportError:error];
                            } else {
                                UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"Products"];
                                for (UBProduct *product in products) {
                                    [sheet bk_addButtonWithTitle:product.displayName handler:^{
                                        self.product = product;
                                        
                                        // reset sandbox environment
                                        self.hasDrivers = YES;
                                        self.surge = 1.0;
                                        [self.client updateSandboxProductWithProductId:self.product.productId
                                                                      driversAvailable:self.hasDrivers
                                                                                 surge:self.surge completion:^(NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self refresh];
                                            });
                                        }];
                                    }];
                                }
                                sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
                                [sheet showInView:self.view];
                            }
                            
                            [self refresh];
                        });
                    }];
                }
                
                break;
            }
            case RowRideDetails:
            {
                if (self.ride) {
                    [self.client rideDetailsWithRequestId:self.ride.requestId completion:^(UBRide *ride, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.ride = ride;
                            [self refresh];
                            
                            [self showResult:ride withError:error];
                        });
                    }];
                }
                
                break;
            }
            case RowRideEstimate:
            {
                if (self.product) {
                    [self.client requestEstimateWithProductId:self.product.productId
                                              startCoordinate:self.startPin.coordinate
                                                endCoordinate:self.endPin.coordinate
                                                   completion:^(UBRideEstimate *estimate, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showResult:estimate withError:error];
                        });
                    }];
                }
                
                break;
            }
            case RowTripMap:
            {
                if (self.ride) {
                    [self showSpinner];
                    [self.client rideMapWithRequestId:self.ride.requestId completion:^(NSURL *rideMapURL, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self hideSpinner];
                            
                            if (error) {
                                [self reportError:error];
                            } else {
                                UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Trip Map"];
                                [alert bk_addButtonWithTitle:@"Open in Browser" handler:^{
                                    [[UIApplication sharedApplication] openURL:rideMapURL];
                                }];
                                alert.cancelButtonIndex = [alert addButtonWithTitle:@"Cancel"];
                                
                                [alert show];
                            }
                        });
                    }];
                }
                
                break;
            }
            case RowRideReceipt:
            {
                if (self.ride) {
                    [self.client rideReceiptWithRequestId:self.ride.requestId completion:^(UBRideReceipt *receipt, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showResult:receipt withError:error];
                        });
                    }];
                }
                
                break;
            }
        }
    }
#pragma mark Sandbox
    else if (indexPath.section == SectionSandbox) {
        switch (indexPath.row) {
            case RowSandboxStatus:
            {
                if (self.ride) {
                    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:nil];
                    
                    [sheet bk_addButtonWithTitle:@"Driver Accepted" handler:^{
                        [self changeTripStatus:@"accepted"];
                    }];
                    [sheet bk_addButtonWithTitle:@"Arriving" handler:^{
                        [self changeTripStatus:@"arriving"];
                    }];
                    [sheet bk_addButtonWithTitle:@"Trip In-Progress" handler:^{
                        [self changeTripStatus:@"in_progress"];
                    }];
                    [sheet bk_addButtonWithTitle:@"Driver Canceled" handler:^{
                        [self changeTripStatus:@"driver_canceled"];
                    }];
                    [sheet bk_addButtonWithTitle:@"Trip Completed" handler:^{
                        [self changeTripStatus:@"completed"];
                    }];
                    
                    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
                    
                    [sheet showInView:self.view];
                }
                
                break;
            }
            case RowSandboxDrivers:
            {
                if (self.product) {
                    [self showSpinner];
                    BOOL drivers = !self.hasDrivers;
                    [self.client updateSandboxProductWithProductId:self.product.productId
                                                  driversAvailable:drivers
                                                             surge:self.surge
                                                        completion:^(NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self hideSpinner];
                            
                            if (error) {
                                [self reportError:error];
                            } else {
                                self.hasDrivers = drivers;
                            }
                            
                            [self refresh];
                        });
                    }];
                }
                
                break;
            }
            case RowSandboxSurge:
            {
                if (self.product) {
                    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Surge"];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *textField = [alert textFieldAtIndex:0];
                    textField.keyboardType = UIKeyboardTypeDecimalPad;
                    textField.placeholder = [NSString stringWithFormat:@"%.1f", self.surge];
                    [alert bk_addButtonWithTitle:@"Set Surge" handler:^{
                        [self showSpinner];
                        [self.client updateSandboxProductWithProductId:self.product.productId
                                                      driversAvailable:self.hasDrivers
                                                                 surge:[textField.text doubleValue]
                                                            completion:^(NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self hideSpinner];
                                
                                if (error) {
                                    [self reportError:error];
                                } else {
                                    self.surge = [textField.text doubleValue];
                                }
                                
                                [self refresh];
                            });
                        }];
                    }];
                    alert.cancelButtonIndex = [alert addButtonWithTitle:@"Cancel"];
                    
                    [alert show];
                }
                
                break;
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Surge Confirmation

- (void)uberSurgeConfirmViewController:(UBSurgeConfirmViewController *)viewController didSucceedWithConfirmationId:(NSString *)confirmationId
{
    [viewController dismissViewControllerAnimated:YES completion:^{
        [self requestProductWithSurgeConfirmation:confirmationId];
    }];
}

- (void)uberSurgeConfirmViewControllerDidCancel:(UBSurgeConfirmViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end



