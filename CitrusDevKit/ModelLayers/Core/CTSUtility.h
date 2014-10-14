//
//  CTSUtility.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 17/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSOauthTokenRes.h"
#import "CTSAuthLayerConstants.h"
#import "UserLogging.h"

@interface CTSUtility : NSObject
+ (NSString*)readFromDisk:(NSString*)key;
+ (void)saveToDisk:(id)data as:(NSString*)key;

+ (NSDictionary*)readSigninTokenAsHeader;
+ (NSDictionary*)readSignupTokenAsHeader;
+ (NSDictionary*)readOauthTokenAsHeader:(NSString*)oauthToken;
+ (void)removeFromDisk:(NSString*)key;
+ (BOOL)validateEmail:(NSString*)email;
+ (BOOL)validateMobile:(NSString*)mobile;
+ (BOOL)validateCardNumber:(NSString*)number;
+ (BOOL)validateExpiryDate:(NSString*)date;
+ (BOOL)validateCVV:(NSString*)cvv cardNumber:(NSString*)cardNumber;
+ (BOOL)toBool:(NSString*)boolString;
+ (NSString*)fetchCardSchemeForCardNumber:(NSString *)cardNumber;
+ (NSDictionary*)getResponseIfTransactionIsFinished:(NSData*)postData;
+ (UIImage*)getSchmeTypeImage:(NSString*)cardNumber;
+ (BOOL)appendHyphenForCardnumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (BOOL)appendHyphenForMobilenumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (BOOL)enterNumericOnly:(NSString*)string;
+ (BOOL)enterCharecterOnly:(NSString*)string;
+ (BOOL)validateCVVNumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (BOOL)validateCVVNumber:(UITextField*)textField cardNumber:(NSString*)cardNumber replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range;
+ (NSString*)createTXNId;
@end
