//
//  LTForm.h
//  buried
//
//  Created by Patrick Blaine on 7/17/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTForm : NSObject

typedef NS_ENUM(NSInteger, LTFormType) {
    LTSignUpForm,
    LTLoginForm
};

typedef NS_ENUM(NSInteger, LTFormFieldType) {
    LTEmailField,
    LTPasswordField,
    LTConfirmationField,
    LTUsernameField
};

@property NSArray *requiredFields;

@property NSSet *fields;

@property NSDictionary *fieldInfo;

@property NSArray *fieldOrdering;

-(BOOL)verifyField:(UITextField *)field;

-(LTFormFieldType)fieldTypeOf:(UITextField *)field;

-(UIResponder *)fieldAfter:(UITextField *)currentField;

-(UIResponder *)fieldBefore:(UITextField *)currentField;

@end