//
//  LTViewController.m
//  buried.
//
//  Created by Loftier Thoughts on 12/18/13.
//  Copyright (c) 2013 Loftier Thoughts. All rights reserved.
//

#import "LTViewController.h"


@interface LTViewController ()

@end

@implementation LTViewController

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

-(BOOL)validateFields
{
    
    // Get contents of fields
    NSString *email = emailTextField.text;
    NSString *thought = thoughtTextView.text;
    
    // create email validation regex & predicate
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    if ([emailTest evaluateWithObject:email] == NO) {
        // test that email is in correct format
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"your thought needs someone to find it...";
        return NO;
    } else if (thought.length == 0) {
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"nothing buried, nothing gained...";
        return NO;
    } else {
        messagesToUserLabel.textColor = [UIColor groupTableViewBackgroundColor];
        messagesToUserLabel.text = @"ready to bury";
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
    capsule[@"email"] = email;
    capsule[@"thought"] = thought;
    capsule[@"timeframe"] = timeframe;
    [self adjustCapsuleDeliveryForForTimeframe:capsule];
    capsule[@"sent"] = @NO;
    [capsule saveInBackground];
        
        NSLog(@"a thought was buried and will be delivered on day %@, interval %@",capsule[@"deliveryDay"],capsule[@"intervalOfDay"]);
        NSLog(@"current date is day %@, interval %@",[self getDaysSinceLaunch],[self getIntervalOfDay]);
        
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

-(PFObject *)adjustCapsuleDeliveryForForTimeframe:(PFObject *)capsule
{
    capsule[@"intervalOfDay"] = @((arc4random() % 47)+1);
    NSNumber *deliveryDay;
    
    if ([capsule[@"timeframe"] isEqualToString:@"soon"])
        capsule[@"intervalOfDay"] = @((arc4random() % ([[self getNumberOfIntervalsInADay] intValue]-[[self getIntervalOfDay] intValue]))+[[self getIntervalOfDay] intValue]);
    else if ([capsule[@"timeframe"] isEqualToString:@"later"])
        deliveryDay = @((arc4random() % 14)+7);
    else if ([capsule[@"timeframe"] isEqualToString:@"someday"])
        deliveryDay = @((arc4random() % 60)+30);
    else if ([capsule[@"timeframe"] isEqualToString:@"forgotten"])
        deliveryDay = @((arc4random() % 65)+115);
    
    capsule[@"deliveryDay"] = @([deliveryDay intValue]+[[self getDaysSinceLaunch] intValue]);
    
    return capsule;
}

@end

/*
 Buried.js Submission Code
 
 buryIt: function(e) {
 e.preventDefault();
 
 console.log("Handling the submit");
 //add error handling here
 //gather the form data
 
 var self = this;
 
 var data = {};
 data.sent = false;
 data.email = this.$("#email").val();
 data.thought = this.$("#thought-to-bury").val();
 
 if (!validateEmail(data.email))
 {
 $("#confirmation").html("<p>Your thought will be lost without someone to find it...</p>").show();
 $("#confirmation").css("color","#6F0008");
 }
 else if (data.thought == "")
 {
 $("#confirmation").html("<p>Nothing buried, nothing gained...</p>").show();
 $("#confirmation").css("color","#6F0008");
 } else
 {
 var AppVariables =  Parse.Object.extend("appVariables");
 var appVariables =  new AppVariables();
 var currentDay = 0;
 var currentInterval = 1;
 var query = new Parse.Query("appVariables");
 
 query.equalTo("objectId","Sid4J1kfn5");
 
 query.find({
 success: function(result) {
 appVariables = result[0];
 currentDay = appVariables.get("daysSinceLaunch");
 currentInterval = appVariables.get("intervalOfDay");
 
 data.intervalOfDay = Math.floor((Math.random()*48)+1);
 
 
 if (this.$("#soon").is(':checked'))
 {data.timeframe="soon";
 data.deliveryDay = 0;
 data.intervalOfDay = Math.floor((Math.random()*(48-currentInterval))+1)+currentInterval;}
 else if (this.$("#later").is(':checked'))
 {data.timeframe = "later";
 data.deliveryDay = Math.floor((Math.random()*14)+7);}
 else if (this.$("#someday").is(':checked'))
 {data.timeframe = "someday";
 data.deliveryDay = Math.floor((Math.random()*60)+30);}
 else
 {data.timeframe = "forgotten";
 data.deliveryDay = Math.floor((Math.random()*65)+115);};
 
 var Capsule = Parse.Object.extend("capsule");
 var capsule = new Capsule();
 
 data.deliveryDay += currentDay;
 
 capsule.save({email:data.email,thought:data.thought,timeframe:data.timeframe,sent:data.sent,deliveryDay:data.deliveryDay,intervalOfDay:data.intervalOfDay},
 {success: function(capsule) {
 // Execute any logic that should take place after the object is saved.
 console.log('New object created with objectId: ' + capsule.id);
 },
 error: function(capsule, error) {
 // Execute any logic that should take place if the save fails.
 // error is a Parse.Error with an error code and description.
 alert('Failed to create new object, with error code: ' + error.description);
 }
 });
 var time = new Date();
 console.log("Capsule buried at "+time);
 console.log("email:"+data.email);
 console.log("thought: "+data.thought);
 console.log("timeframe: "+data.timeframe);
 console.log("deliveryDay: "+data.deliveryDay);
 console.log("intervalOfDay: "+data.intervalOfDay);
 console.log("currentDay: "+currentDay);
 console.log("currentInterval: "+currentInterval);
 
 var nextSubmission = new BuryItView();
 self.undelegateEvents();
 delete self;
 $("#confirmation").html("<p>Your thought has been buried...</p>").show();
 $("#confirmation").css("color","#196024");
 
 }, error: function() {
 }});
 }
 
 
 return false;
 },
 
 render: function() {
 this.$el.html(_.template($("#bury-it-template").html()));
 this.delegateEvents();
 }
 });
*/