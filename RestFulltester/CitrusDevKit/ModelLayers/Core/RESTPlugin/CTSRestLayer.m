//
//  RestLayer.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 21/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSRestLayer.h"
#import <RestKit/RestKit.h>
#import "RestLayerConstants.h"
#import "CTSRestRegister.h"
#import "CTSOauthTokenRes.h"
#import "Logging.h"
#import "CTSRestError.h"
#import "CTSPaymentRequest.h"
#import "CTSProfilePaymentRes.h"
#import "CTSPaymentLayerConstants.h"
#import "CTSUserAddress.h"
#import "CTSPaymentTransactionRes.h"
#import "CTSGuestCheckout.h"
#import "CTSPaymentNetbankingRequest.h"
#import "CTSTokenizedCardPayment.h"
#import "CTSPgSettings.h"
#import "CTSNetbankingOption.h"
#import "CTSCreditCardOption.h"
#import "CTSDebitCardOption.h"
#import "CTSError.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@implementation CTSRestLayer

@synthesize delegate, coreDelegate, objectManager;
//+ (id)sharedRestLayer {
//  static CTSRestLayer* sharedInstance = nil;
//  static dispatch_once_t onceToken;
//  dispatch_once(&onceToken, ^{ sharedInstance = [[self alloc] init]; });
//  return sharedInstance;
//}
- (id)initWithBaseURL:(NSString*)baseURL {
  if (self = [super init]) {
    AFHTTPClient* client =
        [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);

    // [self addErrorMapping];
    [self errorMapping];
    __weak typeof(self) weakSelf = self;

    objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [objectManager.HTTPClient
        setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if ([weakSelf.coreDelegate
                    respondsToSelector:@selector(networkStatusChanged:)]) {
            }
        }];

    DDLogInfo(@" requestSerializationMIMEType %@",
              objectManager.requestSerializationMIMEType);
  }
  return self;
}

- (void)addErrorMapping {
  RKObjectMapping* errorMapping =
      [RKObjectMapping mappingForClass:[CTSRestError class]];
  // [errorMapping addAttributeMappingsFromArray:
  //    [NSArray arrayWithObjects:@"description", @"type", nil]];

  [errorMapping
      addPropertyMapping:[RKAttributeMapping
                             attributeMappingFromKeyPath:@"description"
                                               toKeyPath:@"description"]];
  [errorMapping addPropertyMapping:[RKAttributeMapping
                                       attributeMappingFromKeyPath:@"type"
                                                         toKeyPath:@"type"]];

  //[errorMapping addAttributeMappingsFromDictionary:<#(NSDictionary *)#>]
  RKResponseDescriptor* errorResponseDescriptor = [RKResponseDescriptor
      responseDescriptorWithMapping:errorMapping
                             method:RKRequestMethodAny
                        pathPattern:nil
                            keyPath:nil
                        statusCodes:RKStatusCodeIndexSetForClass(
                                        RKStatusCodeClassClientError)];

  //  RKObjectMapping* errorMappingTypeTwo =
  //      [RKObjectMapping mappingForClass:[CTSRestErrorTypeTwo class]];
  //  [errorMappingTypeTwo
  //      addAttributeMappingsFromArray:
  //          [NSArray arrayWithObjects:@"description", @"error", nil]];
  //  RKResponseDescriptor* errorResponseDescriptorTypeTwo =
  //  [RKResponseDescriptor
  //      responseDescriptorWithMapping:errorMappingTypeTwo
  //                             method:RKRequestMethodAny
  //                        pathPattern:nil
  //                            keyPath:nil
  //                        statusCodes:RKStatusCodeIndexSetForClass(
  //                                        RKStatusCodeClassClientError)];

  [objectManager addResponseDescriptor:errorResponseDescriptor];
  //[objectManager addResponseDescriptor:errorResponseDescriptorTypeTwo];
}

- (void)errorMapping {
  RKObjectMapping* errorMapping =
      [RKObjectMapping mappingForClass:[RKErrorMessage class]];

  [errorMapping
      addPropertyMapping:[RKAttributeMapping
                             attributeMappingFromKeyPath:@"type"
                                               toKeyPath:@"errorMessage"]];
  RKResponseDescriptor* errorResponseDescriptor = [RKResponseDescriptor
      responseDescriptorWithMapping:errorMapping
                        pathPattern:nil
                            keyPath:nil
                        statusCodes:RKStatusCodeIndexSetForClass(
                                        RKStatusCodeClassClientError)];
  [objectManager addResponseDescriptor:errorResponseDescriptor];
}

- (void)changeBaseUrl:(NSString*)baseUrl {
  [objectManager
      setHTTPClient:[AFHTTPClient
                        clientWithBaseURL:[NSURL URLWithString:baseUrl]]];
}
- (void)guestCheckoutPaymentResponseMapping {
  RKObjectMapping* guestTransactionMap =
      [RKObjectMapping mappingForClass:[CTSPaymentTransactionRes class]];
  [guestTransactionMap
      addAttributeMappingsFromDictionary:MLC_PAYMENT_TRANSACTION_RES_MAP];
  RKResponseDescriptor* guestPaymentDes = [RKResponseDescriptor
      responseDescriptorWithMapping:guestTransactionMap
                             method:[self getHTTPMethodFor:POST]
                        pathPattern:MLC_CITRUS_GUESTCHECKOUT_URL
                            keyPath:nil
                        statusCodes:RKStatusCodeIndexSetForClass(
                                        RKStatusCodeClassSuccessful)];
  [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];

  [objectManager addResponseDescriptor:guestPaymentDes];
}
- (void)paymentResponseMapping {
  RKObjectMapping* paymentTransactionMap =
      [RKObjectMapping mappingForClass:[CTSPaymentTransactionRes class]];
  [paymentTransactionMap
      addAttributeMappingsFromDictionary:MLC_PAYMENT_TRANSACTION_RES_MAP];

  RKResponseDescriptor* paymentProfileDes = [RKResponseDescriptor
      responseDescriptorWithMapping:paymentTransactionMap
                             method:[self getHTTPMethodFor:POST]
                        pathPattern:MLC_CITRUS_SERVER_URL
                            keyPath:nil
                        statusCodes:RKStatusCodeIndexSetForClass(
                                        RKStatusCodeClassSuccessful)];
  [objectManager addResponseDescriptor:paymentProfileDes];
}

- (void)complexObjectRegister {
  /*

   register complex objct with mapping


   RKObjectMapping object with class [class ctspaymentdetailupdate]
   rkobject mapping for payment option --> add mapping dict --> * type, *name,
   *ownerName, *number,
   *expiryDate, *scheme


   rkRelationship mapping
   ctspaymentdetailupdate addPropertymapping > rkRelationshipMapping : from to
   PaymentOptionMapping : to payment



   */
  RKObjectMapping* paymentDetailReq = [RKObjectMapping requestMapping];

  RKObjectMapping* paymentObjectMapping =
      [RKObjectMapping mappingForClass:[CTSPaymentOption class]];

  [paymentObjectMapping addAttributeMappingsFromDictionary:
                            MLC_PROFILE_UPDATE_PAYMENT_REQUEST_MAPPING];

  [paymentDetailReq addAttributeMappingsFromDictionary:@{ @"type" : @"type" }];
  [paymentDetailReq
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"paymentOptions"
                                   toKeyPath:@"paymentOptions"
                                 withMapping:[paymentObjectMapping
                                                     inverseMapping]]];

  RKRequestDescriptor* requestDes = [RKRequestDescriptor
      requestDescriptorWithMapping:paymentDetailReq
                       objectClass:[CTSPaymentDetailUpdate class]
                       rootKeyPath:nil
                            method:[self getHTTPMethodFor:PUT]];
  [objectManager addRequestDescriptor:requestDes];
}

- (void)registerPgSettingResponse {
  RKObjectMapping* pgSettingMap =
      [RKObjectMapping mappingForClass:[CTSPgSettings class]];
  RKObjectMapping* netbankingOptions =
      [RKObjectMapping mappingForClass:[CTSNetbankingOption class]];
  [netbankingOptions addAttributeMappingsFromDictionary:
                         MLC_PAYMENT_GET_PGSETTINGS_NETBANKING_REQ_MAPPING];

  RKObjectMapping* creditOptions =
      [RKObjectMapping mappingForClass:[CTSCreditCardOption class]];

  RKObjectMapping* debitCardOptions =
      [RKObjectMapping mappingForClass:[CTSDebitCardOption class]];

  [pgSettingMap
      addPropertyMapping:[RKRelationshipMapping
                             relationshipMappingFromKeyPath:@"netBanking"
                                                  toKeyPath:@"netBanking"
                                                withMapping:netbankingOptions]];

  [pgSettingMap
      addPropertyMapping:[RKRelationshipMapping
                             relationshipMappingFromKeyPath:@"creditCard"
                                                  toKeyPath:@"creditCard"
                                                withMapping:creditOptions]];

  [pgSettingMap
      addPropertyMapping:[RKRelationshipMapping
                             relationshipMappingFromKeyPath:@"debitCard"
                                                  toKeyPath:@"debitCard"
                                                withMapping:debitCardOptions]];

  RKResponseDescriptor* netbankingDes = [RKResponseDescriptor
      responseDescriptorWithMapping:pgSettingMap
                             method:[self getHTTPMethodFor:POST]
                        pathPattern:MLC_PAYMENT_GET_PGSETTINGS_PATH
                            keyPath:nil
                        statusCodes:RKStatusCodeIndexSetForClass(
                                        RKStatusCodeClassSuccessful)];

  [objectManager addResponseDescriptor:netbankingDes];
}

- (void)registerComplexRes {
  RKObjectMapping* paymentProfileMap =
      [RKObjectMapping mappingForClass:[CTSProfilePaymentRes class]];
  RKObjectMapping* paymentOptionsMapping =
      [RKObjectMapping mappingForClass:[CTSPaymentOption class]];

  [paymentOptionsMapping addAttributeMappingsFromDictionary:
                             MLC_PROFILE_GET_PAYMENT_RESPONSE_MAPPING];
  [paymentProfileMap
      addAttributeMappingsFromDictionary:MLC_PROFILE_GET_PAYMENT_RES_MAP];

  [paymentProfileMap
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"paymentOptions"
                                   toKeyPath:@"paymentOptions"
                                 withMapping:paymentOptionsMapping]];

  RKResponseDescriptor* paymentProfileDes = [RKResponseDescriptor
      responseDescriptorWithMapping:paymentProfileMap
                             method:[self getHTTPMethodFor:PUT]
                        pathPattern:MLC_PROFILE_UPDATE_PAYMENT_PATH
                            keyPath:nil
                        statusCodes:RKStatusCodeIndexSetForClass(
                                        RKStatusCodeClassSuccessful)];
  [objectManager addResponseDescriptor:paymentProfileDes];
}
- (void)tokenizedCardRequestMapping {
  RKObjectMapping* paymentamount = [RKObjectMapping requestMapping];
  [paymentamount addAttributeMappingsFromDictionary:MLC_PAYMENT];

  RKObjectMapping* amountMapping =
      [RKObjectMapping mappingForClass:[CTSAmount class]];
  [amountMapping addAttributeMappingsFromDictionary:@{
    @"currency" : @"currency",
    @"value" : @"value"
  }];

  RKObjectMapping* userdetailsMapping =
      [RKObjectMapping mappingForClass:[CTSUserDetails class]];
  [userdetailsMapping addAttributeMappingsFromDictionary:@{
    @"email" : @"email",
    @"firstName" : @"firstName",
    @"lastName" : @"lastName",
    @"mobileNo" : @"mobileNo"
  }];
  RKObjectMapping* addressMapping =
      [RKObjectMapping mappingForClass:[CTSUserAddress class]];
  [addressMapping addAttributeMappingsFromDictionary:@{
    @"city" : @"city",
    @"country" : @"country",
    @"state" : @"state",
    @"street1" : @"street1",
    @"street2" : @"street2",
    @"zip" : @"zip"
  }];
  [userdetailsMapping
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"address"
                                   toKeyPath:@"address"
                                 withMapping:[addressMapping inverseMapping]]];

  RKObjectMapping* paymentTokenMapping =
      [RKObjectMapping mappingForClass:[CTSPaymentToken class]];
  [paymentTokenMapping addAttributeMappingsFromDictionary:@{
    @"type" : @"type",
    @"id" : @"tokenid",
    @"cvv" : @"cvv"
  }];

  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"amount"
                                   toKeyPath:@"amount"
                                 withMapping:[amountMapping inverseMapping]]];
  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"paymentToken"
                                   toKeyPath:@"paymentToken"
                                 withMapping:[paymentTokenMapping
                                                     inverseMapping]]];
  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"userDetails"
                                   toKeyPath:@"userDetails"
                                 withMapping:[userdetailsMapping
                                                     inverseMapping]]];
  RKRequestDescriptor* requestDes = [RKRequestDescriptor
      requestDescriptorWithMapping:paymentamount
                       objectClass:[CTSTokenizedCardPayment class]
                       rootKeyPath:nil
                            method:RKRequestMethodPOST];
  [objectManager addRequestDescriptor:requestDes];
}
- (void)paymentNetbankingRequestMapping {
  RKObjectMapping* paymentamount = [RKObjectMapping requestMapping];
  [paymentamount addAttributeMappingsFromDictionary:MLC_PAYMENT];

  RKObjectMapping* amountMapping =
      [RKObjectMapping mappingForClass:[CTSAmount class]];
  [amountMapping addAttributeMappingsFromDictionary:@{
    @"currency" : @"currency",
    @"value" : @"value"
  }];

  RKObjectMapping* userdetailsMapping =
      [RKObjectMapping mappingForClass:[CTSUserDetails class]];
  [userdetailsMapping addAttributeMappingsFromDictionary:@{
    @"email" : @"email",
    @"firstName" : @"firstName",
    @"lastName" : @"lastName",
    @"mobileNo" : @"mobileNo"
  }];
  RKObjectMapping* addressMapping =
      [RKObjectMapping mappingForClass:[CTSUserAddress class]];
  [addressMapping addAttributeMappingsFromDictionary:@{
    @"city" : @"city",
    @"country" : @"country",
    @"state" : @"state",
    @"street1" : @"street1",
    @"street2" : @"street2",
    @"zip" : @"zip"
  }];
  [userdetailsMapping
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"address"
                                   toKeyPath:@"address"
                                 withMapping:[addressMapping inverseMapping]]];

  RKObjectMapping* paymentTokenMapping =
      [RKObjectMapping mappingForClass:[CTSPaymentToken class]];
  [paymentTokenMapping addAttributeMappingsFromDictionary:@{
    @"type" : @"type"
  }];

  RKObjectMapping* paymentOptionsMapping =
      [RKObjectMapping mappingForClass:[CTSPaymentOption class]];
  [paymentOptionsMapping
      addAttributeMappingsFromDictionary:MLC_PAYMENT_NETBANKINGOPTIONMAPPING];
  [paymentTokenMapping
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"paymentMode"
                                   toKeyPath:@"paymentMode"
                                 withMapping:[paymentOptionsMapping
                                                     inverseMapping]]];
  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"amount"
                                   toKeyPath:@"amount"
                                 withMapping:[amountMapping inverseMapping]]];
  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"paymentToken"
                                   toKeyPath:@"paymentToken"
                                 withMapping:[paymentTokenMapping
                                                     inverseMapping]]];
  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"userDetails"
                                   toKeyPath:@"userDetails"
                                 withMapping:[userdetailsMapping
                                                     inverseMapping]]];
  RKRequestDescriptor* requestDes = [RKRequestDescriptor
      requestDescriptorWithMapping:paymentamount
                       objectClass:[CTSPaymentNetbankingRequest class]
                       rootKeyPath:nil
                            method:RKRequestMethodPOST];
  [objectManager addRequestDescriptor:requestDes];
}

- (void)paymentCardRequestMapping {
  RKObjectMapping* paymentamount = [RKObjectMapping requestMapping];
  [paymentamount addAttributeMappingsFromDictionary:MLC_PAYMENT];

  RKObjectMapping* amountMapping =
      [RKObjectMapping mappingForClass:[CTSAmount class]];
  [amountMapping addAttributeMappingsFromDictionary:@{
    @"currency" : @"currency",
    @"value" : @"value"
  }];

  RKObjectMapping* userdetailsMapping =
      [RKObjectMapping mappingForClass:[CTSUserDetails class]];
  [userdetailsMapping addAttributeMappingsFromDictionary:@{
    @"email" : @"email",
    @"firstName" : @"firstName",
    @"lastName" : @"lastName",
    @"mobileNo" : @"mobileNo"
  }];
  RKObjectMapping* addressMapping =
      [RKObjectMapping mappingForClass:[CTSUserAddress class]];
  [addressMapping addAttributeMappingsFromDictionary:@{
    @"city" : @"city",
    @"country" : @"country",
    @"state" : @"state",
    @"street1" : @"street1",
    @"street2" : @"street2",
    @"zip" : @"zip"
  }];
  [userdetailsMapping
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"address"
                                   toKeyPath:@"address"
                                 withMapping:[addressMapping inverseMapping]]];

  RKObjectMapping* paymentTokenMapping =
      [RKObjectMapping mappingForClass:[CTSPaymentToken class]];
  [paymentTokenMapping addAttributeMappingsFromDictionary:@{
    @"type" : @"type"
  }];

  RKObjectMapping* paymentOptionsMapping =
      [RKObjectMapping mappingForClass:[CTSPaymentOption class]];
  [paymentOptionsMapping
      addAttributeMappingsFromDictionary:MLC_PAYMENT_CARDOPTIONMAPPING];
  [paymentTokenMapping
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"paymentMode"
                                   toKeyPath:@"paymentMode"
                                 withMapping:[paymentOptionsMapping
                                                     inverseMapping]]];
  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"amount"
                                   toKeyPath:@"amount"
                                 withMapping:[amountMapping inverseMapping]]];
  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"paymentToken"
                                   toKeyPath:@"paymentToken"
                                 withMapping:[paymentTokenMapping
                                                     inverseMapping]]];
  [paymentamount
      addPropertyMapping:
          [RKRelationshipMapping
              relationshipMappingFromKeyPath:@"userDetails"
                                   toKeyPath:@"userDetails"
                                 withMapping:[userdetailsMapping
                                                     inverseMapping]]];
  RKRequestDescriptor* requestDes = [RKRequestDescriptor
      requestDescriptorWithMapping:paymentamount
                       objectClass:[CTSPaymentRequest class]
                       rootKeyPath:nil
                            method:RKRequestMethodPOST];
  [objectManager addRequestDescriptor:requestDes];
}
- (void)guestCheckoutPaymentMapping {
  RKObjectMapping* payment = [RKObjectMapping requestMapping];
  [payment addAttributeMappingsFromDictionary:MLC_GUESTCHECKOUT_PAYMENT];
  RKRequestDescriptor* requestDes =
      [RKRequestDescriptor requestDescriptorWithMapping:payment
                                            objectClass:[CTSGuestCheckout class]
                                            rootKeyPath:nil
                                                 method:RKRequestMethodPOST];
  [objectManager addRequestDescriptor:requestDes];
}

/**
 *  this method has to be called by each layer that wants to use rest serivces
 *
 *  @param registrationDetails : details for registration
 */
- (void) register:(NSArray*)registrationDetails {
  for (CTSRestRegister* registrationDetail in registrationDetails) {
    if (registrationDetail.responseMapping != nil) {
      RKObjectMapping* responseMapping =
          [RKObjectMapping mappingForClass:registrationDetail.responseMapping
                                               .responseObjectType];
      [responseMapping
          addAttributeMappingsFromDictionary:registrationDetail.responseMapping
                                                 .parameterMapping];
      RKResponseDescriptor* responseDescriptor = [RKResponseDescriptor
          responseDescriptorWithMapping:responseMapping
                                 method:[self getHTTPMethodFor:
                                                  registrationDetail.httpMethod]
                            pathPattern:registrationDetail.path
                                keyPath:nil
                            statusCodes:RKStatusCodeIndexSetForClass(
                                            RKStatusCodeClassSuccessful)];
      [objectManager addResponseDescriptor:responseDescriptor];
    }

    if (registrationDetail.requestMapping != nil) {
      RKObjectMapping* requestMapping = [RKObjectMapping requestMapping];
      [requestMapping
          addAttributeMappingsFromDictionary:registrationDetail.requestMapping
                                                 .parameterMapping];
      RKRequestDescriptor* requestDescriptor = [RKRequestDescriptor
          requestDescriptorWithMapping:requestMapping
                           objectClass:registrationDetail.requestMapping
                                           .responseObjectType
                           rootKeyPath:nil
                                method:[self getHTTPMethodFor:registrationDetail
                                                                  .httpMethod]];
      [objectManager addRequestDescriptor:requestDescriptor];
    }
  }
}
/*
- (void)requestObjectAtPath:(NSString*)path
             withParameters:(NSDictionary*)queryParams
                 withHeader:(NSDictionary*)headerValuePair
                 withMethod:(HTTPMethod)method
                   withInfo:(NSString*)info;
{
  ENTRY_LOG

  __block NSDictionary* blockHeaderValuePair = headerValuePair;

  [self addHeaders:headerValuePair];
  [self printHeaders:headerValuePair];

  switch (method) {
    case GET: {
      [objectManager getObjectsAtPath:path
          parameters:queryParams
          success:^(RKObjectRequestOperation* operation,
                    RKMappingResult* mappingResult) {

              [self doResponsePostProccesing:mappingResult.array
                                        path:path
                                       error:nil
                                     headers:blockHeaderValuePair
                                        info:info];
          }
          failure:^(RKObjectRequestOperation* operation, NSError* error) {
              NSLog(@"What do you mean by 'there is no Result?': %@", error);
              [self doResponsePostProccesing:nil
                                        path:path
                                       error:error
                                     headers:blockHeaderValuePair
                                        info:info];
          }];
    } break;

    case POST: {
      [objectManager postObject:nil
          path:path
          parameters:queryParams
          success:^(RKObjectRequestOperation* operation,
                    RKMappingResult* mappingResult) {
              [self doResponsePostProccesing:mappingResult.array
                                        path:path
                                       error:nil
                                     headers:blockHeaderValuePair
                                        info:info];
          }
          failure:^(RKObjectRequestOperation* operation, NSError* error) {

              [self doResponsePostProccesing:nil
                                        path:path
                                       error:error
                                     headers:blockHeaderValuePair
                                        info:info];
          }];
    } break;

    case PUT: {
      [objectManager putObject:nil
          path:path
          parameters:queryParams
          success:^(RKObjectRequestOperation* operation,
                    RKMappingResult* mappingResult) {
              [self doResponsePostProccesing:mappingResult.array
                                        path:path
                                       error:nil
                                     headers:blockHeaderValuePair
                                        info:info];
          }
          failure:^(RKObjectRequestOperation* operation, NSError* error) {
              [self doResponsePostProccesing:nil
                                        path:path
                                       error:error
                                     headers:blockHeaderValuePair
                                        info:info];
          }];
    } break;
    default:
      DDLogError(@"NO METHOD FOUND %s ", __PRETTY_FUNCTION__);
      break;
  }

  EXIT_LOG
}
*/
- (void)putObject:(id)object
            atPath:(NSString*)path
        withHeader:(NSDictionary*)headerValuePair
    withParameters:(NSDictionary*)queryParams
          withInfo:(NSString*)info {
  __block NSDictionary* blockHeaderValuePair = headerValuePair;

  [self addHeaders:headerValuePair];
  [self decideMime:object];

  [objectManager putObject:object
      path:path
      parameters:queryParams
      success:^(RKObjectRequestOperation* operation,
                RKMappingResult* mappingResult) {
          DDLogInfo(@" STATUS_CODE %d ",
                    operation.HTTPRequestOperation.response.statusCode);
          [self doResponsePostProccesing:mappingResult.array
                                    path:path
                                   error:nil
                                 headers:blockHeaderValuePair
                                    info:info];
      }
      failure:^(RKObjectRequestOperation* operation, NSError* error) {
          DDLogInfo(@" STATUS_CODE %@ ",
                    operation.HTTPRequestOperation.response);
          error = [self proccesFailure:operation];
          [self doResponsePostProccesing:nil
                                    path:path
                                   error:error
                                 headers:blockHeaderValuePair
                                    info:info];
      }];
}

- (NSError*)proccesFailure:(RKObjectRequestOperation*)operation {
  NSError* error = nil;
  DDLogInfo(@" STATUS_CODE %@ ", operation.HTTPRequestOperation.response);
  if (![RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)
          containsIndex:operation.HTTPRequestOperation.response.statusCode]) {
    error = [CTSError
        getServerErrorWithCode:operation.HTTPRequestOperation.response
                                   .statusCode
                      withInfo:@{
                                 CITRUS_ERROR_DESCRIPTION_KEY : operation
                                     .HTTPRequestOperation.responseString
                               }];
  }

  DDLogInfo(
      @"STATUS_CODE_CASE %d",
      ![RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)
          containsIndex:operation.HTTPRequestOperation.response.statusCode]);

  return error;
}

- (void)postObject:(id)object
            atPath:(NSString*)path
        withHeader:(NSDictionary*)headerValuePair
    withParameters:(NSDictionary*)queryParams
          withInfo:(NSString*)info {
  __block NSDictionary* blockHeaderValuePair = headerValuePair;
  [self addHeaders:headerValuePair];
  [self decideMime:object];
  [objectManager postObject:object
      path:path
      parameters:queryParams
      success:^(RKObjectRequestOperation* operation,
                RKMappingResult* mappingResult) {
          [self doResponsePostProccesing:mappingResult.array
                                    path:path
                                   error:nil
                                 headers:blockHeaderValuePair
                                    info:info];
      }
      failure:^(RKObjectRequestOperation* operation, NSError* error) {
          DDLogInfo(@" STATUS_CODE %@ ",
                    operation.HTTPRequestOperation.response);
          error = [self proccesFailure:operation];
          [self doResponsePostProccesing:nil
                                    path:path
                                   error:error
                                 headers:blockHeaderValuePair
                                    info:info];
      }];
}

- (void)getObjectAtPath:(NSString*)path
             withHeader:(NSDictionary*)headerValuePair
         withParameters:(NSDictionary*)queryParams
               withInfo:(NSString*)info {
  __block NSDictionary* blockHeaderValuePair = headerValuePair;

  [self addHeaders:headerValuePair];

  [objectManager getObjectsAtPath:path
      parameters:queryParams
      success:^(RKObjectRequestOperation* operation,
                RKMappingResult* mappingResult) {
          DDLogInfo(@" STATUS_CODE %d ",
                    operation.HTTPRequestOperation.response.statusCode);
          [self doResponsePostProccesing:mappingResult.array
                                    path:path
                                   error:nil
                                 headers:blockHeaderValuePair
                                    info:info];
      }
      failure:^(RKObjectRequestOperation* operation, NSError* error) {
          NSLog(@"What do you mean by 'there is no Result?': %@", error);
          DDLogInfo(@" STATUS_CODE %@ ",
                    operation.HTTPRequestOperation.response);

          error = [self proccesFailure:operation];
          [self doResponsePostProccesing:nil
                                    path:path
                                   error:error
                                 headers:blockHeaderValuePair
                                    info:info];
      }];
}

- (void)decideMime:(id)object {
  if (object != nil) {
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;

  } else {
    objectManager.requestSerializationMIMEType = RKMIMETypeFormURLEncoded;
  }
}

- (void)doResponsePostProccesing:(NSArray*)responseArray
                            path:(NSString*)path
                           error:(NSError*)error
                         headers:(NSDictionary*)headers
                            info:(NSString*)info {
  DDLogInfo(@" responseArray %@ Count %lu",
            responseArray,
            (unsigned long)[responseArray count]);

  DDLogInfo(@"errorMessage: %@",
            [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey]);
  DDLogInfo(@"error: %@", error);
  DDLogInfo(@"error:localized des %@", [error localizedDescription]);

  [self removeHeaders:headers];
  [delegate receivedObjectArray:responseArray
                        forPath:path
                      withError:error
                       withInfo:info];
}

- (void)removeHeaders:(NSDictionary*)headers {
  for (NSString* key in [headers allKeys]) {
    [[objectManager HTTPClient] setDefaultHeader:key value:nil];
  }
}

- (void)addHeaders:(NSDictionary*)headers {
  for (NSString* key in [headers allKeys]) {
    DDLogInfo(@"key %@, header %@ ", key, [headers valueForKey:key]);
    [[objectManager HTTPClient] setDefaultHeader:key
                                           value:[headers valueForKey:key]];
  }
}

- (void)printHeaders:(NSDictionary*)headers {
  ENTRY_LOG
  for (NSString* key in [headers allKeys]) {
    DDLogInfo(@"key %@ header %@",
              key,
              [[objectManager HTTPClient] defaultValueForHeader:key]);
  }
  EXIT_LOG
}

- (RKRequestMethod)getHTTPMethodFor:(HTTPMethod)methodType {
  switch (methodType) {
    case GET:
      return RKRequestMethodGET;
      break;
    case POST:
      return RKRequestMethodPOST;
      break;
    case PUT:
      return RKRequestMethodPUT;
      break;
    case DELETE:
      return RKRequestMethodDELETE;
      break;
  }
}

@end
