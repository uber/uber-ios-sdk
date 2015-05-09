//
//  UBOAuth2Client.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UBOAuth2GrantFlowProtocol.h"

@interface UBOAuth2Client : NSObject

/*
 The OAuth 2 client ID.
 */
@property (nonatomic) NSString *clientID;

/*
 The OAuth 2 client secret.
 */
//@property (nonatomic) NSString *clientSecret;

/*
 The URL to authorize againt. Typically something like `https://someservice.com/oauth/authorize`.
 */
@property (nonatomic) NSURL *authURL;

@property (nonatomic) id<UBOAuth2GrantFlow> grantFlow;



/*
 The scope string you would like to be granted. Generally a space-separated list of scopes, but some providers use commas.
 */
//@property (nonatomic) NSString *scope;

/*
 The URI to redirect to after an authorization by the resource owner. Most providers require you register the redirect URI ahead of time.
 */
//@property (nonatomic) NSURL *redirectURI;

@end
