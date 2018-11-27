//
//  DailySchedDtlController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DailySchedDtlController.h"
#import "InsulinBrand.h"
#import "InsulinBrandsController.h"


#define NAME            0
#define BEGIN_TIME      1
#define END_TIME        2
#define REMINDER        3
#define ANY_TIME        4
#define INSULIN_DOSE    5
#define INSULIN_BRAND   6
#define CARB_ROW        7

#define ROW_COUNT       8

@interface DailySchedDtlController () 


- (void) showDatePicker:(NSDate *)theDate;
- (void) showInsulinPicker:(id)sender;
- (void) clearAllEditing;
- (void) closeButton:(id)sender;
- (CGRect)pickerFrameWithSize:(CGSize)size;

@end

@implementation DailySchedDtlController

@synthesize schedule;
@synthesize settings;
@synthesize selectedIndexPath;

@synthesize nameCell;
@synthesize beginTimeCell;
@synthesize endTimeCell;
@synthesize reminderCell;
@synthesize carbsCell;
@synthesize anyTimeCell;
@synthesize insulinDoseCell;
@synthesize insulinBrandCell;

@synthesize name;
@synthesize carbsToIngest;
@synthesize reminder;
@synthesize complexCarb;
@synthesize beginTime;
@synthesize endTime;
@synthesize anyTime;
@synthesize insulinDose;
@synthesize insulinBrand;

@synthesize numericChars;

@synthesize activeField;

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        selectedIndexPath = [[NSIndexPath alloc] init];
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
    
    dateFmt = [[NSDateFormatter alloc] init];
    [dateFmt setDateStyle:NSDateFormatterNoStyle];
    [dateFmt setTimeStyle:NSDateFormatterShortStyle];
    
    numFmt = [[NSNumberFormatter alloc] init];
    
    self.numericChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    
    [reminder addTarget:self action:@selector(reminderChanged) forControlEvents:UIControlEventValueChanged];
    [anyTime addTarget:self action:@selector(anyTimeChanged) forControlEvents:UIControlEventValueChanged];
    [complexCarb addTarget:self action:@selector(complexCarbChanged) forControlEvents:UIControlEventValueChanged];
    
    if (schedule.name) {
        self.title = @"Edit Item";
    } else {
        self.title = @"Add Item";
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddScheduleItem)];
        self.navigationItem.leftBarButtonItem = buttonItem;
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveScheduleItem)];
        self.navigationItem.rightBarButtonItem = buttonItem;
        //need to setup something in SettingsClass to initialize these.  That whole class needs rework
        schedule.beginTime = [NSDate date];
        schedule.endTime = schedule.beginTime;
        schedule.carbToIngest = [NSNumber numberWithInt:0];
        schedule.insulinDose = [NSNumber numberWithInt:0];
        schedule.InsulinBrand = nil;
        schedule.complexCarb = [NSNumber numberWithBool:NO];
        schedule.reminder = [NSNumber numberWithBool:YES];
        schedule.anyTime = [NSNumber numberWithBool:NO];
    }

    self.tableView.backgroundView = settings.tableViewBgView;

    self.activeField = nil;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.name.textAlignment = UITextAlignmentRight;
    self.carbsToIngest.textAlignment = UITextAlignmentCenter;
    self.insulinDose.textAlignment = UITextAlignmentCenter;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (datePicker) {
        [datePicker removeFromSuperview];
    }
    
    if (insulinPicker) {
        [insulinPicker removeFromSuperview];
    }
    
    [settings saveSettings];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([schedule.insulinDose intValue] == 0 && schedule.InsulinBrand && [schedule.reminder boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"There is a reminder set for %@\nthat has %@ insulin but no dose.\nReminder will fire,\nbut you may want to set the \ndose at %@",schedule.name, schedule.InsulinBrand.brandName, schedule.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    if ([schedule.insulinDose intValue] != 0 && !schedule.InsulinBrand && [schedule.reminder boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"There is a reminder set for %@\nthat has %@ units of insulin\nbut no type of insulin.\nReminder will fire,\nbut you may want to set the \ntype of insulin at %@",schedule.name, [settings formatToRoundedString:schedule.insulinDose accuracy:nil], schedule.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - textField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == name) return YES;
    
    if ([string length] > 0 && ![numericChars characterIsMember:[string characterAtIndex:0]])
        return NO;
    
    if ([string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location != NSNotFound) {
        return NO;
    }
    
    return YES;
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    
    if (datePicker || insulinPicker) [self closeButton:nil];
    
    if (textField == insulinDose && [schedule.insulinDose intValue] == 0) {
        insulinDose.text = @"";
    }
    
    
    self.activeField = textField;
    [self.activeField setValue:settings.accessoryView forKey:@"inputAccessoryView"];
    [settings.theCloseButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];

    

    if (textField == name) {
        textField.keyboardType = UIKeyboardTypeDefault;
    } else {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }
}

-(void) textFieldDidEndEditing:(UITextField *)textField {

         if (textField == name) schedule.name = self.name.text;
    else if (textField == carbsToIngest) schedule.carbToIngest = [numFmt numberFromString:self.carbsToIngest.text];
    else if (textField == insulinDose)   schedule.insulinDose = [numFmt numberFromString:self.insulinDose.text];

    [settings saveSettings];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ROW_COUNT;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[settings setView:self.tableView toColorScheme:nil];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.row) {
        case NAME:
            self.name.text = schedule.name;
            return nameCell;
            break;
        case BEGIN_TIME:
            beginTime.text = [dateFmt stringFromDate:schedule.beginTime];
            return beginTimeCell;
            break;
        case END_TIME:
            endTime.text = [dateFmt stringFromDate:schedule.endTime];
            return endTimeCell;
            break;
        case ANY_TIME:
            anyTime.on = [schedule.anyTime boolValue];
            return anyTimeCell;
            break;
        case REMINDER:
            reminder.on = [schedule.reminder boolValue];
            return reminderCell;
            break;
        case CARB_ROW:
            self.carbsToIngest.text = [schedule.carbToIngest stringValue];
            self.complexCarb.on = [schedule.complexCarb boolValue];
            return carbsCell;
            break;
        case INSULIN_BRAND:
            self.insulinBrand.text = (schedule.InsulinBrand ? schedule.InsulinBrand.brandName : @"Not Set");
            return insulinBrandCell;
            break;
        case INSULIN_DOSE:
            self.insulinDose.text = [settings formatToRoundedString:schedule.insulinDose accuracy:nil];
            return insulinDoseCell;
            break;
        default:
            break;
    }
    
    return nil;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self clearAllEditing];
    
    self.selectedIndexPath = indexPath;
    
    beginTime.textColor = [UIColor blackColor];
    endTime.textColor = [UIColor blackColor];

    if (indexPath.row == BEGIN_TIME) {
        beginTime.textColor = [UIColor redColor];
        if (!datePicker)
            [self showDatePicker:schedule.beginTime];
        else
            datePicker.date = schedule.beginTime;
    } else if (indexPath.row == END_TIME) {
        endTime.textColor = [UIColor redColor];
        if (insulinPicker) [self closeButton:nil];
        if (!datePicker)
            [self showDatePicker:schedule.endTime];
        else
            datePicker.date = schedule.endTime;
    } else if (indexPath.row == INSULIN_DOSE) {
        [insulinDose becomeFirstResponder];
    } else if (indexPath.row == INSULIN_BRAND) {
        if (datePicker) [self closeButton:nil];
        if (!insulinPicker)
            [self showInsulinPicker:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - Pickers

- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
                                   screenRect.size.height - 42.0 - size.height,
                                   size.width,
                                   size.height);
	return pickerRect;
}


- (void)showDatePicker:(NSDate *)theDate {
    
    if (datePicker) return;
    
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	
	datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    datePicker.minuteInterval = [settings.datePickerInterval intValue];
    datePicker.datePickerMode = UIDatePickerModeTime;
    [datePicker addTarget:self action:@selector(updateTime:) forControlEvents:UIControlEventValueChanged];
    
    if ([theDate isEqualToDate:schedule.beginTime]) {
        datePicker.date = schedule.beginTime;
    } else if ([theDate isEqualToDate:schedule.endTime]) {
        datePicker.date = schedule.endTime;
    }
    
    self.activeField = beginTime;
    beginTime.inputView = datePicker;
    beginTime.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];

    beginTime.canBecomeFirstResponder = YES;
    [beginTime becomeFirstResponder];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  //will need to modify this to check alertView passed in if others are added to app that have actionable buttons
{
    
    if (buttonIndex == 0) {
        return;
    }
    
    InsulinBrandsController *controller = [[InsulinBrandsController alloc] initWithNibName:@"InsulinBrandsController" bundle:nil];
    controller.settings = self.settings;
    controller.fromSettings = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}

-(void)showInsulinPicker:(id)sender {
    
    if (![settings.prescribedInsulinArray count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Prescribed Insulin" message:@"Insulin that is prescribed to you is not set up yet." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Go There", nil];
        [alert show];
        
        return;
    }
    
    if (insulinPicker) return;
    
    [self clearAllEditing];
    [self closeButton:nil];

	insulinPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
    insulinPicker.hidden = NO;
	insulinPicker.showsSelectionIndicator = YES;	
    
	// this view controller is the data source and delegate
	insulinPicker.delegate = self;
	insulinPicker.dataSource = self;
    
    if (schedule.InsulinBrand) {
        int i=0;
        for (InsulinBrand *loopInsulin in settings.prescribedInsulinArray) {
            if (loopInsulin == schedule.InsulinBrand) break;
            i++;
        }
        [insulinPicker selectRow:i inComponent:0 animated:NO];
    } else {
        schedule.InsulinBrand = [settings.prescribedInsulinArray objectAtIndex:0];
        insulinBrand.text = schedule.InsulinBrand.brandName;
    }
	
	insulinPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.activeField = insulinBrand;
    
    insulinBrand.inputView = insulinPicker;
    insulinBrand.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];

    insulinBrand.canBecomeFirstResponder = YES;
    [insulinBrand becomeFirstResponder];
    
}

-(void) clearAllEditing {
    
    [name resignFirstResponder];
    [carbsToIngest resignFirstResponder];
    [insulinDose resignFirstResponder];
    
}

-(void)updateTime:(UIDatePicker *)sender {
    
    if (self.selectedIndexPath.row == BEGIN_TIME) {
        beginTime.text = [dateFmt stringFromDate:(NSDate *)[sender date]];
        endTime.text = beginTime.text;
        schedule.beginTime = [sender date];
        schedule.endTime = schedule.beginTime;
    } else if (self.selectedIndexPath.row == END_TIME) {
        endTime.text = [dateFmt stringFromDate:(NSDate *)[sender date]];
        schedule.endTime = [sender date];
        if ([[schedule.endTime earlierDate:schedule.beginTime] isEqualToDate:schedule.endTime]) {  // begin later than end (begin > end)
            endTime.text = beginTime.text;
            schedule.endTime = schedule.beginTime;
            [sender setDate:schedule.beginTime];
        }
    }
    
    schedule.reminder = [NSNumber numberWithBool:YES];
    [reminder setOn:YES animated:YES];
    [anyTime setOn:NO animated:YES];

}

-(void)reminderChanged {
    
    schedule.reminder = [NSNumber numberWithBool:reminder.on];
    schedule.anyTime = [NSNumber numberWithBool:NO];
    [anyTime setOn:NO animated:YES];
    [settings saveSettings];
    
}

-(void)anyTimeChanged {
    
    schedule.anyTime = [NSNumber numberWithBool:anyTime.on];
    schedule.reminder = [NSNumber numberWithBool:NO];
    [reminder setOn:NO animated:YES];
    [settings saveSettings];
    
}

-(void)complexCarbChanged {
    
    schedule.complexCarb = [NSNumber numberWithBool:complexCarb.on];
    
}

-(void)saveScheduleItem {
    
    if (!self.name.text) return;
    
    [settings addSchedule:self.schedule];
    [settings saveSettings];
    
    if (self.delegate) {
        [self.delegate dismissAddSchedItem];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)cancelAddScheduleItem {
    
    [settings.managedObjectContext deleteObject:schedule];
    [self.delegate dismissAddSchedItem];
    
}
#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (row < [settings.prescribedInsulinArray count]) {
        schedule.InsulinBrand = [settings.prescribedInsulinArray objectAtIndex:row];
        insulinBrand.text = schedule.InsulinBrand.brandName;
    } else {
        if (schedule.InsulinBrand) {
            [schedule.InsulinBrand removeDailySchedulesObject:schedule];
        }
        insulinBrand.text = @"None";
    }
    return;              
    
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (row < [settings.prescribedInsulinArray count]) {
        return [[settings.prescribedInsulinArray objectAtIndex:row] brandName];
    } else {
        return @"None";
    }
	
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{

    return 200;

}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{

	return 35.0;

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{

    return [settings.prescribedInsulinArray count] + 1;

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{

    return 1;

}

#pragma mark - Done Button


- (void)closeButton:(id)sender {
    
    [self.activeField resignFirstResponder];
    
    if (activeField == beginTime) {
        datePicker = nil;
        beginTime.textColor = [UIColor blackColor];
        endTime.textColor = [UIColor blackColor];
    }

    if (activeField == insulinBrand) {
        insulinPicker = nil;
    }
    
    self.activeField = nil;
    settings.accessoryView = nil;

    
}

@end
