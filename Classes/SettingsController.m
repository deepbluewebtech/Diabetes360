//
//  SettingsController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DiabetesAppDelegate.h"
#import "SettingsController.h"
#import "InsulinFactorController.h"
#import "InsulinScaleController.h"
#import "DailyScheduleController.h"
#import "PumpSiteController.h"
#import "InsulinBrandsController.h"
#import "UpcomingReminderViewController.h"
#import "SetupViewController.h"
#import "InsulinOnBoardController.h"
#import "ExerciseController.h"
#import "ActiveDatabaseVC.h"
#import "SiteVC.h"

#define INSULIN_SECTION         0
#define PRESCRIBED_INSULIN      0
#define INSULIN_CALC_METHOD     1
#define GLUCOSE_UNIT            2
#define SITES                   3
#define INSULIN_ON_BOARD        4
#define EXERCISE_FACTOR         5

#define REMINDER_SECTION        1
#define DAILY_SCHEDULE          0
#define PUMP_SITE_INTERVAL      1
#define UPCOMING_REMINDERS      2

#define MISC_SECTION            2
#define ROUNDING                0
#define KETONE_THRESHOLD        1
#define DATE_PICKER_INTERVAL    2

//#define SWITCH_LOG_SECTION      3
#define SWITCH_LOG              0

///#define WELCOME_SECTION         4
#define SHOW_WELCOME            0

@implementation SettingsController

@synthesize settings;
@synthesize insulinCalcCell;
@synthesize datePickerInterval;
@synthesize glucoseUnit;
@synthesize roundingAccuracy;

@synthesize ketoneCell;
@synthesize insulinCalcMethod;
@synthesize ketoneThreshold;
@synthesize dailyScheduleCell;
@synthesize datePickerIntervalCell;
@synthesize glucoseUnitCell;
@synthesize pumpSiteChangeCell;
@synthesize roundingAccuracyCell;
@synthesize prescribedInsulinCell;
@synthesize upcomingRemindersCell;
@synthesize insulinOnBoardCell;
@synthesize exerciseFactorCell;
@synthesize welcomeCell;
@synthesize switchLogCell;
@synthesize sitesCell;

@synthesize activeField;

@synthesize viewForSelectedCell;

@synthesize numericChars;

int switch_log_section;
int show_welcome_section;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    NSDictionary *plistInfo = [[NSBundle mainBundle] infoDictionary];

    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 50)];
    tableFooter.backgroundColor = [UIColor clearColor];
    
    UILabel *versionInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    
    NSString *fmtString = @"Version %@ Build %@";
#ifdef LOG_MAX_FOR_LITE
    fmtString = @"Version %@ Lite";
#endif
    
    versionInfo.text = [NSString stringWithFormat:fmtString,[plistInfo valueForKey:@"CFBundleShortVersionString"],[plistInfo valueForKey:@"CFBundleVersion"]];
    versionInfo.textAlignment = NSTextAlignmentCenter;
    versionInfo.textColor = [UIColor grayColor];
    versionInfo.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    versionInfo.backgroundColor =  [UIColor clearColor];
    [tableFooter addSubview:versionInfo];
    
    self.tableView.tableFooterView = tableFooter;

#ifdef LOG_MAX_FOR_LITE
    
    tblSection0Cells = [[NSArray alloc] initWithObjects:prescribedInsulinCell, insulinCalcCell, glucoseUnitCell, sitesCell, nil];
    tblSection1Cells = [[NSArray alloc] initWithObjects:dailyScheduleCell, pumpSiteChangeCell, upcomingRemindersCell, nil];
    tblSection2Cells = [[NSArray alloc] initWithObjects:roundingAccuracyCell, ketoneCell, datePickerIntervalCell, nil];


    tblSection3Cells = [[NSArray alloc] initWithObjects:welcomeCell, nil];
    tblSections      = [[NSArray alloc] initWithObjects:tblSection0Cells, tblSection1Cells, tblSection2Cells, tblSection3Cells, nil];
    show_welcome_section = 3;
    
#else
    
    tblSection0Cells = [[NSArray alloc] initWithObjects:prescribedInsulinCell, insulinCalcCell, glucoseUnitCell, sitesCell, insulinOnBoardCell, exerciseFactorCell, nil];
    tblSection1Cells = [[NSArray alloc] initWithObjects:dailyScheduleCell, pumpSiteChangeCell, upcomingRemindersCell, nil];
    tblSection2Cells = [[NSArray alloc] initWithObjects:roundingAccuracyCell, ketoneCell, datePickerIntervalCell, nil];
    
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0f) { // manage logs not supported prior to iOS 5.0
        tblSection3Cells = [[NSArray alloc] initWithObjects:switchLogCell, nil];
        tblSection4Cells = [[NSArray alloc] initWithObjects:welcomeCell, nil];
        tblSections      = [[NSArray alloc] initWithObjects:tblSection0Cells, tblSection1Cells, tblSection2Cells, tblSection3Cells,  tblSection4Cells, nil];
        switch_log_section = 3;
        show_welcome_section = 4;

    } else {
        tblSection3Cells = [[NSArray alloc] initWithObjects:welcomeCell, nil];
        tblSections = [[NSArray alloc] initWithObjects:tblSection0Cells, tblSection1Cells, tblSection2Cells, tblSection3Cells, nil];
        show_welcome_section = 3;
    }

#endif

    self.title = @"Settings";
    numFmt = [[NSNumberFormatter alloc] init];
    self.numericChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    [insulinCalcMethod addTarget:self action:@selector(insulinCalcChanged) forControlEvents:UIControlEventValueChanged];
    [glucoseUnit addTarget:self action:@selector(glucoseUnitChanged) forControlEvents:UIControlEventValueChanged];

    self.tableView.backgroundView = settings.tableViewBgView;
    self.activeField = nil;
    
}

- (void)viewDidUnload
{

    [self setSwitchLogCell:nil];
    [self setSitesCell:nil];
    [self setUseIOB:nil];
    [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                              style: UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                            action:nil];
    
    glucoseUnit.selectedSegmentIndex = [settings.glucoseUnit intValue];
    insulinCalcMethod.selectedSegmentIndex = [settings.calcType intValue];
    
    float round = 1.0f;
    if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
        round = 0.1f;
    }
    
    self.ketoneThreshold.text = [settings formatToRoundedString:[settings glucoseConvert:settings.ketoneThreshold toExternal:YES] accuracy:[NSNumber numberWithFloat:round]];
    self.datePickerInterval.text = [settings.datePickerInterval stringValue];
    self.roundingAccuracy.text = [settings formatToRoundedString:settings.roundingAccuracy accuracy:[NSNumber numberWithFloat:0.001f]];

    self.roundingAccuracy.textAlignment = UITextAlignmentRight;
    self.ketoneThreshold.textAlignment = UITextAlignmentRight;
    self.datePickerInterval.textAlignment = UITextAlignmentRight;

}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    [settings saveSettings];

}

- (void)viewDidDisappear:(BOOL)animated
{

    [super viewDidDisappear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string length] > 0 && ![numericChars characterIsMember:[string characterAtIndex:0]])
        return NO;
    
    if (textField == roundingAccuracy) {
        if ([string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location != NSNotFound) {
            return NO;
        }
    } else if (textField == ketoneThreshold) {
        if ([string isEqualToString:@"."]) {
            if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
                if ([string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location != NSNotFound) {
                    return NO;
                }
            } else {
                return NO;
            }
        }
    } else if (textField == datePickerInterval) {
        if ([string isEqualToString:@"."]) {
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    //[self resignTextResponders];
    return YES;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == ketoneThreshold) {
        settings.ketoneThreshold = [settings glucoseConvert:[numFmt numberFromString:self.ketoneThreshold.text] toExternal:NO];
    } else if (textField == datePickerInterval) {
        settings.datePickerInterval = [numFmt numberFromString:self.datePickerInterval.text];
        if ([settings.datePickerInterval intValue] > 59 || [settings.datePickerInterval intValue] <= 0) {
            settings.datePickerInterval = [NSNumber numberWithInt:1];
            self.datePickerInterval.text = @"1";
        }
        
        
    } else if (textField == roundingAccuracy) {
        
        NSNumber *oldAccuracy = settings.roundingAccuracy;
        NSNumber *newAccuracy = [numFmt numberFromString:self.roundingAccuracy.text];
        
        if ([newAccuracy floatValue] > 1 || newAccuracy.floatValue == 0) {
            
            settings.roundingAccuracy = oldAccuracy;
            self.roundingAccuracy.text = [settings formatToRoundedString:oldAccuracy accuracy:[NSNumber numberWithFloat:0.010f]];
            
            NSString *message = @"Insulin Factor cannot be zero";
            if (newAccuracy.floatValue > 1) {
                message = @"Insulin Factor cannot be more than 1";
            }
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:message
                                       delegate:nil
                              cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
        } else {
            settings.roundingAccuracy = newAccuracy;
        }
    }
    
    textField.textColor = settings.colorScheme.textNormal; 
    
    return;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    textField.textColor = settings.colorScheme.textHightlight;
    self.activeField = textField;
    self.activeField.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];

    textField.keyboardType = UIKeyboardTypeDecimalPad;
    
}

#pragma mark - App Buttons

-(void)insulinCalcChanged {

    settings.calcType = [NSNumber numberWithInt:insulinCalcMethod.selectedSegmentIndex];
    [self resignTextResponders];

}

-(void)glucoseUnitChanged {

    [self resignTextResponders];   
    
    settings.glucoseUnit = [NSNumber numberWithInt:glucoseUnit.selectedSegmentIndex];

    float round = 1.0f;
    if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
        round = 0.1f;
    }
    
    ketoneThreshold.text = [settings formatToRoundedString:[settings glucoseConvert:settings.ketoneThreshold toExternal:YES] accuracy:[NSNumber numberWithFloat:round]];
    
}

-(void)resignTextResponders {
 
    [ketoneThreshold resignFirstResponder];
    [datePickerInterval resignFirstResponder];
    [roundingAccuracy resignFirstResponder];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    return [tblSections count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[tblSections objectAtIndex:section] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[settings setView:self.tableView toColorScheme:nil];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == MISC_SECTION) {
        
        switch (indexPath.row) {
            case KETONE_THRESHOLD: {
                float round = 1.0f;
                if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
                    round = 0.1f;
                }
                self.ketoneThreshold.text = [settings formatToRoundedString:[settings glucoseConvert:settings.ketoneThreshold toExternal:YES] accuracy:[NSNumber numberWithFloat:round]];
                break;
            }
            case DATE_PICKER_INTERVAL:
                self.datePickerInterval.text = [settings.datePickerInterval stringValue];
                break;
                
            case ROUNDING:
                self.roundingAccuracy.text = [settings formatToRoundedString:settings.roundingAccuracy accuracy:[NSNumber numberWithFloat:0.001f]];
                break;
                
            default:
                break;
        }
        
    }
    
    UITableViewCell *cell = [[tblSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.selectedBackgroundView = viewForSelectedCell;
    return cell; 
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [self resignTextResponders];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == MISC_SECTION) {
        
        switch (indexPath.row) {
            case KETONE_THRESHOLD:
                [ketoneThreshold becomeFirstResponder];
                break;
            case DATE_PICKER_INTERVAL:
                [datePickerInterval becomeFirstResponder];
                break;
            case ROUNDING:
                [roundingAccuracy becomeFirstResponder];
                break;
            default:
                break;
        }
    
    } else {

        [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];

    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == INSULIN_SECTION && indexPath.row == INSULIN_CALC_METHOD) {
        if ([settings.calcType intValue] == INSULIN_CALC_FORMULA) {
            InsulinFactorController *controller = [[InsulinFactorController alloc] initWithNibName:@"InsulinFactorController" bundle:nil];
            controller.settings = self.settings;
            controller.managedObjectContext = settings.managedObjectContext;
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            InsulinScaleController *controller = [[InsulinScaleController alloc] initWithNibName:@"InsulinScaleController" bundle:nil];
            controller.settings = self.settings;
            controller.managedObjectContext = settings.managedObjectContext;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    } else if (indexPath.section == REMINDER_SECTION && indexPath.row == DAILY_SCHEDULE) {
        DailyScheduleController *controller = [[DailyScheduleController alloc] initWithNibName:@"DailyScheduleController" bundle:nil];
        controller.settings = self.settings;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == REMINDER_SECTION && indexPath.row == PUMP_SITE_INTERVAL) {
        PumpSiteController *controller = [[PumpSiteController alloc] initWithNibName:@"PumpSiteController" bundle:nil];
        controller.settings = self.settings;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == INSULIN_SECTION && indexPath.row == PRESCRIBED_INSULIN) {
        InsulinBrandsController *controller = [[InsulinBrandsController alloc] initWithNibName:@"InsulinBrandsController" bundle:nil];
        controller.settings = self.settings;
        controller.fromSettings = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == INSULIN_SECTION && indexPath.row == SITES) {
        SiteVC *controller = [[SiteVC alloc] initWithNibName:@"SiteVC" bundle:nil];
        controller.settings = self.settings;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == INSULIN_SECTION && indexPath.row == INSULIN_ON_BOARD) {
        InsulinOnBoardController *controller = [[InsulinOnBoardController alloc] initWithNibName:@"InsulinOnBoardController" bundle:nil];
        controller.settings = self.settings;
        controller.managedObjectContext = settings.managedObjectContext;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == INSULIN_SECTION && indexPath.row == EXERCISE_FACTOR) {
        ExerciseController *controller = [[ExerciseController alloc] initWithNibName:@"ExerciseController" bundle:nil];
        controller.settings = self.settings;
        controller.managedObjectContext = settings.managedObjectContext;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == REMINDER_SECTION && indexPath.row == UPCOMING_REMINDERS) {
        UpcomingReminderViewController *controller = [[UpcomingReminderViewController alloc] initWithNibName:@"UpcomingReminderViewController" bundle:nil];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                  style: UIBarButtonItemStyleBordered
                                                                                 target:nil
                                                                                 action:nil];
        controller.settings = self.settings;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == switch_log_section && indexPath.row == SWITCH_LOG) {
        ActiveDatabaseVC *activeDBVC = [[ActiveDatabaseVC alloc] initWithNibName:@"ActiveDatabaseVC" bundle:nil];
        activeDBVC.settings = self.settings;
        [self.navigationController pushViewController:activeDBVC animated:YES];
        
    }  else if (indexPath.section == show_welcome_section && indexPath.row == SHOW_WELCOME) {
        SetupViewController *setupController = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
        setupController.settings = self.settings;
        [self.navigationController pushViewController:setupController animated:YES];
    }

}

#pragma mark - Done Button

- (void)doneButton:(id)sender {
    
    [self.activeField resignFirstResponder];
    activeField = nil;
    settings.accessoryView = nil;

}



@end
