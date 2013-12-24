//
//  LTBuryItViewController.m
//  buried.
//
//  Created by Mitch Solomon on 12/24/13.
//  Copyright (c) 2013 Loftier Thoughts. All rights reserved.
//

#import "LTBuryItViewController.h"

@interface LTBuryItViewController ()

@end

@implementation LTBuryItViewController

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
    
    /*Parse.com Object Submit Code
     PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
     testObject[@"foo"] = @"bar";
     [testObject saveInBackground];*/
    
	// Do any additional setup after loading the view, typically from a nib.
    
    errorColor = [UIColor colorWithRed:111/255.0f green:0/255.0f blue:8/255.0f alpha:1.0f];
    successColor = [UIColor colorWithRed:25/255.0f green:96/255.0f blue:36/255.0f alpha:1.0f];
    
    // Add logout navigation bar button
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            if (userData[@"name"]) {self.title = userData[@"name"];};
            
            /* TODO updateProfile - ADDED test for change of email*/
            [[PFUser currentUser] setObject:userData forKey:@"profile"];
            [[PFUser currentUser] setObject:userData[@"email"] forKey:@"email"];
            [[PFUser currentUser] saveInBackground];
            
            NSLog(@"User logged in with email: %@",[[PFUser currentUser ] email]);
            
            emailTextField.placeholder = userData[@"email"];
            
        }}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissKeyboardAndCheckInput:(id)sender
{
    [self.view endEditing:YES];
    [self validateFields];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboardAndCheckInput:NULL];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // dismisses keyboard when the return key is pressed
    
    if([text isEqualToString:@"\n"]) {
        [self dismissKeyboardAndCheckInput:NULL];
        return NO;
    }
    
    return YES;
}

-(void)clearMessageToUser
{
    messagesToUserLabel.text = @"";
}

-(BOOL)textFieldDidBeginEditing:(UITextField *)textField
{
    [self clearMessageToUser];
    return YES;
}

-(BOOL)textViewDidBeginEditing:(UITextView *)textView
{
    [self clearMessageToUser];
    return YES;
}

-(void)setMessageToUserForTimeframe {
messagesToUserLabel.textColor = [UIColor darkTextColor];
    if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"soon"])
messagesToUserLabel.text = @"your thought will unearth in the next 24 hours";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"later"])
        messagesToUserLabel.text = @"your thought will in during the next 2-7 days";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"someday"])
        messagesToUserLabel.text = @"your thought will in during the next 1-4 weeks";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"forgotten"])
        messagesToUserLabel.text = @"your thought will in during the next 1-3 months";
    else
    {
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"every journey needs to end sometime...";
    }
}

-(IBAction)timeframeClicked:(id)sender
{
    [self setMessageToUserForTimeframe];
}

-(BOOL)validateFields
{
    
    // Get contents of fields
    NSString *email = emailTextField.text;
    NSString *thought = thoughtTextView.text;
    
    // create email validation regex & predicate
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    if (([emailTest evaluateWithObject:email] == NO && ![email isEqualToString:@""]) || ([[[PFUser currentUser] email] isEqualToString:nil])) {
        // test that email is in correct format
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"your thought needs someone to find it...";
        return NO;
    } else if (thought.length == 0) {
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"nothing buried, nothing gained...";
        return NO;
    } else {
        [self setMessageToUserForTimeframe];
    }
    
    return YES;
}

-(IBAction)buryIt:(id)sender
{
    if ([self validateFields])
    {
        PFObject *capsule = [PFObject objectWithClassName:@"capsule"];
        NSString *email = emailTextField.text;
        NSString *thought = thoughtTextView.text;
        NSString *timeframe = [timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex];
        if ([email isEqualToString:@""])
            capsule[@"email"] = [[PFUser currentUser] email];
        else
            capsule[@"email"] = email;
        capsule[@"thought"] = thought;
        capsule[@"timeframe"] = timeframe;
        capsule[@"from"] = [[PFUser currentUser] email];
        [capsule saveInBackground];
        
        NSLog(@"current date is day %@, interval %@",[self getDaysSinceLaunch],[self getIntervalOfDay]);
        NSLog(@"a thought was buried by %@ and will be delivered %@",capsule[@"from"], capsule[@"timeframe"]);
        
        messagesToUserLabel.textColor = successColor;
        messagesToUserLabel.text = @"your thought has been buried...";
        
        emailTextField.text = @"";
        thoughtTextView.text = @"";
        
        [timeframeSegmentedControl setSelectedSegmentIndex:0];
    }
}

-(NSNumber *)getDaysSinceLaunch
{
    PFObject *appVariables = [self getAppVariables];
    NSNumber *daysSinceLaunch = appVariables[@"daysSinceLaunch"];
    return daysSinceLaunch;
}

-(NSNumber *)getIntervalOfDay
{
    PFObject *appVariables = [self getAppVariables];
    NSNumber *intervalOfDay = appVariables[@"intervalOfDay"];
    return intervalOfDay;
}

-(NSNumber *)getNumberOfIntervalsInADay
{
    PFObject *appVariables = [self getAppVariables];
    NSNumber *numberOfIntervalsInADay = appVariables[@"numberOfIntervalsInADay"];
    return numberOfIntervalsInADay;
}

-(PFObject *)getAppVariables
{
    PFQuery *query = [PFQuery queryWithClassName:@"appVariables"];
    return [query getFirstObject];
}


#pragma mark - ()

- (void)logoutButtonTouchHandler:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// Set received values if they are not nil and reload the table
- (void)updateProfile {NSLog(@"updateProfile run");}

@end