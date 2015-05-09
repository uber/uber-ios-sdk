//
//  UBOAuth2GrantFlowProtocol.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UBOAuth2GrantFlowDelegate;

@protocol UBOAuth2GrantFlow <NSObject>

@property (nonatomic, weak) id<UBOAuth2GrantFlowDelegate> delegate;

- (void)authorizeURL:(NSURL *)authURL withRedirectURL:(NSURL *)redirectURL scope:(NSString *)scope state:(NSString *)state params:(NSDictionary *)params;
- (void)handleRedirectURL:(NSURL *)redirectURL;

@end

@protocol UBOAuth2GrantFlowDelegate <NSObject>

- (void)grantFlow:(id<UBOAuth2GrantFlow>)grantFlow didAuthorize:(id)authObject;
- (void)grantFlow:(id<UBOAuth2GrantFlow>)grantFlow didFail:(NSError *)error;

@end
