//
//  CTSUtility.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 17/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSUtility.h"
#import "CreditCard-Validator.h"
#import "CTSError.h"
#import "CTSAuthLayer.h"

#define ALPHABETICS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
#define NUMERICS @"0123456789"

#import "CTSAuthLayerConstants.h"
#define amex @[ @"34", @"37" ]
#define discover @[ @"60", @"62", @"64", @"65" ]
#define JCB @[ @"35" ]
#define DinerClub @[ @"30", @"36", @"38", @"39" ]
#define VISA @[ @"4" ]
#define MAESTRO \
@[            \
@"67",      \
@"56",      \
@"502260",  \
@"504433",  \
@"504434",  \
@"504435",  \
@"504437",  \
@"504645",  \
@"504681",  \
@"504753",  \
@"504775",  \
@"504809",  \
@"504817",  \
@"504834",  \
@"504848",  \
@"504884",  \
@"504973",  \
@"504993",  \
@"508125",  \
@"508126",  \
@"508159",  \
@"508192",  \
@"508227",  \
@"600206",  \
@"603123",  \
@"603741",  \
@"603845",  \
@"622018"   \
]
#define MASTER @[ @"5" ]

@implementation CTSUtility
+ (BOOL)validateCardNumber:(NSString*)number {
    return [CreditCard_Validator checkCreditCardNumber:number];
}

+ (NSString*)readFromDisk:(NSString*)key {
    LogDebug(@"Key %@ value %@",
             key,
             [[NSUserDefaults standardUserDefaults] valueForKey:key]);
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+ (void)saveToDisk:(id)data as:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeFromDisk:(NSString*)key {
    LogDebug(@"removing key %@", key);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary*)readSigninTokenAsHeader {
    return @{
             @"Authorization" : [NSString
                                 stringWithFormat:@" Bearer %@",
                                 [CTSUtility
                                  readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN]]
             };
}

+ (NSDictionary*)readOauthTokenAsHeader:(NSString*)oauthToken {
    return @{
             @"Authorization" : [NSString stringWithFormat:@" Bearer %@", oauthToken]
             };
}

+ (NSDictionary*)readVaultTokenAsHeader {
    if ([CTSAuthLayer.getBaseURL isEqualToString:PRODUCTION_BASEURL]) {
        return @{
                 @"Authorization" : [NSString stringWithFormat:@" Bearer %@", @"test-vault"]
                 };
    }else{
        return @{
                 @"Authorization" : [NSString stringWithFormat:@" Bearer %@", @"test-vault"]
                 };
    }
}

+ (NSDictionary*)readMetaDataCardAsHeader {
    return @{
             @"Authorization" : [NSString stringWithFormat:@" Basic %@", @"Y2l0cnVzOlF1YWVoN09v"]
             };
}

+ (NSString *)convertDictToJSONStringForDictionary:(NSDictionary *)dictionary {
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    return  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


+ (NSDictionary*)readSignupTokenAsHeader {
    return @{
             @"Authorization" : [NSString
                                 stringWithFormat:@" Bearer %@",
                                 [CTSUtility
                                  readFromDisk:MLC_SIGNUP_ACCESS_OAUTH_TOKEN]]
             };
}


+ (BOOL)validateEmail:(NSString*)candidate {
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate* emailTest =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+(BOOL)isEmail:(NSString *)string{
    if([string rangeOfString:@"@"].location != NSNotFound){
        return YES;
    }
    else{
        return NO;
    }
}


+ (BOOL)validateMobile:(NSString*)mobile {
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(?:0091|\\+91||91|0)[7-9][0-9]{9}$"];
    return [regex evaluateWithObject:mobile];
}

+ (NSString *)mobileNumberToTenDigit:(NSString*)mobile {
// remove hyphens
// first extra charecters
    // return number
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *invertedValidCharSet = [myCharSet invertedSet];
    
    
    NSArray* words = [mobile componentsSeparatedByCharactersInSet:invertedValidCharSet];
    NSString* proccesedNumber = [words componentsJoinedByString:@""];
    
    
    
    int extraCount =  (int)[proccesedNumber length] - 10;
    if(extraCount){
        proccesedNumber = [proccesedNumber substringFromIndex:extraCount];
    }
    
    return proccesedNumber;
}


+(NSString*)mobileNumberToTenDigitIfValid:(NSString *)number{
    NSString *proccessedNumber = nil;
    if([self validateMobile:number]){
        proccessedNumber = [self mobileNumberToTenDigit:number];
    }
    return proccessedNumber;
}



+ (BOOL)validateCVV:(NSString*)cvv cardNumber:(NSString*)cardNumber {
    if (cvv == nil)
        return YES;
    BOOL error = NO;
    if ([CreditCard_Validator checkCardBrandWithNumber:cardNumber] ==
        CreditCardBrandAmex) {
        if ([cvv length] == 4) {
            error = YES;
        }
    } else {
        if ([cvv length] == 3) {
            error = YES;
        }
    }
    return error;
}

+ (BOOL)validateExpiryDate:(NSString *)date {
    BOOL isValid = true;
    NSArray *subStrings = [date componentsSeparatedByString:@"/"];
    if ([subStrings count] < 2) {
        isValid = NO;
    }
    //yy string
    if([[subStrings objectAtIndex:1] length] != 4){
        isValid = NO;
    }
    //mm string
    if([[subStrings objectAtIndex:0] length] > 2 || [[subStrings objectAtIndex:0] length] < 1){
        isValid = NO;
    }
    
    return isValid;
}


+ (BOOL)validateExpiryDateMonth:(NSString *)date {
    
    NSArray *subStrings = [date componentsSeparatedByString:@"/"];
    
    int month = [[subStrings objectAtIndex:0] intValue];
    int year = [[subStrings objectAtIndex:1] intValue];
    
    int expiryYear = year;
    int expiryMonth = month;
    if (![self validateExpiryMonth:month year:year]) {
        return FALSE;
    }
    if (![self validateExpiryYear:year]) {
        return FALSE;
    }
    return [self hasMonthPassedYear:expiryYear month:expiryMonth];
}

+ (BOOL)validateExpiryMonth:(int)month year:(int)year {
    int expiryYear = year;
    int expiryMonth = month;
    if (expiryMonth == 0) {
        return FALSE;
    }
    return (expiryYear >= 1 && expiryMonth <= 12);
}

+(NSString*)correctExpiryDate:(NSString *)date{
    NSArray* subStrings = [date componentsSeparatedByString:@"/"];
    if ([subStrings count] < 2) {
        return date;
    }
    NSString *newDate = nil;
    if([[subStrings objectAtIndex:1] length] == 2 ){
        newDate = [NSString stringWithFormat:@"%@/20%@",[subStrings objectAtIndex:0],[subStrings objectAtIndex:1]];
    }else if([[subStrings objectAtIndex:1] length] == 4){
        return date;
    }
    return newDate;
}


+ (BOOL)validateExpiryYear:(int)year {
    int expiryYear = year;
    if (expiryYear == 0) {
        return FALSE;
    }
    return [self hasYearPassed:expiryYear];
    // return FALSE;
}

+ (BOOL)hasYearPassed:(int)year {
    int normalized = [self normalizeYear:year];
    NSCalendar* gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components =
    [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
    int currentyear = (int)[components year];
    return normalized >= currentyear;
}

+ (BOOL)hasMonthPassedYear:(int)year month:(int)month {
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDateComponents* components = [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateComponents* monthcomponent = [gregorian components:NSCalendarUnitMonth fromDate:[NSDate date]];
//    int currentYear = (int)[components year];
    int currentmonth = (int)[monthcomponent month];
//    int normalizeyear = [self normalizeYear:year];
    // Expires at end of specified month, Calendar month starts at 0
//    return [self hasYearPassed:year] ||
//    (normalizeyear == currentYear && month < (currentmonth + 1));
    
    return month >= (currentmonth);

}

+ (int)normalizeYear:(int)year {
    if (year < 100 && year >= 0) {
        NSCalendar* gregorian =
        [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents* components =
        [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger yearr = [components year];
        NSString* currentYear = [NSString stringWithFormat:@"%d", (int)yearr];
        
        NSString* prefix =
        [currentYear substringWithRange:NSMakeRange(0, currentYear.length - 2)];
        
        // year = Integer.parseInt(String.format(Locale.US, "%s%02d", prefix,
        // year));
        year = [[NSString stringWithFormat:@"%@%02d", prefix, year] intValue];
    }
    return year;
}

+ (BOOL)toBool:(NSString*)boolString {
    if ([boolString isEqualToString:@"false"])
        return NO;
    else
        return YES;
}

+ (NSString*)fetchCardSchemeForCardNumber:(NSString*)cardNumber {
    if (![CTSUtility validateCardNumber:cardNumber]) {
        return @"UNKNOWN";
        
    } else {
        if ([CTSUtility hasPrefixArray:amex cardNumber:cardNumber]) {
            return @"AMEX";
        } else if ([CTSUtility hasPrefixArray:discover cardNumber:cardNumber]) {
            return @"DISCOVER";
        } else if ([CTSUtility hasPrefixArray:JCB cardNumber:cardNumber]) {
            return @"JCB";
        } else if ([CTSUtility hasPrefixArray:DinerClub cardNumber:cardNumber]) {
            return @"DINERCLUB";
        } else if ([CTSUtility hasPrefixArray:VISA cardNumber:cardNumber]) {
            return @"VISA";
        } else if ([CTSUtility hasPrefixArray:MAESTRO cardNumber:cardNumber]) {
            return @"MAESTRO";
        } else if ([CTSUtility hasPrefixArray:MASTER cardNumber:cardNumber]) {
            return @"MCRD";
        }
        return @"UNKNOWN";
    }
}

+ (UIImage*)getSchmeTypeImage:(NSString*)cardNumber {
    // Card scheme validation
    if (cardNumber.length == 0) {
        return nil;
    } else {
        NSString* scheme = [CTSUtility fetchCardSchemeForCardNumber:cardNumber];
        if ([scheme caseInsensitiveCompare:@"amex"] == NSOrderedSame) {
            return [UIImage imageNamed:@"amex.png"];
        } else if ([scheme caseInsensitiveCompare:@"discover"] == NSOrderedSame) {
            return [UIImage imageNamed:@"discover.png"];
        } else if ([scheme caseInsensitiveCompare:@"maestro"] == NSOrderedSame) {
            return [UIImage imageNamed:@"maestro.png"];
        } else if ([scheme caseInsensitiveCompare:@"master"] == NSOrderedSame) {
            return [UIImage imageNamed:@"mastercard.png"];
        } else if ([scheme caseInsensitiveCompare:@"rupay"] == NSOrderedSame) {
            return [UIImage imageNamed:@"rupay.png"];
        } else if ([scheme caseInsensitiveCompare:@"visa"] == NSOrderedSame) {
            return [UIImage imageNamed:@"visa.png"];
        }
    }
    return 0;
}


+ (BOOL)hasPrefixArray:(NSArray*)array cardNumber:(NSString*)cardNumber {
    for (int i = 0; i < [array count]; i++) {
        if ([cardNumber hasPrefix:[array objectAtIndex:i]]) {
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary*)getResponseIfTransactionIsFinished:(NSData*)postData {
    // contains the HTTP body as in an HTTP POST request.
    NSString* dataString =
    [[NSString alloc] initWithData:postData encoding:NSASCIIStringEncoding];
    LogDebug(@"dataString %@ ", dataString);
    
    NSMutableDictionary* responseDictionary = nil;
    if ([dataString rangeOfString:@"TxStatus" options:NSCaseInsensitiveSearch]
        .location != NSNotFound) {
        responseDictionary = [[NSMutableDictionary alloc] init];
        
        NSArray* separatedByAMP = [dataString componentsSeparatedByString:@"&"];
        LogDebug(@"separated by & %@", separatedByAMP);
        
        for (NSString* string in separatedByAMP) {
            NSArray* separatedByEQ = [string componentsSeparatedByString:@"="];
            LogDebug(@"separatedByEQ %@ ", separatedByEQ);
            
            [responseDictionary setObject:[separatedByEQ objectAtIndex:1]
                                   forKey:[separatedByEQ objectAtIndex:0]];
        }
        LogDebug(@" final dictionary %@ ", responseDictionary);
    }
    return responseDictionary;
}


+ (BOOL)appendHyphenForCardnumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range{
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet]
          characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
    
    // Auto-add hyphen before appending 4rd or 7th digit
    if (range.length == 0 &&
        (range.location == 4 || range.location == 9 || range.location == 14)) {
        textField.text =
        [NSString stringWithFormat:@"%@-%@", textField.text, string];
        return NO;
    }
    
    // Delete hyphen when deleting its trailing digit
    if (range.length == 1 &&
        (range.location == 5 || range.location == 10 || range.location == 15)) {
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:@""];
        return NO;
    }
    return YES;
}


+ (BOOL)appendHyphenForMobilenumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range{
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet]
          characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
    
    // Auto-add hyphen before appending 4rd or 7th digit
    if (range.length == 0 &&
        (range.location == 3 || range.location == 7)) {
        textField.text =
        [NSString stringWithFormat:@"%@-%@", textField.text, string];
        return NO;
    }
    
    // Delete hyphen when deleting its trailing digit
    if (range.length == 1 &&
        (range.location == 4 || range.location == 8)) {
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:@""];
        return NO;
    }
    return YES;
}


+ (BOOL)enterNumericOnly:(NSString*)string{
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:NUMERICS];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)enterCharecterOnly:(NSString*)string{
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:ALPHABETICS];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}


+ (BOOL)validateCVVNumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range{
    // CVV validation
    // if amex allow 4 digits, if non amex only 3 should allowed.
    NSString* scheme = [CTSUtility fetchCardSchemeForCardNumber:textField.text];
    NSInteger textfieldLength = textField.text.length - range.length + string.length;
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:NUMERICS];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            if ([scheme caseInsensitiveCompare:@"amex"] == NSOrderedSame) {
                if (textfieldLength > 4) {
                    return NO;
                } else {
                    return YES;
                }
            } else if ([scheme caseInsensitiveCompare:@"amex"] !=
                       NSOrderedSame) {
                if (textfieldLength > 3) {
                    return NO;
                } else {
                    return YES;
                }
            }
            
        } else {
            return NO;
        }
    }
    return YES;
}


+ (NSString*)createTXNId {
    NSString* transactionId;
    long long CurrentTime =
    (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    transactionId = [NSString stringWithFormat:@"CTS%lld", CurrentTime];
    return transactionId;
}

+(BOOL)convertToBool:(NSString *)boolStr{
    if([boolStr caseInsensitiveCompare:@"true"]== NSOrderedSame){
        return YES;
    }
    else{
        return NO;
    }
}


+(NSError *)verifiyEmailOrMobile:(NSString *)userName{
    
    NSError *error = nil;
    
    if([CTSUtility isEmail:userName]){
        if (![CTSUtility validateEmail:userName]) {
            error = [CTSError getErrorForCode:EmailNotValid];
        
        }
    }else{
        userName = [CTSUtility mobileNumberToTenDigitIfValid:userName];
        if (!userName) {
            error = [CTSError getErrorForCode:MobileNotValid];
        }
    }
    return nil;
}

+(BOOL)validateBill:(CTSBill *)bill{
    if(bill == nil){
        return NO;
    }
    if(bill.amount == nil){
        return NO;
    }
    if(bill.requestSignature == nil){
        return NO;
        
    }
    if(bill.merchantAccessKey == nil){
        return NO;
    }
    if (bill.returnUrl == nil) {
        return NO;
    }
    return YES;
}

+ (NSDictionary*)getResponseIfTransactionIsComplete:(UIWebView *)webview {
    // contains the HTTP body as in an HTTP POST request.
    NSString *iosResponse = [webview stringByEvaluatingJavaScriptFromString:@"postResponseiOS();"];
    LogDebug(@"iosResponse %@",iosResponse);
    if(iosResponse == nil ){
        return nil;
    }
    else{
        NSError *error;
        NSDictionary *dictionary =  [NSJSONSerialization JSONObjectWithData: [iosResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options: NSJSONReadingMutableContainers
                                                                      error: &error];
        LogDebug(@" dictionary %@ ",dictionary);
        LogDebug(@" error %@ ",error);
        return dictionary;
    }
}

+(BOOL)isVerifyPage:(NSString *)urlString{
    BOOL isVerifyPage = [CTSUtility myContainsString:urlString];
    
    if(isVerifyPage){
        LogDebug(@"not logged in");
        isVerifyPage = YES;
    }
    return isVerifyPage;
}

+ (BOOL)myContainsString:(NSString*)other {
    NSRange range = [other rangeOfString:@"prepaid/pg/verify/"];
    return range.length != 0;
}


+(BOOL)stringContainsSpecialChars:(NSString *)toCheck exceptChars:(NSString*)exceptionChars exceptCharSet:(NSCharacterSet*)exceptionCharSet {
    BOOL isContain = NO;
    NSString *setString = [NSString stringWithFormat:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789%@",exceptionChars];
    NSMutableCharacterSet *setBase = [NSMutableCharacterSet characterSetWithCharactersInString:setString];
    if(exceptionCharSet)
        [setBase formUnionWithCharacterSet:exceptionCharSet];
    
    NSCharacterSet * set = [setBase invertedSet];
    
    if ([toCheck rangeOfCharacterFromSet:set].location != NSNotFound) {
        isContain = YES;
    }
    return isContain;
}

+(BOOL)islengthInvalid:(NSString*)string{
    if(string.length>255 || string.length == 0){
        return YES;
    }
    return NO;
}

+ (BOOL)isMaestero:(NSString *)number {
    if([[CTSUtility fetchCardSchemeForCardNumber:number] isEqualToString:@"MTRO"]){
        return YES;
    }
    return NO;
}

+ (BOOL)isAmex:(NSString *)number {
    if([[CTSUtility fetchCardSchemeForCardNumber:number] isEqualToString:@"AMEX"]){
        return YES;
    }
    return NO;
}


@end
