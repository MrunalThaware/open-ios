//
//  CTSUpdateUserProfileRes.h
//  CTS iOS Sdk
//
//  Created by Mukesh Patil on 23/06/15.
//  Copyright (c) 2015 Citrus. All rights reserved.
//

#import "JSONModel.h"

@interface CTSUpdateUserProfileRes : JSONModel
@property(strong)NSString<Optional>* responseCode;
@property(strong)NSString<Optional>* responseMessage;
@property(strong)NSDictionary<Optional>* responseData;
@end
