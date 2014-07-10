//
//  CTSProfileLayer.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 04/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSRestLayer.h"
#import "CTSRestIntergration.h"
#import "CTSContactUpdate.h"
#import "CTSProfileContactRes.h"
#import "CTSProfilePaymentRes.h"
#import "CTSPaymentDetailUpdate.h"
@protocol CTSProfileProtocol
/**
 *  called when client requests for contact information
 *
 *  @param contactInfo nil in case of error
 *  @param error       nil when successful
 */
- (void)contactInformation:(CTSProfileContactRes*)contactInfo
                     error:(NSError*)error;
/**
 *  called when client requests for payment information
 *
 *  @param contactInfo nil in case of error
 *  @param error       nil when succesful
 */
- (void)paymentInformation:(CTSProfilePaymentRes*)contactInfo
                     error:(NSError*)error;
/**
 *  when contact information is updated to server
 *
 *  @param error error if happned
 */
- (void)contactInfoUpdatedError:(NSError*)error;

/**
 *  when payment information is updated on server
 *
 *  @param error nil when successful
 */
- (void)paymentInfoUpdatedError:(NSError*)error;

@end

/**
 *  user profile related services
 */
@interface CTSProfileLayer : CTSRestIntergration {
}
@property(weak) id<CTSProfileProtocol> delegate;

/**
 *  update contact related information
 *
 *  @param contactInfo actual information to be updated
 */
- (void)updateContactInformation:(CTSContactUpdate*)contactInfo;

/**
 *  update payment related information
 *
 *  @param paymentInfo payment information
 */
- (void)updatePaymentInformation:(CTSPaymentDetailUpdate*)paymentInfo;

/**
 *  to request contact related information
 */
- (void)requestContactInformation;

/**
 *  request payment information
 */
- (void)requestPaymentInformation;
@end
