//
//  UBSurgeConfirmViewController.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBSurgeConfirmViewController.h"

#import "NSString+UberSDK.h"

@interface UBSurgeConfirmViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSURLSessionTask *sessionTask;

@property (nonatomic) UBSurgeConfirmation *surgeConfirmation;
@property (nonatomic) NSURL *redirectURL;

@end


@implementation UBSurgeConfirmViewController

- (id)initWithSurgeConfirmation:(UBSurgeConfirmation *)surgeConfirmation redirectURL:(NSURL *)redirectURL
{
    NSParameterAssert(surgeConfirmation);
    NSParameterAssert(redirectURL);
    
    self = [super init];
    if (self) {
        _surgeConfirmation = surgeConfirmation;
        _redirectURL = redirectURL;
    }
    
    return self;
}

- (void)loadView {
    //TODO: autolayout
    self.webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = self.webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Confirm Surge";
    
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.surgeConfirmation.confirmationURL]];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss)];
    cancel.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = cancel;
}

- (void)dismiss
{
    self.webView.delegate = nil;
    [self.sessionTask cancel];
    
    if ([self.delegate respondsToSelector:@selector(uberSurgeConfirmViewControllerDidCancel:)]) {
        [self.delegate uberSurgeConfirmViewControllerDidCancel:self];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    
    NSURL *strippedUrl = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
    if ([strippedUrl isEqual:self.redirectURL]) {
        __block NSString *confirmationid = nil;
        
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        [[components.query ub_urlQueryParameters] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isEqual:@"surge_confirmation_id"]) {
                confirmationid = [obj description];
                *stop = YES;
            }
        }];
        
        if (confirmationid) {
            if ([self.delegate respondsToSelector:@selector(uberSurgeConfirmViewController:didSucceedWithConfirmationId:)]) {
                [self.delegate uberSurgeConfirmViewController:self didSucceedWithConfirmationId:confirmationid];
                
                return NO;
            }
        }
    }
    
    return YES;
}


@end
