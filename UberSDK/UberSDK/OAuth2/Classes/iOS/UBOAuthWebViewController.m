//
//  OauthWebViewController.m
//  UberOAUth
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBOAuthWebViewController.h"

#import "UBUtils.h"

NSString *const UBScopeRequest = @"request";
NSString *const UBScopeRequestReceipt = @"request_receipt";
NSString *const UBScopeHistory = @"history";
NSString *const UBScopeProfile = @"profile";

@interface UBOAuthWebViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSURLSessionTask *sessionTask;

@property (nonatomic) NSString *clientId;
@property (nonatomic) NSString *clientSecret;
@property (nonatomic) NSURL *redirectURL;
@property (nonatomic) NSArray *scopes;

@end

@implementation UBOAuthWebViewController

- (id)initWithClientId:(NSString *)clientId secret:(NSString *)secret redirectURL:(NSURL *)redirectURL scopes:(NSArray *)scopes
{
    NSParameterAssert(clientId.length);
    NSParameterAssert(secret.length);
    NSParameterAssert(redirectURL);
    
    self = [super init];
    if (self) {
        _clientId = clientId;
        _clientSecret = secret;
        _redirectURL = redirectURL;
        _scopes = scopes;
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
    
    self.title = @"Authenticate";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   self.clientId, @"client_id",
                                   @"code", @"response_type",
                                   nil];
    if (self.scopes.count) {
        [params setObject:[self.scopes componentsJoinedByString:@" "] forKey:@"scope"];
    }
    NSURL *authUrl = [UBUtils URLWithHost:UBLoginHost path:@"oauth/authorize" query:params];
    
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:authUrl]];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss)];
    cancel.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = cancel;
}

- (void)dismiss
{
    self.webView.delegate = nil;
    [self.sessionTask cancel];
    
    
    if ([self.delegate respondsToSelector:@selector(uberOAuthWebViewControllerDidCancel:)]) {
        [self.delegate uberOAuthWebViewControllerDidCancel:self];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    
    if ([request.URL.scheme isEqual:self.redirectURL.scheme]) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSString *code = nil;
        for (NSURLQueryItem *item in components.queryItems) {
            if ([item.name isEqual:@"code"]) {
                code = item.value;
                break;
            }
        }
        
        if (!code.length) {
            if ([self.delegate respondsToSelector:@selector(uberOAuthWebViewController:didFailWithError:)]) {
                NSError *error = [UBUtils errorWithCode:UBErrorUnableToAuthenticate description:@"unable to to receive authentication code"];
                [self.delegate uberOAuthWebViewController:self didFailWithError:error];
            }
            
            return NO;
        }
        
        NSDictionary *postData = @{@"client_id": self.clientId,
                                   @"client_secret": self.clientSecret,
                                   @"grant_type": @"authorization_code",
                                   @"redirect_uri": self.redirectURL,
                                   @"code": code};
        NSURL *url = [NSURL URLWithString:@"oauth/token" relativeToURL:[NSURL URLWithString:UBLoginHost]];
        NSURLRequest *authRequest = [UBUtils POSTRequestWithUrl:url params:postData isJSON:NO];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        self.sessionTask = [session dataTaskWithRequest:authRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                if ([self.delegate respondsToSelector:@selector(uberOAuthWebViewController:didFailWithError:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate uberOAuthWebViewController:self didFailWithError:error];
                    });
                }
            } else {
                NSError *jsonError;
                NSDictionary *json = [UBUtils validatedJSONFromData:data response:response responseError:error error:&jsonError];
                if (jsonError && [self.delegate respondsToSelector:@selector(uberOAuthWebViewController:didFailWithError:)]) {
                    [self.delegate uberOAuthWebViewController:self didFailWithError:jsonError];
                } else {
                    UBOAuthToken *token = [[UBOAuthToken alloc] initWithJSON:json];
                    token.clientId = self.clientId;
                    token.clientSecret = self.clientSecret;
                    token.redirectURL = self.redirectURL;
                    
                    if ([self.delegate respondsToSelector:@selector(uberOAuthWebViewController:didSucceedWithToken:)]) {
                        [self.delegate uberOAuthWebViewController:self didSucceedWithToken:token];
                    }
                }
            }
            
        }];
        [self.sessionTask resume];
        
        return NO;
    }
    
    return YES;
}


@end
