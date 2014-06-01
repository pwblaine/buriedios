//
//  LTThoughtDetailViewController.m
//  buried
//
//  Created by Patrick Blaine on 5/14/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTThoughtDetailViewController.h"
#import "LTBuryItViewController.h"

@interface LTThoughtDetailViewController ()

@end

@implementation LTThoughtDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self->thoughtView.text = self.theThought;
    
    // TODO in the future actions (sharing/saving) may be implemented, remove the icon for now
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self->topToolbar.items];
        [toolbarItems removeObject:self->actionButton];
        self->topToolbar.items = toolbarItems;
    
    // set top toolbar to transparent
    [self->topToolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionButtonTouched:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self.callingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)doneButtonTouched:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self.callingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)forwardButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    LTBuryItViewController *buryItViewController = [[LTBuryItViewController alloc] init];
    
    buryItViewController.capsuleThought = self.theThought;
    [self.navigationController pushViewController:buryItViewController animated:YES];
}

@end
