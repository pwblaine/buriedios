//
//  LTForm.m
//  buried
//
//  Created by Patrick Blaine on 7/17/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTForm.h"

@implementation LTForm


-(BOOL)verifyField:(UITextField *)field{return YES;}

-(LTFormFieldType)fieldTypeOf:(UITextField *)field{return LTPasswordField;}

-(UIResponder *)fieldAfter:(UITextField *)currentField{return [UIResponder alloc];}

-(UIResponder *)fieldBefore:(UITextField *)currentField{return [UIResponder alloc];}

@end
