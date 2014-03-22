//
//  LTCapsuleViewController.m
//  buried
//
//  Created by Patrick Blaine on 3/4/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTCapsuleViewController.h"
#import "UIBarButtonItem+_projectButtons.h"
#import "LTPhotoDetailViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface LTCapsuleViewController ()

@end

@implementation LTCapsuleViewController

@synthesize capsule;

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
    fullScreenThought.alpha = 0;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = backButton;
    NSString *toBeTitle = @"";
    
    NSString *from = [self.capsule objectForKey:@"from"];
    
    if (from.length > 0)
        toBeTitle = from;
    else
        toBeTitle = @"Capsule";
    
    PFUser *fromUser = [self.capsule objectForKey:@"fromUser"];
    [fromUser fetchIfNeeded];
    NSString *displayName = [fromUser objectForKey:@"displayName"];
    if (displayName.length > 0)
            toBeTitle = displayName;
    
    self.title = toBeTitle;
    
    NSString *timestampString = [NSDateFormatter localizedStringFromDate:self.capsule.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    self->timestamp.text = timestampString; // timestamp states created at date
    NSString *thought = [self.capsule objectForKey:@"thought"];
    self->thoughtContainer.editable = NO;
    self->thoughtContainer.selectable = YES;
    self->thoughtContainer.text = thought;
    self->fullScreenThought.text = thought;
    self->fullScreenThought.alpha = 1;
    self->fullScreenThought.editable = NO;
    self->fullScreenThought.textAlignment = NSTextAlignmentCenter;
    self->thoughtContainer.alpha = 0;
    
    PFFile *imageFile = [self.capsule objectForKey:@"image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        
        if (thought.length > 1 && image)
        {
            self->imageContainer.image = image;
            self->fullScreenThought.alpha = 0;
            self->thoughtContainer.alpha = 1;
        }
        else if (image)
        {
            self->imageContainer.frame = CGRectMake(40.0f, 109.0f, 240.0f, 356.0f);
            self->imageContainer.image = image;
            self->thoughtContainer.alpha = 0;
            self->fullScreenThought.alpha = 0;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)backButtonTouchHandler:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageButtonTapped:(id)sender
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    self->thoughtContainer.alpha = 0;
    self->imageContainer.alpha = 1;

}

- (void)doneButtonTapped:(id)sender
{
    self->thoughtContainer.alpha = 1;
    self->imageContainer.alpha = 0;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customNavBarButtonWithTarget:self action:@selector(imageButtonTapped:) withImage:self->theImage];
}

@end
