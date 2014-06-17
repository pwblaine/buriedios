//
//  LTPINVerificationViewController.m
//  buried
//
//  Created by Patrick Blaine on 6/8/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTPINVerificationViewController.h"
#import "LTAppDelegate.h"
#import "LTStartScreenViewController.h"

@interface LTPINVerificationViewController ()

@end

@implementation LTPINVerificationViewController

@synthesize lastLoggedInDisplayName, lastLoggedInFacebookId, lastLoggedInUserName, lastLoggedInUserId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewDidAppear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)submitButtonTouched:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self dismissViewControllerAnimated:YES completion:^{
// TODO temporatily this will be a way to progress until the PIN view is done, a linked FB account is current REQUIRED
        [(LTStartScreenViewController *)self.presentingViewController performSelector:@selector(continueToUnearthedWithFbLoginPermissionsAfterPINVerificationBy:) withObject:self];
    }];
}

-(IBAction)cancelButtonTouched:(id)sender
{
   NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"PIN view cancelled and dismissed");
    }];
}

@end
