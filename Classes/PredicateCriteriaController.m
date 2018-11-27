//
//  PredicateCriteriaController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataService.h"
#import "DailySchedule.h"
#import "PredicateCriteriaController.h"
#import "GraphController.h"
#import "Event.h"
#import "InsulinBrand.h"
#import "Site.h"
#import "EventFood.h"
#import "FoodItem.h"
#import "KetoneValue.h"
#import "PickerLabel.h"
#import "DiabetesAppDelegate.h"

@interface PredicateCriteriaController ()

@property (nonatomic,strong) UIView *accessoryView;
@property (nonatomic, strong) UIButton *theCloseButton;

#define CLOSE_BUTTON_TAG 99

- (void)removePickers;
- (void)showDatePicker:(id)sender;
- (void)showTimeOfDayPicker:(id)sender;
- (void)launchMailAppOnDevice;
- (void)displayComposerSheet;
- (void)displayEmail;
- (void)initialValues;

@end

@implementation PredicateCriteriaController

@synthesize settings;
@synthesize theStartDate;
@synthesize theEndDate;
@synthesize theSchedule;
@synthesize nextController;

@synthesize csvString;
@synthesize csvFoodString;
@synthesize emailBody;

@synthesize selectedIndexPath;

@synthesize startDateCell;
@synthesize endDateCell;
@synthesize timeOfDayCell;
@synthesize startDate;
@synthesize endDate;
@synthesize timeOfDay;
@synthesize executeButton;
@synthesize resetButton;
@synthesize waitingCancel;
@synthesize formatSegCtl;

@synthesize waiting;
@synthesize waitingProgress;
@synthesize cancelBuild;
@synthesize csvDateFmt;
@synthesize csvTimeFmt;
@synthesize numFmt;
@synthesize numFmt1;

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
        csvDateFmt = [[NSDateFormatter alloc] init];
        csvTimeFmt = [[NSDateFormatter alloc] init];
        numFmt  = [[NSNumberFormatter alloc] init];
        dateFmt = [[NSDateFormatter alloc] init];
        numFmt1 = [[NSNumberFormatter alloc] init];
    }
    
    return self;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"memory error %@",[self class]);
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    tblSection0Cells = [[NSArray alloc] initWithObjects:startDateCell, endDateCell, nil];
    
    if (nextController == NEXT_IS_MAIL) {
        tblSection1Cells = [[NSArray alloc] initWithObjects:timeOfDayCell, nil];
        tblSections      = [[NSArray alloc] initWithObjects:tblSection0Cells, tblSection1Cells, nil];
    } else {
        tblSections      = [[NSArray alloc] initWithObjects:tblSection0Cells, nil];
    }
    
    
    theStartDate = [[NSDate alloc] init];
    theEndDate   = [[NSDate alloc] init];
    
    [self initialValues];

    dateFmt.dateStyle = NSDateFormatterLongStyle;
    dateFmt.timeStyle = NSDateFormatterShortStyle;
    
    self.cancelBuild = [NSNumber numberWithBool:NO];
    
    CGRect frame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 160)];
        
    if (nextController == NEXT_IS_GRAPH) {
        
        [executeButton setTitle:@"View Graph" forState:UIControlStateNormal];
        [executeButton setTitle:@"View Graph" forState:UIControlStateHighlighted];
        self.title = @"Graph Criteria";
        
    } else {
        
        [executeButton setTitle:@"View Export" forState:UIControlStateNormal];
        [executeButton setTitle:@"View Export" forState:UIControlStateHighlighted];
        self.title = @"Export Criteria";
        frame = formatSegCtl.frame;
        frame.origin.x = 60.0f;
        self.formatSegCtl.frame = frame;
        [view addSubview:formatSegCtl];

    }

    frame = executeButton.frame;
    frame.origin.y = 50.0f;
    frame.origin.x = 45.0f;
    executeButton.frame = frame;
    
    frame = resetButton.frame;
    frame.origin.y = 50.0f;
    frame.origin.x = 175.0f;
    resetButton.frame = frame;
    
    
    [view addSubview:executeButton];
    [view addSubview:resetButton];
    
    self.tableView.tableFooterView = view;
    self.tableView.backgroundView = settings.tableViewBgView;
    
    secondaryQueue = dispatch_queue_create("secondary", DISPATCH_QUEUE_SERIAL);

}

-(void)initialValues {

    NSDate *aDate = [NSDate distantPast];
    self.theStartDate = aDate;
    
    aDate = [NSDate distantFuture];
    self.theEndDate   = aDate;

    theSchedule  = nil;
    
}

- (void)viewDidUnload
{

    [self setFormatSegCtl:nil];
    [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    self.selectedIndexPath = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [tblSections count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[tblSections objectAtIndex:section] count];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [[tblSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath == self.selectedIndexPath) {
        return;
    }
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        [self showDatePicker:@"startDate"];
    } else if (indexPath.row == 1 && indexPath.section == 0) {
        [self showDatePicker:@"endDate"];
    } else if (indexPath.row == 0 && indexPath.section == 1) {
        [self showTimeOfDayPicker:nil];
    }
    
    self.selectedIndexPath = indexPath;
}

#pragma mark - Build Result

- (IBAction)resetCriteria:(id)sender {

    [self initialValues];
    
    startDate.text = @"Tap To Select";
    endDate.text   = @"Tap To Select";
    timeOfDay.text = @"Tap To Select";
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES];
    
    [self removePickers];
}

- (NSString *)doCSVFoodRecordWithFood:(EventFood *)eventFood string:(NSString *)string {

    [csvDateFmt setDateFormat:@"yyyy-MM-dd"];
    [csvTimeFmt setDateFormat:@"HH:mm"];

    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",[csvDateFmt stringFromDate:eventFood.Event.eventDate]]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",[csvTimeFmt stringFromDate:eventFood.Event.eventDate]]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",eventFood.FoodItem.shortDesc]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",eventFood.servingQty]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",eventFood.foodMeasure]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@",[numFmt1 stringFromNumber:eventFood.foodCarb]]];
    
    string = [string stringByAppendingString:@"\r\n"];
    
    return string;
}

- (NSString *)doCSVRecordWithEvent:(Event *)event string:(NSString *)string {

    [csvDateFmt setDateFormat:@"yyyy-MM-dd"];
    [csvTimeFmt setDateFormat:@"HH:mm"];
    
    float glucoseAcc;
    if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
        glucoseAcc = 0.1f;
    } else {
        glucoseAcc = 1.0f;
    }
    
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",[csvDateFmt stringFromDate:event.eventDate]]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",[csvTimeFmt stringFromDate:event.eventDate]]];
    
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",[settings formatToRoundedString:[settings glucoseConvert:event.glucose toExternal:YES] accuracy:[NSNumber numberWithFloat:glucoseAcc]]]];
    
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",([event.totalCarb intValue] ? [event.totalCarb stringValue] : @"0")]];

    if ([[event.InsulinBrand.classification substringFromIndex:1] isEqualToString:RAPID_INSULIN]) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,",[settings formatToRoundedString:event.insulinAmt accuracy:nil]]];
    } else {
        string = [string stringByAppendingString:@","];
    }
    
    string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",(event.InsulinBrand.brandName ? event.InsulinBrand.brandName : @"")]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",(event.Site.name ? event.Site.name : @"")]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",(event.KetoneValue.name ? event.KetoneValue.name : @"")]];
    
    if (event.DailySchedule) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@ %@\",",(event.isBeforeSchedule ? @"Before" : @"After"), event.DailySchedule.name]];
    } else {
        string = [string stringByAppendingString:@"\"\","];
    }
    
    string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\"",(event.note ? event.note : @"")]];
    
    string = [string stringByAppendingString:@"\r\n"];
    
    if ([event.EventFoods count] > 0) {
        for (EventFood *eventFood in event.EventFoods) {
            csvFoodString = [self doCSVFoodRecordWithFood:eventFood string:csvFoodString];
        }
    }
    
    return string;
    
}

-(NSDate *)dateWithoutTimeFrom:(NSDate *)theDate {

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:theDate];
    comps.hour = 0;
    comps.minute = 0;
    comps.second = 0;
    return [calendar dateFromComponents:comps];

}

-(NSMutableArray *)aNewOneDayDatasetWith:(Event *)event {
    
    NSMutableArray *oneDayDataset = [[NSMutableArray alloc] initWithCapacity:25];
    
    [oneDayDataset addObject:[self dateWithoutTimeFrom:event.eventDate]];
    
    for (int i=0; i<24; i++) {
        [oneDayDataset addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"sum",[NSNumber numberWithInt:0],@"count", nil]];
    }
    
    return oneDayDataset;
}

-(NSArray *)buildSummaryEmailDatasetUsing:(NSArray *)resultSet {
    
    NSMutableArray *allDaysDataset = [[NSMutableArray alloc] initWithCapacity:300];
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *eventHour;
    NSMutableDictionary *bucket;
    
    for (Event *theEvent in resultSet) {
        NSLog(@"%@",theEvent.eventDate);
    }
    Event *event = (Event *)[resultSet objectAtIndex:0];
    NSMutableArray *oneDayDataset = [self aNewOneDayDatasetWith:event];
    
    NSDate *dateSave = [oneDayDataset objectAtIndex:0];
    
    int hourSave;
    hourSave = [[cal components:(NSHourCalendarUnit) fromDate:event.eventDate] hour];

    float sum, count, carb;
    int maxAvg = 0;

    
    for (Event *event in resultSet) {
        
        if (![[self dateWithoutTimeFrom:event.eventDate] isEqualToDate:[oneDayDataset objectAtIndex:0]]) {

            [allDaysDataset addObject:oneDayDataset];
            oneDayDataset = [self aNewOneDayDatasetWith:event];
            dateSave = [oneDayDataset objectAtIndex:0];
            hourSave = eventHour.hour;
            carb = 0;
            sum = 0;
            count = 0;

        }
        
        if (eventHour.hour != hourSave) {
            carb = 0;
            sum=0;
            count=0;
        }
        
        eventHour = [cal components:(NSHourCalendarUnit) fromDate:event.eventDate];
        bucket = [oneDayDataset objectAtIndex:eventHour.hour + 1];

        if ([event.glucose floatValue] > 0) {
            count = [[bucket valueForKey:@"count"] floatValue];
            count++;
            
            [bucket setValue:[NSNumber numberWithFloat:count] forKey:@"count"];
            sum = [[bucket valueForKey:@"sum"] floatValue];
            sum += [[settings glucoseConvert:event.glucose toExternal:YES] floatValue];
            [bucket setValue:[NSNumber numberWithFloat:sum] forKey:@"sum"];
            
            for (int i=1; i < [oneDayDataset count]; i++) {
                sum = [[[oneDayDataset objectAtIndex:i] valueForKey:@"sum"] floatValue];
                count = [[[oneDayDataset objectAtIndex:i] valueForKey:@"count"] floatValue];
                if (maxAvg <= (sum / count)) maxAvg = sum / count;
            }
            
        }
        
        if ([event.totalCarb floatValue] > 0) {
            carb += [event.totalCarb floatValue];
            [bucket setValue:[NSNumber numberWithFloat:carb] forKey:@"carb"];
        }
        
        if ([event.insulinAmt floatValue] > 0 && [[event.InsulinBrand.classification substringFromIndex:1] isEqualToString:RAPID_INSULIN]) {
            [bucket setValue:event.insulinAmt forKey:@"insulin"];
        }
        
    }
    
    [allDaysDataset addObject:oneDayDataset];
    
    return [allDaysDataset copy];
    
}


-(void)buildSummaryEmailStringUsing:(NSArray *)resultSet {
    
    DiabetesAppDelegate *appDelegate = (DiabetesAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.criteriaVC = self;
    
    NSArray *summaryDataset = [self buildSummaryEmailDatasetUsing:resultSet];
    
    dateFmt.timeStyle = NSDateFormatterNoStyle;
    dateFmt.dateStyle = NSDateFormatterMediumStyle;
    emailBody = @"<table width=1500 cellpadding=4 cellspacing=0 border=1>";
    
    int glucose = 0;
    int i = 0;
    
    NSNumberFormatter *twoDecimalFmt = [[NSNumberFormatter alloc] init];
    twoDecimalFmt.positiveFormat = @"##.##";
    NSString *insulinAmt = nil;
    
    NSArray *theDay=nil;
    for (int x=0; x<[summaryDataset count]; x++) {
        theDay = [summaryDataset objectAtIndex:x];
        for (id theHour in theDay) {
            
            if ([theHour isKindOfClass:[NSDate class]]) {
                emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<tr><td>%@</td>",[dateFmt stringFromDate:theHour]]];
                int hour;
                NSString *amPm;
    
                for (int i=1; i <= 24; i++) {
                 
                    switch (i) {
                        case 1:
                            hour = 12;
                            amPm = @"<br>mdnt";
                            break;
                        case 13:
                            hour = 12;
                            amPm  = @"<br>noon";
                            break;
                        default:
                            if (i < 13) {
                                hour = i - 1;
                                amPm = @"am";
                            } else {
                                hour = i -  13;
                                amPm = @"pm";
                            }
                            break;
                    }
                    
                    emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",[NSString stringWithFormat:@"%d%@",hour,amPm]]];
                }
                
                emailBody = [emailBody stringByAppendingString:@"</tr>"];
                emailBody = [emailBody stringByAppendingString:@"<td>Glucose</td>"];

            } else {
                
                glucose = 0;
                
                if ([[theHour valueForKey:@"count"] intValue] > 0) {
                    glucose = [[theHour valueForKey:@"sum"] intValue] / [[theHour valueForKey:@"count"] intValue];
                }
                
                emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",(glucose ? [NSNumber numberWithInt:glucose] : @"&nbsp;")]];
                
            }

        }
        
        emailBody = [emailBody stringByAppendingString:@"</tr><tr><td>Carbohydrate</td>"];
        
        for (id theHour in theDay) {
            if ( ! [theHour isKindOfClass:[NSDate class]]) {
                emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",([theHour valueForKey:@"carb"] ? [theHour valueForKey:@"carb"] : @"&nbsp;")]];
            }
        }
        
        emailBody = [emailBody stringByAppendingString:@"</tr>"];

        emailBody = [emailBody stringByAppendingString:@"</tr><tr><td>Insulin</td>"];
        
        for (id theHour in theDay) {
            if ( ! [theHour isKindOfClass:[NSDate class]]) {
                insulinAmt = [twoDecimalFmt stringFromNumber:[theHour valueForKey:@"insulin"]];
                emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",(insulinAmt ? insulinAmt : @"&nbsp;")]];
            }
        }
        
        emailBody = [emailBody stringByAppendingString:@"</tr><tr><td colspan=25>&nbsp</td></tr>"];

        i++;
        
        dispatch_async(dispatch_get_main_queue(), ^{ //update UI progress bar on main thread
            [waitingProgress setProgress:(i / (float)[summaryDataset count])];
        });
        
        if ([cancelBuild boolValue] == YES) {
            break;
        }
    }
    
    emailBody = [emailBody stringByAppendingString:@"</table>"];
    
    appDelegate.criteriaVC = nil;
    appDelegate = nil;

}

-(void)buildDetailEmailStringUsing:(NSArray *)resultSet {
    
    DiabetesAppDelegate *appDelegate = (DiabetesAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.criteriaVC = self;
    
    [dateFmt setDateStyle:NSDateFormatterMediumStyle];
    [dateFmt setTimeStyle:NSDateFormatterShortStyle];
    
    float glucoseAcc;
    NSString *glucoseUnit;
    if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
        glucoseAcc = 0.1f;
        glucoseUnit = @"mmol/L";
    } else {
        glucoseAcc = 1.0f;
        glucoseUnit = @"mg/dL";
    }
    
    csvString = @"\"date\",\"time\",\"glucose\",\"totalCarb\",\"insulinAmt\",\"insulinBrand\",\"site\",\"ketone\",\"timeOfDay\",\"notes\"\r\n";
    csvFoodString = @"\"date\",\"time\",\"foodDesc\",\"servingQty\",\"foodMeasure\",\"foodCarb\"\r\n";
    
	emailBody = @"<div style=\"margin-bottom:20px\">CSV files attached at end of note for spreadsheet import.</div><table width=800 border='1' cellpadding='4' cellspacing='0'>";
    emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<tr valign=bottom><td>Date/Time</td><td>Glucose<br>(%@)</td><td>Total Carbs</td><td>Insulin</td><td>Insulin Brand</td><td>Site</td><td>Ketone</td><td>Time of Day</td><td>Notes</td></tr>",glucoseUnit]];
    
    int resultSetSize = [resultSet count];
    int i = 0;
    
    for (Event *event in resultSet) {
        csvString = [self doCSVRecordWithEvent:event string:csvString];
        emailBody = [emailBody stringByAppendingString:@"<tr>"];
        emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",[dateFmt stringFromDate:event.eventDate]]];
        
        if ([event.glucose intValue]) {
            emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",[settings formatToRoundedString:[settings glucoseConvert:event.glucose toExternal:YES] accuracy:[NSNumber numberWithFloat:glucoseAcc]]]];
        } else {
            emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",@" "]];
        }
        
        emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",([event.totalCarb intValue] ? [event.totalCarb stringValue] : @" ")]];
        
        if ([[event.InsulinBrand.classification substringFromIndex:1] isEqualToString:RAPID_INSULIN]) {
            emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",[settings formatToRoundedString:event.insulinAmt accuracy:nil]]];
        } else {
            emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>&nbsp;</td>"]];
        }
        
        emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",(event.InsulinBrand.brandName ? event.InsulinBrand.brandName : @" ")]];
        emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",(event.Site.name ? event.Site.name : @" ")]];
        
        if (event.KetoneValue) {
            emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",event.KetoneValue.name]];
        } else {
            emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",@" "]];
        }
        
        if (event.DailySchedule) {
            emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@ %@</td>",(event.isBeforeSchedule ? @"Before" : @"After"), event.DailySchedule.name]];
        } else {
            emailBody = [emailBody stringByAppendingString:@"<td> </td>"];
        }
        
        emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",(event.note ? event.note : @" ")]];
        emailBody = [emailBody stringByAppendingString:@"</tr>"];
        if ([event.EventFoods count]) {
            emailBody = [emailBody stringByAppendingString:@"<tr><td colspan=9><table border='1' cellpadding='4' cellspacing='0'>"];
            emailBody = [emailBody stringByAppendingString:@"<tr valign=bottom><td>&nbsp;</td><td>Qty</td><td>Measure</td><td>Carbs</td></tr>"];
            for (EventFood *eventFood in event.EventFoods) {
                emailBody = [emailBody stringByAppendingString:@"<tr>"];
                
                emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",eventFood.FoodItem.shortDesc]];
                emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",eventFood.servingQty]];
                emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@</td>",eventFood.foodMeasure]];
                emailBody = [emailBody stringByAppendingString:[NSString stringWithFormat:@"<td>%@g</td>",[numFmt stringFromNumber:eventFood.foodCarb]]];
                emailBody = [emailBody stringByAppendingString:@"</tr>"];
            }
            emailBody = [emailBody stringByAppendingString:@"</table></td></tr>"];
        }
        i++;
        dispatch_async(dispatch_get_main_queue(), ^{ //update UI progress bar on main thread
            [waitingProgress setProgress:(i / resultSetSize)];
        });
        if ([cancelBuild boolValue]) {
            break;
        }
    }
    
    emailBody = [emailBody stringByAppendingString:@"</table>"];
    
    appDelegate.criteriaVC = nil;
    appDelegate = nil;

}
- (void)buildEmailStringsUsing:(NSArray *)resultSet {
    
    if (self.formatSegCtl.selectedSegmentIndex == 0) {
        [self buildSummaryEmailStringUsing:resultSet];
    } else {
        [self buildDetailEmailStringUsing:resultSet];
    }
    
}

- (IBAction)buildResultGoNext:(id)sender {
    
    [self removePickers];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:settings.managedObjectContext]];

    BOOL ascending = NO;
    if (self.formatSegCtl.selectedSegmentIndex == 0) {
        ascending = YES;
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *pred;
    if (theSchedule) {
        pred = [NSPredicate predicateWithFormat:@"eventDate >= %@ && eventDate <= %@ && DailySchedule == %@ && isBeforeSchedule == %@",theStartDate, theEndDate, theSchedule, [NSNumber numberWithBool:isBeforeSchedule]];
    } else {
        pred = [NSPredicate predicateWithFormat:@"eventDate >= %@ && eventDate <= %@",theStartDate, theEndDate];
    }

    [fetchRequest setPredicate:pred];
     
	NSError *error = nil;
    NSArray *theResult = [settings.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ buildResultGoNext",self.class]];

    
    if ([theResult count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results" message:@"Try Adjusting Criteria"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
        self.selectedIndexPath = nil;
    } else {
        if (nextController == NEXT_IS_MAIL) {
            [[NSBundle mainBundle] loadNibNamed:@"buildingEmailView" owner:self options:nil];
            CGRect frame = waiting.frame;
            frame.origin.x = 60.0f;
            frame.origin.y = 50.0f;
            waiting.frame = frame;
            [waitingProgress setProgress:0.0f];
            [[self.view superview] addSubview:waiting];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nextController == NEXT_IS_GRAPH) {
                [self removePickers];
                GraphController *controller = [[GraphController alloc] initWithNibName:@"GraphController" bundle:nil];
                controller.resultSet = theResult;
                controller.settings = self.settings;
                [self presentViewController:controller animated:YES completion:nil];
            } else {
                
                self.tableView.userInteractionEnabled = NO;
                
                dispatch_async(secondaryQueue, ^{
                    
                    [self buildEmailStringsUsing:theResult];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                    
                        if (waiting) [waiting removeFromSuperview];
                        self.tableView.userInteractionEnabled = YES;
                        if ([cancelBuild boolValue]) {
                            emailBody = @"";
                            csvString = @"";
                            csvFoodString = @"";
                        } else {
                            [self displayEmail];
                        }
                        cancelBuild = [NSNumber numberWithBool:NO];
                    
                    });
                    
                });
            }
        });
    }
}

-(IBAction)cancelExport:(id)sender {
    
    cancelBuild = [NSNumber numberWithBool:YES];
    
}

#pragma mark - Pickers

-(void)removePickers {
    
    if ([startDate isFirstResponder]) {
        [startDate resignFirstResponder];
        datePicker = nil;
    }
    
    if ([timeOfDay isFirstResponder]) {
        [timeOfDay resignFirstResponder];
        timeOfDayPicker = nil;
    }

    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    self.selectedIndexPath = nil;

}

- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
                                   screenRect.size.height - 42.0 - size.height,
                                   size.width,
                                   size.height);
	return pickerRect;
}

- (void)updatePickerDate {

    if (pickerStartDate) {
        self.theStartDate = datePicker.date;
        datePicker.date = theStartDate;
        if ([[theEndDate earlierDate:theStartDate] isEqualToDate:theEndDate] || [theEndDate isEqualToDate:[NSDate distantFuture]]) {  // begin later than end (begin > end)
            self.theEndDate = theStartDate;
        }
    } else {
        self.theEndDate = datePicker.date;
        datePicker.date = theEndDate;
        if ([[theEndDate earlierDate:theStartDate] isEqualToDate:theEndDate]) {  // begin later than end (begin > end)
            self.theEndDate = theStartDate;
            [datePicker setDate:theStartDate animated:YES];
        }
        
    }

    if ([[dateFmt stringFromDate:theStartDate] isEqualToString:[dateFmt stringFromDate:[NSDate distantPast]]]) {
        startDate.text = @"Tap To Select";
        [datePicker setDate:[NSDate date] animated:YES];
    } else {
        startDate.text = [dateFmt stringFromDate:theStartDate];
    }
    
    if ([theEndDate isEqualToDate:[NSDate distantFuture]]) {
        endDate.text = @"Tap To Select";
        [datePicker setDate:[NSDate date] animated:YES];
    } else {
        endDate.text = [dateFmt stringFromDate:theEndDate];
    }
    

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit |
                                                    NSMonthCalendarUnit |
                                                    NSDayCalendarUnit) fromDate:theStartDate];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *aDate = [calendar dateFromComponents:comps];
    self.theStartDate = aDate;

    comps = [calendar components:(NSYearCalendarUnit |
                                  NSMonthCalendarUnit |
                                  NSDayCalendarUnit) fromDate:theEndDate];
    [comps setHour:23];
    [comps setMinute:59];
    [comps setSecond:59];
    aDate = [calendar dateFromComponents:comps];
    self.theEndDate = aDate;
    
}

- (void)showDatePicker:(id)sender {
    
    [self removePickers];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker addTarget:self action:@selector(updatePickerDate) forControlEvents:UIControlEventValueChanged];
    datePicker.hidden = NO;
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minuteInterval = [settings.datePickerInterval intValue];
    [datePicker setDate:[NSDate date] animated:YES];

    if ([sender isEqualToString:@"startDate"]) {
        pickerStartDate = YES;
    } else {
        pickerStartDate = NO;
    }
    
    if ([theStartDate isEqualToDate:[NSDate distantPast]] || [theEndDate isEqualToDate:[NSDate distantFuture]]) {
        [self updatePickerDate];
    } else {
        if ([sender isEqualToString:@"startDate"]) {
            if ([[dateFmt stringFromDate:theStartDate] isEqualToString:[dateFmt stringFromDate:[NSDate distantPast]]]) {
                startDate.text = @"Tap To Select";
                [datePicker setDate:[NSDate date] animated:YES];
            } else {
                datePicker.date = theStartDate;
            }
        } else {
            if ([[dateFmt stringFromDate:theEndDate] isEqualToString:[dateFmt stringFromDate:[NSDate distantFuture]]]) {
                endDate.text = @"Tap To Select";
                [datePicker setDate:[NSDate date] animated:YES];
            } else {
                datePicker.date = theEndDate;
            }
        }
    }
    
	datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    startDate.inputView = datePicker;
    startDate.inputAccessoryView = self.accessoryView;
    
    startDate.canBecomeFirstResponder = YES;
    [startDate becomeFirstResponder];
    
}

-(NSString *) timeOfDayStringWithSched:(NSString *)sched {
    
    if (!sched) {
        return @"Tap To Select";
    }
    NSString *part1;
    if (isBeforeSchedule == YES) {
        part1 = @"Before ";
    } else {
        part1 = @"After ";
    }
    
    return [part1 stringByAppendingString:sched];
    
}

- (void)showTimeOfDayPicker:(id)sender {
    
    [self removePickers];
    
	timeOfDayPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    
	timeOfDayPicker.showsSelectionIndicator = YES;	
	timeOfDayPicker.delegate = self;
	timeOfDayPicker.dataSource = self;
    
    if (!theSchedule) {
        theSchedule = [settings.dailyScheduleArray objectAtIndex:0];
        timeOfDay.text = @"Tap To Select";
        isBeforeSchedule = YES;
        timeOfDay.text = [self timeOfDayStringWithSched:theSchedule.name];
    }
    
    int i=0;
    for (DailySchedule *loopSched in settings.dailyScheduleArray) {
        if ([loopSched.name isEqualToString:theSchedule.name]) break;
        i++;
    }
    
    [timeOfDayPicker selectRow:i inComponent:1 animated:NO];
    if (isBeforeSchedule == YES) {
        [timeOfDayPicker selectRow:0 inComponent:0 animated:NO];
    } else {
        [timeOfDayPicker selectRow:1 inComponent:0 animated:NO];
    }
    
    timeOfDayPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    timeOfDayPicker.hidden = NO;

    timeOfDay.inputView = timeOfDayPicker;
    timeOfDay.inputAccessoryView = self.accessoryView;
    
    timeOfDay.canBecomeFirstResponder = YES;
    [timeOfDay becomeFirstResponder];
}

-(UIView *)accessoryView {
    
    if (_accessoryView) {
        return _accessoryView;
    }
    
    NSArray *buttonView = [[NSBundle mainBundle] loadNibNamed:@"InputAccessory" owner:self options:nil];
    _accessoryView = [buttonView objectAtIndex:0];
    
    self.theCloseButton = (UIButton *)[_accessoryView viewWithTag:CLOSE_BUTTON_TAG];
    [self.theCloseButton addTarget:self action:@selector(removePickers) forControlEvents:UIControlEventTouchUpInside];
    
    return _accessoryView;
    
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (pickerView == timeOfDayPicker ) {
        NSString *part1;
        NSString *part2;
        if (component == 0) {
            if (row == 0) {
                isBeforeSchedule = YES;
                part1 = @"Before ";
                
            } else {
                isBeforeSchedule = NO;
                part1 = @"After ";
            }
        } else {
            if (isBeforeSchedule == YES) {
                part1 = @"Before ";
            } else {
                part1 = @"After ";
            }
            theSchedule = [settings.dailyScheduleArray objectAtIndex:row];
        }
        part2 = theSchedule.name;
        timeOfDay.text = [part1 stringByAppendingString:part2];
    } 
    
    return;              
    
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (pickerView == timeOfDayPicker) {
        if (component == 0) {
            if (row == 0) {
                return @"Before";
            } else {
                return @"After";
            }
        } else {
            return [[settings.dailyScheduleArray objectAtIndex:row] name];
        }
    } else {
        return @"invalid picker";
    }
	
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0)
        return 80;
    else
        return 220;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 35.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (pickerView == timeOfDayPicker) {
        if (component == 0) {
            return 2;
        } else {
            return [settings.dailyScheduleArray count];
        }
    } else {
        return 0;
    }
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{

    return 2;

}


#pragma mark -
#pragma mark Compose Mail

-(void)displayEmail {
    // This sample can run on devices running iPhone OS 2.0 or later  
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
	// So, we must verify the existence of the above class and provide a workaround for devices running 
	// earlier versions of the iPhone OS. 
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
     
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet {
    
	MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
	mailer.mailComposeDelegate = self;
	
	[mailer setSubject:@"Log From Diabetes 360"];
    
	[mailer setMessageBody:emailBody isHTML:YES];

    NSError *error = nil;
    
    NSString *theFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Diabetes360Log.csv"];
    NSData *theData;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([csvString writeToFile:theFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        theData = [NSData dataWithContentsOfFile:theFilePath];
        [mailer addAttachmentData:theData mimeType:@"text/csv" fileName:@"Diabetes360Log.csv"];
        [fileManager removeItemAtPath:theFilePath error:nil];
    }
    if (error) [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ csv save",self.class]];

    theFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Diabetes360LogFood.csv"];
    if([csvFoodString writeToFile:theFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        theData = [NSData dataWithContentsOfFile:theFilePath];
        [mailer addAttachmentData:theData mimeType:@"text/csv" fileName:@"Diabetes360LogFood.csv"];
        [fileManager removeItemAtPath:theFilePath error:nil];
    }

    if (error) [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ csv food save",self.class]];

	[self presentViewController:mailer animated:YES completion:nil];
    
    
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    
	NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
	NSString *body = @"&body=It is raining in sunny California!";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    
}

-(void)dealloc {
    
    
}

@end
