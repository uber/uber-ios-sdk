//
//  OauthWebViewController.h
//  UberOAUth
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UBOAuthToken.h"

/// OAuth "request" scope
FOUNDATION_EXPORT NSString *const UBScopeRequest;
/// OAuth "request_receipt" scope
FOUNDATION_EXPORT NSString *const UBScopeRequestReceipt;
/// OAuth "history" scope
FOUNDATION_EXPORT NSString *const UBScopeHistory;
/// OAuth "profile" scope
FOUNDATION_EXPORT NSString *const UBScopeProfile;

@protocol UBOAuthWebViewControllerDelegate;

@interface UBOAuthWebViewController : UIViewController

/// Your app's client id.
@property (nonatomic, readonly) NSString *clientId;
/// Your app's client secret.
@property (nonatomic, readonly) NSString *clientSecret;
/// Your app's OAuth redirect URL.
@property (nonatomic, readonly) NSURL *redirectURL;
/// List of specified scope strings.
@property (nonatomic, readonly) NSArray *scopes;

/// Delegate object.
@property (nonatomic, weak) id<UBOAuthWebViewControllerDelegate> delegate;

/**
 Initializes the view controller.
 
 @param clientId your app's client id
 @param secret your app's secret
 @param redirectURL your app's OAuth redirect URL
 @param scopes list of desired scope strings, or nil for default scope
 
 @return initalized UBOAuthWebViewController object
 */
- (id)initWithClientId:(NSString *)clientId secret:(NSString *)secret redirectURL:(NSURL *)redirectURL scopes:(NSArray *)scopes;

@end


/**
 Delegate that responds to OAuth view controller events.
 */
@protocol UBOAuthWebViewControllerDelegate <NSObject>

@optional
/**
 Called if the user cancels (dismisses the view controller) OAuth login.

 Note: It is your responsibility to dismiss the view controller.
 @param viewController the OAuth login view controller.
 */
- (void)uberOAuthWebViewControllerDidCancel:(UBOAuthWebViewController *)viewController;

/**
 Called if an error occues with the OAuth login.
 
 Note: It is your responsibility to dismiss the view controller.
 @param viewController the OAuth login view controller.
 @param error the error
 */
- (void)uberOAuthWebViewController:(UBOAuthWebViewController *)viewController didFailWithError:(NSError *)error;

/**
 Called if the user OAuth login succeeds.
 
 Note: It is your responsibility to dismiss the view controller.
 @param viewController the OAuth login view controller.
 @param token UBOAuthToken object containing the credentials
 */
- (void)uberOAuthWebViewController:(UBOAuthWebViewController *)viewController didSucceedWithToken:(UBOAuthToken *)token;

@end