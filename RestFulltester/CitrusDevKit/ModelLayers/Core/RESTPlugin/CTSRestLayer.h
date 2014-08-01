//
//  RestLayer.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 21/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSPaymentDetailUpdate.h"
#import "CTSCoreProtocol.h"
@class CTSRestRegister;
@class RKObjectManager;

@protocol CTSRestLayerProtocol<NSObject>
@required
- (void)receivedObjectArray:(NSArray*)response
                    forPath:(NSString*)path
                  withError:(NSError*)error
                   withInfo:(NSString*)info;

@end

@interface CTSRestLayer : NSObject
@property(nonatomic, strong) RKObjectManager* objectManager;
@property(nonatomic, strong) id<CTSRestLayerProtocol> delegate;
@property(nonatomic, weak) id<CTSCoreProtocol> coreDelegate;

//+ (id)sharedRestLayer;
- (id)initWithBaseURL:(NSString*)baseURL;
- (void) register:(NSArray*)registrationDetails;
//- (void)requestObjectAtPath:(NSString*)path
//             withParameters:(NSDictionary*)queryParams
//                 withHeader:(NSDictionary*)headerValuePair
//                 withMethod:(HTTPMethod)method
//                   withInfo:(NSString *)info;

- (void)postObject:(id)object
            atPath:(NSString*)path
        withHeader:(NSDictionary*)headerValuePair
    withParameters:(NSDictionary*)queryParams
          withInfo:(NSString*)info;

- (void)getObjectAtPath:(NSString*)path
             withHeader:(NSDictionary*)headerValuePair
         withParameters:(NSDictionary*)queryParams
               withInfo:(NSString*)info;

- (void)putObject:(id)object
            atPath:(NSString*)path
        withHeader:(NSDictionary*)headerValuePair
    withParameters:(NSDictionary*)queryParams
          withInfo:(NSString*)info;

- (void)complexObjectRegister;
- (void)registerComplexRes;
- (void)changeBaseUrl:(NSString*)baseUrl;
- (void)paymentCardRequestMapping;
- (void)paymentResponseMapping;
- (void)tokenizedCardRequestMapping;
- (void)paymentNetbankingRequestMapping;
- (void)guestCheckoutPaymentMapping;
- (void)guestCheckoutPaymentResponseMapping;
- (void)registerPgSettingResponse;

@end
