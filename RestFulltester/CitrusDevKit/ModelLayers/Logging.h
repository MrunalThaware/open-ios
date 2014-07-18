//
//  Logging.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 28/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#ifndef RestFulltester_Logging_h
#define RestFulltester_Logging_h
#import "DDLog.h"


#define ENTRY_LOG      DDLogVerbose(@"%s ENTRY ", __PRETTY_FUNCTION__);
#define EXIT_LOG       DDLogVerbose(@"%s EXIT ", __PRETTY_FUNCTION__);
#define ERROR_EXIT_LOG DDLogError(@"%s ERROR EXIT", __PRETTY_FUNCTION__);



#endif
