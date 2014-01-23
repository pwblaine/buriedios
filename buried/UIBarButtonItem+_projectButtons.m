//
//  UIBarButtonItem+_projectButtons.m
//  buried
//
//  Created by Patrick Blaine on 1/22/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "UIBarButtonItem+_projectButtons.h"

@implementation UIBarButtonItem (_projectButtons)

+(UIBarButtonItem*)customNavBarButtonWithTarget:(id)target action:(SEL)action withImage:(UIImage *)buttonImage
{
    
    //create the button and assign the image
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    
    //set the frame of the button to the size of the image (see note below)
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return customBarItem;
}

@end
