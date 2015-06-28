//
//  UBSurgeConfirmViewController.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UBSurgeConfirmation.h"

@protocol UBSurgeConfirmViewControllerDelegate;

@interface UBSurgeConfirmViewController : UIViewController

/// Surge confirmation object.
@property (nonatomic, readonly) UBSurgeConfirmation *surgeConfirmation;
/// Your app's surge redirect URL.
@property (nonatomic, readonly) NSURL *redirectURL;

/// Delegate object.
@property (nonatomic, weak) id<UBSurgeConfirmViewControllerDelegate> delegate;

/**
 Initializes the view controller.
 
 @param surgeConfirmation surge confirmation object returned by the request endpoint
 @param redirectURL your app's surge redirect URL
 
 @return initalized UBSurgeConfirmViewController object
 */
- (id)initWithSurgeConfirmation:(UBSurgeConfirmation *)surgeConfirmation redirectURL:(NSURL *)redirectURL;

@end


/**
 Delegate that responds to surge view controller events.
 */
@protocol UBSurgeConfirmViewControllerDelegate <NSObject>

@optional
/**
 Called if the user cancels (dismisses the view controller) surge confirmation.
 
 Note: It is your responsibility to dismiss the view controller.
 @param viewController the OAuth login view controller.
 */
- (void)uberSurgeConfirmViewControllerDidCancel:(UBSurgeConfirmViewController *)viewController;

/**
 Called if the user confirms surge pricing.
 
 Use the returned confirmation id when re-trying a previous Uber request.
 
 Note: It is your responsibility to dismiss the view controller.
 @param viewController the OAuth login view controller.
 @param confirmationId the unique confirmation id
 */
- (void)uberSurgeConfirmViewController:(UBSurgeConfirmViewController *)viewController didSucceedWithConfirmationId:(NSString *)confirmationId;

@end