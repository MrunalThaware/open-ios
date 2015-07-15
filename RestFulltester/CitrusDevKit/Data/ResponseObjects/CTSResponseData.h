//
//  CTSResponseData.h
//  CitrusPay-iOS-SDK
//
//  Created by Mukesh Patil on 26/06/15.
//  Copyright (c) 2015 CitrusPay. All rights reserved.
//

#import "JSONModel.h"

@interface CTSResponseData : JSONModel
@property(strong)NSString<Optional>* responseCode;
@property(strong)NSString<Optional>* responseMessage;
@property(strong)NSDictionary<Optional>* responseData;

+ (CTSResponseData*)returnCTSResponseDataObjectModel:(id)JSON;
@end
