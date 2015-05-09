//
//  UBEmbeddedOAuth2WebViewController.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UBOAuth2Client.h"

@class UBEmbeddedOAuth2WebViewController;

@interface UBOAuth2Client (EmbeddedWebViewController)

- (UBEmbeddedOAuth2WebViewController *)embeddedOAuthFlowViewController;

@end


@protocol UBEmbeddedOAuth2WebViewControllerDelegate;

@interface UBEmbeddedOAuth2WebViewController : UIViewController

@property (nonatomic, weak) id<UBEmbeddedOAuth2WebViewControllerDelegate> delegate;

@property (nonatomic) NSURL *authorizationURI;
@property (nonatomic) NSURL *redirectURI;

- (void)startLoading;

@end


@protocol UBEmbeddedOAuth2WebViewControllerDelegate <NSObject>

- (void)embeddedOAuthWebViewController:(UBEmbeddedOAuth2WebViewController *)webViewController willDismiss:(BOOL)cancelled;
- (BOOL)embeddedOAuthWebViewController:(UBEmbeddedOAuth2WebViewController *)webViewController didInterceptURL:(NSURL *)interceptedURL;

@end
