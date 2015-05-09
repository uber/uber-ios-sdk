//
//  UBEmbeddedOAuth2WebViewController.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import "UBEmbeddedOAuth2WebViewController.h"

@interface UBEmbeddedOAuth2WebViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;
@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation UBEmbeddedOAuth2WebViewController

#pragma mark - UIViewController

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeAll;
}

- (BOOL)extendedLayoutIncludesOpaqueBars
{
    return YES;
}

- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = ({
        UIWebView *webView = [[UIWebView alloc] init];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        self.webView.delegate = self;
        webView;
    });
    
    self.loadingView = ({
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.hidesWhenStopped = YES;
        loadingView;
    });
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.loadingView];
    
    NSDictionary *views = @{ @"view" : self.webView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:0.9f
                                                           constant:0.0f]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.webView.canGoBack) {
        [self startLoading];
    }
}


#pragma mark - Actions

- (void)startLoading
{
    if (self.authorizationURI) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.authorizationURI]];
    } else {
        [self.webView loadHTMLString:@"ERROR: No `authorizationURI` provided."
                             baseURL:nil];
    }
}

- (IBAction)_cancel:(id)sender
{
    
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.loadingView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingView stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if ([url.scheme isEqualToString:self.redirectURI.scheme] &&
        [url.host isEqualToString:self.redirectURI.host] &&
        [url.path isEqualToString:self.redirectURI.path]) {
        return [self.delegate embeddedOAuthWebViewController:self didInterceptURL:url];
    } else {
        return YES;
    }
}

@end
