//
//  LTThoughtDetailViewController.m
//  buried
//
//  Created by Patrick Blaine on 5/14/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTThoughtDetailViewController.h"
#import "LTBuryItViewController.h"
#import "LTCapsuleViewController.h"

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
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // Do any additional setup after loading the view from its nib.
    self->thoughtView.text = self.theThought;
    
    // TODO in the future actions (sharing/saving) may be implemented, remove the icon for now
    /*
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self->topToolbar.items];
        [toolbarItems removeObject:self->actionButton];
        self->topToolbar.items = toolbarItems;
    */
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
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)doneButtonTouched:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)forwardButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"forward to new capsule" message:@"which would you like to forward to start a new capsule with..." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"just this", @"all of it", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // only occurs in a buryItView currently
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);        if (buttonIndex != alertView.cancelButtonIndex)
        {
            // code for the forwarding alert
            LTBuryItViewController *buryItViewController = [[LTBuryItViewController alloc] init];
            buryItViewController.capsuleThought = [self.theThought copy];
            if (buttonIndex == alertView.firstOtherButtonIndex + 1)
                buryItViewController.capsuleImage = [[(LTCapsuleViewController *)self.callingViewController theImage] copy];
            
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [self.callingViewController.navigationController pushViewController:buryItViewController animated:YES];
            }];
        }
    
}

@end
