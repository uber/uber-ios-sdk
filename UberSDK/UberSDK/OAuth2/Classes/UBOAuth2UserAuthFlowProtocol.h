//
//  UBOAuth2UserAuthFlowProtocol.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UBOAuth2UserAuthFlowDelegate;

@protocol UBOAuth2UserAuthFlow <NSObject>

@property (nonatomic, weak) id<UBOAuth2UserAuthFlowDelegate> delegate;

- (void)authorizeWithURL:(NSURL *)authURL interceptURL:(NSURL *)interceptURL;

@end


@protocol UBOAuth2UserAuthFlowDelegate <NSObject>

- (void)userAuthFlow:(id<UBOAuth2UserAuthFlow>)userAuthFlow didInterceptURL:(NSURL *)interceptedURL;

@end
