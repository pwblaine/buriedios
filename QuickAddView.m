//
//  QuickAddView.m
//  buried
//
//  Created by Patrick Blaine on 3/8/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "QuickAddView.h"

@implementation QuickAddView

@synthesize grassButton = _grassButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [QuickAddView loadViewForQuickAddView];
        [self setFrame:frame];
    }
    return self;
}

+ (id)loadViewForQuickAddView
{
    QuickAddView *view = [[[NSBundle mainBundle] loadNibNamed:@"QuickAddView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([view isKindOfClass:[QuickAddView class]])
        return view;
    else
        return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
