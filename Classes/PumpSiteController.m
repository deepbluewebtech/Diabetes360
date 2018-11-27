//
//  PumpSiteController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PumpSiteController.h"

@interface PumpSiteController()
-(void)turnOnReminder;
@end

@implementation PumpSiteController

@synthesize reminderSwitch, reminderTimePicker, pumpSiteInterval;
@synthesize settings;
@synthesize numericChars;

@synthesize activeField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Pump Site";

    numFmt = [[NSNumberFormatter alloc] init];
    self.numericChars = [NSCharacterSet decimalDigitCharacterSet];
    
    NSDate *aDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit |
                                                    NSMonthCalendarUnit |
                                                    NSDayCalendarUnit |
                                                    NSHourCalendarUnit | 
                                                    NSMinuteCalendarUnit) fromDate:aDate];
    [comps setHour:23];
    [comps setMinute:59];

    self.reminderTimePicker.maximumDate = [calendar dateFromComponents:comps];
    self.reminderTimePicker.minuteInterval = [settings.datePickerInterval intValue];
    self.pumpSiteInterval.text = [settings.pumpSiteInterval stringValue];
    self.reminderSwitch.on = [settings.pumpSiteAlert boolValue];

    [reminderSwitch addTarget:self action:@selector(reminderChanged) forControlEvents:UIControlEventValueChanged];
    [reminderTimePicker addTarget:self action:@selector(turnOnReminder) forControlEvents:UIControlEventValueChanged];

    self.activeField = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.reminderTimePicker.date = settings.pumpSiteTime;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    settings.pumpSiteAlert = [NSNumber numberWithBool:reminderSwitch.on];
    settings.pumpSiteTime = self.reminderTimePicker.date;
    settings.pumpSiteInterval = [numFmt numberFromString:self.pumpSiteInterval.text];
    [settings saveSettings];
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pumpSiteInterval.textAlignment = NSTextAlignmentCenter;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
    
    settings.pumpSiteInterval = [numFmt numberFromString:pumpSiteInterval.text]; // this is only text field for now will need if/else if more added.
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string length] > 0 && ![numericChars characterIsMember:[string characterAtIndex:0]])
        return NO;

    [self turnOnReminder];

    return YES;
    
}

-(void)reminderChanged {
    
    settings.pumpSiteAlert = [NSNumber numberWithBool:reminderSwitch.on];
    
}

-(void)turnOnReminder {
    
    reminderSwitch.on = YES;
    [self reminderChanged];
    
}

#pragma mark - TextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.activeField = textField;
    self.activeField.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];

    textField.keyboardType = UIKeyboardTypeDecimalPad;
    
}
                                                    

#pragma mark - Done Button


- (void)doneButton:(id)sender {
    
    [self.activeField resignFirstResponder];
    activeField = nil;
    settings.accessoryView = nil;

}



@end
