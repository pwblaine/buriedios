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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    NSString *timestampString = [NSDateFormatter localizedStringFromDate:[self.capsule objectForKey:@"deliveryDate"] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    self->timestamp.text = timestampString;
    NSString *thought = [self.capsule objectForKey:@"thought"];
    self->thoughtContainer.editable = NO;
    self->thoughtContainer.selectable = YES;
    self->thoughtContainer.text = thought;
    
    PFFile *imageFile = [self.capsule objectForKey:@"image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        
    if (image)
    {
        self->imageContainer.image = image;
        self->theImage = [image thumbnailImage:32 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
        
        if (thought.length > 1)
        {
        }
        else if (self->theImage)
        {
            self->imageContainer.frame = CGRectMake(40.0f, 109.f, 240.0f, 356.0f);
            self->imageContainer.image = image;
            self->thoughtContainer.alpha = 0;
        }
       
    } else {
        self->thoughtContainer.frame = CGRectMake(40.0f, 109.f, 240.0f, 356.0f);
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
