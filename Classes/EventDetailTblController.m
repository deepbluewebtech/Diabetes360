//
//  EventDetailTblController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  iOS 5 safe and Automatic Reference Counting enabled.  There are no retain/release calls.

#import "EventDetailTblController.h"
#import "DataService.h"

#import "DiabetesAppDelegate.h"
#import "RootViewController.h"
#import "InsulinBrandsController.h"
#import "InsulinFactorController.h"
#import "FoodController.h"
#import "LogByMonthViewController.h"
#import "LogByDayViewController.h"
#import "NoteViewController.h"

#import "Event.h"
#import "InsulinBrand.h"
#import "Site.h"
#import "KetoneValue.h"
#import "InsulinScale.h"
#import "InsulinFactor.h"
#import "DailySchedule.h"
#import "IOBFactor.h"
#import "ExerciseType.h"
#import "Appirater.h"

#import "PickerLabel.h"

#define DATE_CELL               0
#define GLUCOSE_CARB_CELL       1
#define INSULIN_DOSE_CELL       2
#define INSULIN_BRAND_SITE_CELL 3
#define KETONE_CELL             4
#define NOTE_CELL               5

#define CELL_COUNT              6

#define CLOSE_BUTTON_TAG        99

@interface EventDetailTblController ()

@property (nonatomic, strong) UIView *accessoryView;
@property (nonatomic, strong) UIButton *theCloseButton;

- (BOOL)removePickersAndResignButNot:(UITextField *)notTextField;
- (void)calcInsulin;
- (void)saveEvent:(id)sender;
- (void)cancelEventAdd:(id)sender;
- (void)showEventDatePicker:(id)sender;
- (void)showTimeOfDayPicker:(id)sender;
- (void)showKetonePicker:(id)sender;
- (void)showSitePicker:(id)sender;
- (void)showInsulinPicker:(id)sender;
- (void)showNote:(id)sender;
- (void)setEventIOBValues;
- (void)setTextForInsulinRows;
- (NSUInteger)indexOfCurrentSched;
- (void)setTotalSites;
@end

@implementation EventDetailTblController

@synthesize settings;

@synthesize dateCell;
@synthesize timeOfDay;
@synthesize glucoseCarbCell;
@synthesize insulinDoseCell;
@synthesize insulinBrandSiteCell;
@synthesize ketoneCell;
@synthesize noteCell;
@synthesize event;

@synthesize dateFmt;
@synthesize numFmt;
@synthesize numericChars;

@synthesize alertTargetRate;
@synthesize alertInsulin;

@synthesize glucose;
@synthesize eventDate;
@synthesize insulinAmt;
@synthesize takeAsPrescribed;
@synthesize totalCarb;
@synthesize totalCarbLabel;
@synthesize foodLabel;
@synthesize insulinBrand;
@synthesize site;
@synthesize ketone;
@synthesize calcLabelGlucose;
@synthesize calcLabelCarb;
@synthesize calcLabelIOB;
@synthesize calcLabelExercise;
@synthesize componentGlucose;
@synthesize componentCarb;
@synthesize componentIOB;
@synthesize componentExercise;
@synthesize componentExerciseSign;
@synthesize IOBStrike;
@synthesize calcNoCalc;
@synthesize unitsLabel;
@synthesize foodButton;

@synthesize glucoseUnitLabel;
@synthesize note;

@synthesize exerciseButton;
@synthesize IOBButton;

@synthesize sitesArray;
@synthesize ketoneArray;

@synthesize noCalc;
@synthesize fromViewController;

@synthesize theCloseButton;

@synthesize managedObjectContext;

@synthesize delegate;

static float targetRate = 0;
static float corrFactor = 0;
static float carbFactor = 0;

static BOOL didChangeStuff = NO; //used when attribues on logDay and LogMonth alter to force reload of those views.

static float totalSites;  // for calc of percentage on site picker

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

- (void)setupFormulaFactorsByTime {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InsulinFactor" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"factorId" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"timeOfDayBegin" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ setupFormulaFactorsByTime",self.class]];
    }
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *nowComps = [calendar components:(NSYearCalendarUnit |
                                                       NSMonthCalendarUnit |
                                                       NSDayCalendarUnit |
                                                       NSHourCalendarUnit | 
                                                       NSMinuteCalendarUnit) fromDate:event.eventDate];
    
    [nowComps setYear:2000];
    [nowComps setMonth:1];
    [nowComps setDay:1];
    
    // to override current time for testing
//    [nowComps setHour:3];
//    [nowComps setMinute:59];
    
    NSDate *now = [calendar dateFromComponents:nowComps];
    
    BOOL TRFound = NO;
    BOOL CFFound = NO;
    BOOL KFFound = NO;
    
    BOOL firstTRFound = NO;
    BOOL firstCFFound = NO;
    BOOL firstKFFound = NO;
    
    float saveTR = 0;
    float saveCF = 0;
    float saveKF = 0;
    
    for (InsulinFactor *insulinFactor in result) {
        if ([insulinFactor.factorId isEqualToString:@"1TR"] && !TRFound) {
            if (!firstTRFound) {
                saveTR = [insulinFactor.factorValue floatValue];
                firstTRFound = YES;
            }
            if ([[insulinFactor.timeOfDayBegin earlierDate:now] isEqualToDate:insulinFactor.timeOfDayBegin]) {
                targetRate = [insulinFactor.factorValue floatValue];
                TRFound = YES;
            }
        } else if ([insulinFactor.factorId isEqualToString:@"2CF"] && !CFFound) {
            if (!firstCFFound) {
                saveCF = [insulinFactor.factorValue floatValue];
                firstCFFound = YES;
            }
            if ([[insulinFactor.timeOfDayBegin earlierDate:now] isEqualToDate:insulinFactor.timeOfDayBegin]) {
                corrFactor = [insulinFactor.factorValue floatValue];
                CFFound = YES;
            }
        } else if ([insulinFactor.factorId isEqualToString:@"3KF"] && !KFFound) {
            if (!firstKFFound) {
                saveKF = [insulinFactor.factorValue floatValue];
                firstKFFound = YES;
            }
            if ([[insulinFactor.timeOfDayBegin earlierDate:now] isEqualToDate:insulinFactor.timeOfDayBegin]) {
                carbFactor = [insulinFactor.factorValue floatValue];
                KFFound = YES;
            }
        }
    }
    
    if (!TRFound) {
        targetRate = saveTR;
    }
    if (!CFFound) {
        corrFactor = saveCF;
    }
    if (!KFFound) {
        carbFactor = saveKF;
    }
    
}

-(NSString *) timeOfDayStringWithSched:(NSString *)sched {

    if (!sched) {
        return @"Tap To Select Time Of Day";
    }
    NSString *part1;
    if ([[event valueForKey:@"isBeforeSchedule"] boolValue] == YES) {
        part1 = @"Before ";
    } else {
        part1 = @"After ";
    }

    return [part1 stringByAppendingString:sched];
    
}

-(void)setTotalSites {
    
    totalSites = 0;
    
    for (Site *loopSite in sitesArray) {
        totalSites += [loopSite.useCount floatValue];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {	
    
    [super viewDidLoad]; 
    
    tblSection0Cells = [[NSArray alloc] initWithObjects:dateCell, nil];
    tblSection1Cells = [[NSArray alloc] initWithObjects:glucoseCarbCell, insulinDoseCell, insulinBrandSiteCell, nil];
    tblSection2Cells = [[NSArray alloc] initWithObjects:ketoneCell, nil];
    tblSection3Cells = [[NSArray alloc] initWithObjects:noteCell, nil];
    
    tblSections = [[NSArray alloc] initWithObjects:tblSection0Cells, tblSection1Cells, tblSection2Cells, tblSection3Cells, nil];


    alertTargetRate = [[UIAlertView alloc] initWithTitle:@"Insulin Calculation Problem" message:@"The factors used to calculate your rapid-acting insulin dose are not set!!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Go There", nil];

    alertInsulin = [[UIAlertView alloc] initWithTitle:@"No Prescribed Insulin" message:@"Insulin that is prescribed to you is not set up yet." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Go There", nil];
    
    dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.locale = [NSLocale autoupdatingCurrentLocale];
    
    numFmt  = [[NSNumberFormatter alloc] init];
    
    self.numericChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    
    [self.searchDisplayController setActive:YES];  
    
    if (delegate) { 
        self.title = @"Add Log Entry";
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEventAdd:)];
        self.navigationItem.rightBarButtonItem = buttonItem;
        event.eventDate = [NSDate date];
        event.calcType = settings.calcType;
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveEvent:)];
        self.navigationItem.leftBarButtonItem = buttonItem;
        event.DailySchedule = [settings.dailyScheduleArray objectAtIndex:[self indexOfCurrentSched]];
        event.isBeforeSchedule = [NSNumber numberWithBool:YES];
        if (settings.useIOB == YES) {
            [self setEventIOBValues];
        }
    } else {
        self.title = @"Edit Log Entry";
        targetRate = [event.targetRate floatValue];
        corrFactor = [event.corrFactor floatValue];
        carbFactor = [event.carbFactor floatValue];
    }

    timeOfDay.text = [self timeOfDayStringWithSched:event.DailySchedule.name];
    
    eventDate.userInteractionEnabled = YES;
    UIGestureRecognizer *singleTapEventDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEventDatePicker:)];
    [eventDate addGestureRecognizer:singleTapEventDate];

    timeOfDay.userInteractionEnabled = YES;
    UIGestureRecognizer *singleTapTimeOfDay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTimeOfDayPicker:)];
    [timeOfDay addGestureRecognizer:singleTapTimeOfDay];
    
    insulinBrand.userInteractionEnabled = YES;
    UIGestureRecognizer *singleTapInsulin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInsulinPicker:)];
    [insulinBrand addGestureRecognizer:singleTapInsulin];
    
    site.userInteractionEnabled = YES;
    UIGestureRecognizer *singleTapSite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSitePicker:)];
    [site addGestureRecognizer:singleTapSite];
    
    ketone.userInteractionEnabled = YES;
    UIGestureRecognizer *singleTapKetone = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKetonePicker:)];
    [ketone addGestureRecognizer:singleTapKetone];
    
    note.userInteractionEnabled = YES;
    UIGestureRecognizer *singleTapNote = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNote:)];
    [note addGestureRecognizer:singleTapNote];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calcInsulin)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    
	[dateFmt setDateStyle:NSDateFormatterLongStyle];
	[dateFmt setTimeStyle:NSDateFormatterShortStyle];
    
    eventDate.text = [dateFmt stringFromDate:event.eventDate];
    
    //Load Sites
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Site" inManagedObjectContext:managedObjectContext]];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"useCount" ascending:YES];
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, sortDescriptor1, nil];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"active = YES"];
    fetchRequest.predicate = pred;
	[fetchRequest setSortDescriptors:sortDescriptors];
    
	NSError *error = nil;
    self.sitesArray = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    fetchRequest.predicate = nil;
    
    if (!event.Site && [sitesArray count] > 0) {
        event.Site = [sitesArray objectAtIndex:0];
    }
    
    if (error) [sitesArray addObject:@"no sites"];
    
    site.text = event.Site.name;
    
    //load KetoneValues
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"KetoneValue" inManagedObjectContext:managedObjectContext]];
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
	sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	[fetchRequest setSortDescriptors:sortDescriptors];
    
	error = nil;
    self.ketoneArray = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (error) [ketoneArray addObject:@"no sites"];
    
    if (event.KetoneValue) {
        ketone.text = event.KetoneValue.name;
    } else {
        ketone.text = @"n/a";
    }

    glucoseUnitLabel.text = [settings glucoseLiteral];
    
    self.tableView.backgroundView = settings.tableViewBgView;
    componentIOB.textColor = settings.kRedColor;
    componentExercise.textColor = settings.kRedColor;
    
    didChangeStuff = NO;
    didSelectNewSite = NO;
    self.noCalc = YES;
    
    self.glucose.inputAccessoryView = self.accessoryView;
    self.totalCarb.inputAccessoryView = self.accessoryView;
    self.insulinAmt.inputAccessoryView = self.accessoryView;
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calcInsulin)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    
    //stuff that is updated in pushed VC's
    [numFmt setPositiveFormat:@"######"];
    if (self.event.totalCarb == NULL) {
        totalCarb.text= @"";
    } else {
        totalCarb.text = [numFmt stringFromNumber:self.event.totalCarb];
    }
    
    if ([self.event.EventFoods count] > 0) {
        if ([self.event.EventFoods count] == 1) {
            foodLabel.text = [NSString stringWithFormat:@"%d Food",[self.event.EventFoods count]];
        } else {
            foodLabel.text = [NSString stringWithFormat:@"%d Foods",[self.event.EventFoods count]];
        }
    } else {
        foodLabel.text = @"Tap To Select Foods";
    }
    
    float round=0;
    if (!self.event.glucose || [self.event.glucose intValue] == 0) {
        glucose.text = @"";
    } else {
        if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
            round = 0.1f;
        } else {
            round = 1.0f;
        }
        glucose.text = [settings formatToRoundedString:[settings glucoseConvert:self.event.glucose toExternal:YES] accuracy:[NSNumber numberWithFloat:round]];
    }
    
    if (!event.InsulinBrand && self.delegate) { // only in add mode
        for (InsulinBrand *insulin in settings.prescribedInsulinArray) { // set to first prescribed
            if ([insulin.prescribed intValue] == 1 && ![[insulin.classification substringFromIndex:1] isEqualToString:LONG_INSULIN]) {
                event.InsulinBrand = insulin;
                break;
            }
        }
    }
    
    [self setTextForInsulinRows];
    
    insulinAmt.text = [settings formatToRoundedString:event.insulinAmt accuracy:nil];
    
    if (reloadNote) {
        reloadNote = NO;
        [self.tableView reloadData];
    }
    
    note.text = self.event.note;
    
    if (delegate) { // add mode
        [self setupFormulaFactorsByTime];
    }

    if (delegate && [settings.calcType intValue] == INSULIN_CALC_FORMULA && targetRate == 0 && [[event.InsulinBrand.classification substringFromIndex:1] isEqualToString:RAPID_INSULIN]) {
        [alertTargetRate show];
    }

    if (event.disableIOB == nil) event.disableIOB = [NSNumber numberWithBool:NO];

    if (settings.useIOB == NO) {
        event.disableIOB = [NSNumber numberWithBool:YES];
    }
    
    UIImage *image = nil;
    if (settings.useIOB == YES) {
        
        if ([event.disableIOB boolValue] == YES) {
            image = [UIImage imageWithContentsOfFile:[NSBundle pathForResource:@"IOB-on-icon" ofType:@"png" inDirectory:[[NSBundle mainBundle] bundlePath] ] ];
            [IOBButton setImage:image forState:UIControlStateNormal];
            IOBStrike.hidden = NO;
        } else {
            image = [UIImage imageWithContentsOfFile:[NSBundle pathForResource:@"IOB-off-icon" ofType:@"png" inDirectory:[[NSBundle mainBundle] bundlePath] ] ];
            [IOBButton setImage:image forState:UIControlStateNormal];
            IOBStrike.hidden = YES;
        }
        
    } else {
        self.IOBButton.hidden = YES;
        self.IOBStrike.hidden = NO;
    }

#ifdef LOG_MAX_FOR_LITE
    IOBView.hidden = YES;
    ExerciseView.hidden = YES;
    IOBButton.hidden = YES;
    exerciseButton.hidden = YES;
    foodLabel.hidden = YES;
    foodButton.hidden = YES;
    
    
#endif
    
    [self setTotalSites];

    [self calcInsulin];
    self.noCalc = NO;
    
    self.glucose.textAlignment = UITextAlignmentCenter;
    self.insulinAmt.textAlignment = UITextAlignmentRight;
    self.totalCarb.textAlignment = UITextAlignmentCenter;

}

-(void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self removePickersAndResignButNot:nil];
    
    self.event.glucose = [numFmt numberFromString:glucose.text];
    
    if (self.event.totalCarb) {
        self.event.totalCarb = [numFmt numberFromString:totalCarb.text];
    }

    self.event.targetRate = [NSNumber numberWithFloat:targetRate];
    self.event.corrFactor = [NSNumber numberWithFloat:corrFactor];
    self.event.carbFactor = [NSNumber numberWithFloat:carbFactor];
    //self.event.note = note.text;
    [self calcInsulin];
    
    [dateFmt setDateFormat:@"yyyy-MM-dd"];
    event.fmtDate = [dateFmt stringFromDate:event.eventDate];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ viewWillDisappear",self.class]];
	}
    
    if (didChangeStuff) {
        if (delegate) {
            if ([[[delegate class] description] isEqualToString:@"LogByMonthViewController"]) {
                [(LogByMonthViewController *)delegate setRecalcSections:YES];
            } else if  ([[[delegate class] description] isEqualToString:@"LogByDayViewController"]) {
                [[(LogByDayViewController *)delegate tableView] reloadData];
            }
        } else {
            NSArray *navStack = self.navigationController.viewControllers;
            for (int i=0 ; i < [navStack count] ; i++) {
                if ([[[[navStack objectAtIndex:i] class] description] isEqualToString:@"LogByDayViewController"]) {
                    [[[navStack objectAtIndex:i] tableView] reloadData];
                } else if ([[[[navStack objectAtIndex:i] class] description] isEqualToString:@"LogByMonthViewController"]) {
                    [(LogByMonthViewController *)[navStack objectAtIndex:i] setRecalcSections:YES];
                }
            }
        }
        didChangeStuff = NO;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self ];  // prevents button from appearing on other VC's 
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation //for iOS 5 only...iOS 6 uses info.plist
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - textField delegate

-(void)setHiddenOnAllStrikes:(BOOL)hidden {
    
    if (settings.useIOB == NO) {
        IOBStrike.hidden = NO;
    } else {
        IOBStrike.hidden = hidden;
    }
    ExerciseStrike.hidden = hidden;
    carbStrike.hidden = hidden;
    glucoseStrike.hidden = hidden;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string length] > 0 && ![numericChars characterIsMember:[string characterAtIndex:0]])
        return NO;
    
    if (textField == glucose && [settings.glucoseUnit intValue] != GLUCOSE_UNIT_MMOL && [string isEqualToString:@"."]) { // mg/Dl doesn't accept decimal
        return NO;
    }
    
    if (textField == glucose && [settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL && [string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location != NSNotFound) {
        return NO;
    }
    
    if (textField == insulinAmt && [string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location != NSNotFound) {
        return NO;
    }
    
    if (textField == insulinAmt) {
        event.insulinAmtIsManual = [NSNumber numberWithBool:YES];

    } else if (textField == glucose) {
        event.insulinAmtIsManual = [NSNumber numberWithBool:NO];

    } else if (textField == totalCarb) {
        event.insulinAmtIsManual = [NSNumber numberWithBool:NO];
    }
    
    if ([event.insulinAmtIsManual boolValue] == YES) {
        [self setHiddenOnAllStrikes:NO];
    } else {
        [self setHiddenOnAllStrikes:YES];
    }
    
    if (textField == totalCarb) {
        //carb value manually keyed, remove all foods
        event.insulinAmtIsManual = [NSNumber numberWithBool:NO];
        settings.manualCarb = YES;
        if ([event.EventFoods count] > 0) {
            [event removeEventFoods:[NSSet setWithArray:[event.EventFoods allObjects]]];
        }
        foodLabel.text = @"Tap To Select Foods";
    }

    didChangeStuff = YES;

    return YES;
    
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self removePickersAndResignButNot:textField];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    return YES;
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == insulinAmt) {
        event.insulinAmt = [numFmt numberFromString:insulinAmt.text];
    }
    
    [textField resignFirstResponder];
    return YES;
    
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == glucose || textField == totalCarb) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [[tblSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0 && indexPath.section == 2) {
        [self showKetonePicker:nil];
    } else if (indexPath.row == 0 && indexPath.section == 3) {
        [self showNote:nil];
    } else if (indexPath.row == 0 && indexPath.section == 1) { //glucose carb cell 
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
#ifdef LOG_MAX_FOR_LITE
        return;
#endif
        [self showFood:nil];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0 && indexPath.section == 3) {
        CGSize textViewSize = [event.note sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0f] constrainedToSize:CGSizeMake(260, 10000)];
        textViewSize.height += 50;
        textViewSize.width = 260;
        CGRect frame = note.frame;
        frame.size = textViewSize;
        if (frame.size.height < 10.0f) frame.size.height = 100.f;
        note.frame = frame;
        return frame.size.height + 30.0f;
    } else  if (indexPath.row == 0 && indexPath.section == 0) {
        return 54.0f;
    } else  if (indexPath.row == 0 && indexPath.section == 1) {
        return 68.0f;
    } else  if (indexPath.row == 1 && indexPath.section == 1) {
        return 118.0f;
    } else {
        return 44.0f;
    }
    
}

#pragma mark - Action Methods

- (void)saveEvent:(id)sender {
    
    if ([[numFmt numberFromString:glucose.text] intValue] >= [settings.ketoneThreshold intValue] && event.KetoneValue == nil) {
        [self showKetonePicker:nil];
        return;
    }
    
    [self calcInsulin];
    
	event.glucose = [numFmt numberFromString:glucose.text];

    if (totalCarb.text.length == 0) {
        event.totalCarb = NULL;
    } else {
        event.totalCarb  = [numFmt numberFromString:totalCarb.text];
    }
    
    event.targetRate = [NSNumber numberWithFloat:targetRate];
    event.corrFactor = [NSNumber numberWithFloat:corrFactor];
    event.carbFactor = [NSNumber numberWithFloat:carbFactor];
    event.calcType = settings.calcType;
    event.roundingAccuracy = settings.roundingAccuracy;
    
    float useCount = [event.Site.useCount floatValue];
    event.Site.useCount = [NSNumber numberWithFloat:++useCount];

    [dateFmt setDateFormat:@"yyyy-MM-dd"];
    event.fmtDate = [dateFmt stringFromDate:event.eventDate];
    [dateFmt setDateFormat:@"yyyy-MM"];
    event.fmtMonth = [dateFmt stringFromDate:event.eventDate];
    
    [settings cancelNotificationsOfType:event.InsulinBrand.brandName];
    [settings scheduleInsulinNotification:event.InsulinBrand fromDate:event.eventDate];
    
	NSError *error = nil;
    
	if (![self.managedObjectContext save:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ saveEvent",self.class]];
	}
	
    if (self.delegate) { // adding new one
        [self.delegate dismissAddEvent];
        if ([event.KetoneValue.waterAlert boolValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"High Ketones" message:@"Drink Plenty of Water"
                                                           delegate:self.delegate cancelButtonTitle:@"I Promise" otherButtonTitles: nil];
            [alert show];	
        }
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

#ifndef LOG_MAX_FOR_LITE
    
	[Appirater userDidSignificantEvent:YES];

#endif
}

- (void)cancelEventAdd:(id)sender {
    
    [self.managedObjectContext deleteObject:event]; 

    [self.delegate dismissAddEvent];
    
}

- (void)updateEventDate {
    
    didChangeStuff = YES;
    dateFmt.dateStyle = NSDateFormatterLongStyle;
    dateFmt.timeStyle = NSDateFormatterShortStyle;
    eventDate.text = [dateFmt stringFromDate:[datePicker date]];
    event.eventDate = [datePicker date];
    [dateFmt setDateFormat:@"yyyy-MM-dd"];
    event.fmtDate = [dateFmt stringFromDate:event.eventDate];
    [dateFmt setDateFormat:@"yyyy-MM"];
    event.fmtMonth = [dateFmt stringFromDate:event.eventDate];
    
    [self setupFormulaFactorsByTime];
    [self setEventIOBValues];
    [self calcInsulin];
    
}

- (IBAction)showFood:(id)sender {
    
    FoodController *foodController = [[FoodController alloc] initWithNibName:@"FoodController" bundle:nil];
    foodController.managedObjectContext = self.managedObjectContext;
    foodController.event = self.event;
    foodController.settings = self.settings;
    [self.navigationController pushViewController:foodController animated:YES];
    
}

-(void)showNote:(id)sender {
    
    [self removePickersAndResignButNot:nil];
    NoteViewController *noteController = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
    noteController.event = self.event;
    reloadNote = YES;
    [self.navigationController pushViewController:noteController animated:YES];

}


#pragma mark - Insulin Calculation and Display

-(NSString *) calcLabelGlucoseString {
    
    float x = 0;
    if ([event.calcType intValue] == INSULIN_CALC_FORMULA) {
        if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
            x = 0.1f;
        } else {
            x = 1.0f;
        }
        return  [NSString stringWithFormat:@"((%@ - %@) / %@)",
                 [settings formatToRoundedString:[settings glucoseConvert:event.glucose toExternal:YES] accuracy:[NSNumber numberWithFloat:x]],
                 [settings formatToRoundedString:[settings glucoseConvert:[NSNumber numberWithFloat:targetRate ] toExternal:YES] accuracy:[NSNumber numberWithFloat:x]],
                 [settings formatToRoundedString:[settings glucoseConvert:[NSNumber numberWithFloat:corrFactor] toExternal:YES] accuracy:[NSNumber numberWithFloat:x]]];
    } else {
        return @"Sliding";
    }
    
}

-(NSString *) calcLabelCarbString {
    
    if ([event.calcType intValue] == INSULIN_CALC_FORMULA) {
        return  [NSString stringWithFormat:@"(%d / %d)",
                 [event.totalCarb intValue],
                 [[NSNumber numberWithFloat:carbFactor] intValue]];
    } else {
        return @"Scale";
    }
    
}

-(NSString *) calcLabelIOBString {
    
    float lastRapidHours = 0.0f;
    if (event.lastRapidEventDate) {
        NSTimeInterval lastRapidInterval = [event.eventDate timeIntervalSinceDate:event.lastRapidEventDate];
        lastRapidHours = lastRapidInterval / 3600.0f;
    }
    
    NSString *hours = nil;
    if (lastRapidHours < 0.0f) {
        lastRapidHours = 0.0f;
    }
    
    if (lastRapidHours > 24.0f)
        hours = @"over 24";
    else
        hours = [settings formatToRoundedString:[NSNumber numberWithFloat:lastRapidHours] accuracy:[NSNumber numberWithFloat:0.1f]];
    
    NSString *string = [NSString stringWithFormat:@"%@ hrs : %@",hours ,[settings formatToRoundedString:event.iobFactor accuracy:[NSNumber numberWithFloat:1.0f]]];
    string = [string stringByAppendingString:@"% of "];
    string = [string stringByAppendingString:[settings formatToRoundedString:event.lastRapidDose accuracy:nil]]; 

    return string;
    
}

-(void)setEventIOBValues {  //not a setter method
    
    if (settings.useIOB == NO) {
        self.IOBStrike.hidden = NO;
        return;
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ setEventIOBFactor",self.class]];
    }	
    
    Event *lastRapidEvent = nil;
    if ([result count]) {
        for (Event *event_ in result) {
            if ([[event_.InsulinBrand.classification substringFromIndex:1] isEqualToString:RAPID_INSULIN] && ![event_.eventDate isEqualToDate:event.eventDate]) {
                lastRapidEvent = event_;
                break;
            }
        }
    }
    
    if (lastRapidEvent) {
        NSTimeInterval lastRapidInterval = [event.eventDate timeIntervalSinceDate:lastRapidEvent.eventDate];
        float lastRapidHours = lastRapidInterval / 3600.0f;
        event.lastRapidDose = nil;
        event.iobFactor = nil;
        
        int i = 0;
        for (i = ([settings.IOBFactorArray count] - 1); i >= 0; i--) {
            if ([[[settings.IOBFactorArray objectAtIndex:i] valueForKey:@"hours"] floatValue] <= lastRapidHours) {
                event.iobFactor = [[settings.IOBFactorArray objectAtIndex:i] valueForKey:@"percentReduce"];
                event.lastRapidDose = lastRapidEvent.insulinAmt;
                break;
            }
        }
        
        event.lastRapidEventDate = lastRapidEvent.eventDate;
        
        if (i < 0) { //more recent than earliest range IOB is 100%
            event.iobFactor = [NSNumber numberWithFloat:100.0f];
            event.lastRapidDose = lastRapidEvent.insulinAmt;  ///////// this needs to calc based on blood sugar insulin amt only.
        }
        
    } else {
        event.lastRapidEventDate = nil;
        event.iobFactor = nil;
        event.lastRapidDose = nil;
    }
}

-(void)setTextForInsulinRows { //not a setter method
    
    if (event.InsulinBrand.brandName) {
        insulinBrand.text = event.InsulinBrand.brandName;
        if ([[event.InsulinBrand.classification substringFromIndex:1] isEqualToString:RAPID_INSULIN]) {
            takeAsPrescribed.hidden = YES;
        } else {
            takeAsPrescribed.hidden = NO;
            takeAsPrescribed.text = [NSString stringWithFormat:@"Take %@ As Prescribed",event.InsulinBrand.brandName];
        }
    } else {
        insulinBrand.text = @"Tap To Select Insulin";
        takeAsPrescribed.text = @" ";
        takeAsPrescribed.hidden = NO;
        takeAsPrescribed.text = [NSString stringWithFormat:@"Select Insulin Below"];
    }
    
}

-(void) doExerciseIOBButtonDisableAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Exercise and IOB buttons\nare disabled while overriding\ncalculated insulin dose"
                                                   delegate:self.delegate cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];	
    
}

-(IBAction)IOBButton:(id)sender {

    if (settings.useIOB == NO) {
        event.disableIOB = [NSNumber numberWithBool:YES];
        IOBButton.hidden = YES;
        IOBStrike.hidden = NO;
        return;
    }
    
    if ([event.insulinAmtIsManual boolValue] == YES) {
        [self doExerciseIOBButtonDisableAlert];
        return;
    }
    
    UIImage *image = nil;
    if ([event.disableIOB boolValue] == YES) {
        event.disableIOB = [NSNumber numberWithBool:NO];
        image = [UIImage imageWithContentsOfFile:[NSBundle pathForResource:@"IOB-off-icon" ofType:@"png" inDirectory:[[NSBundle mainBundle] bundlePath] ] ];
        [IOBButton setImage:image forState:UIControlStateNormal];
        IOBStrike.hidden = YES;
    } else {
        event.disableIOB = [NSNumber numberWithBool:YES];
        image = [UIImage imageWithContentsOfFile:[NSBundle pathForResource:@"IOB-on-icon" ofType:@"png" inDirectory:[[NSBundle mainBundle] bundlePath] ] ];
        [IOBButton setImage:image forState:UIControlStateNormal];
        IOBStrike.hidden = NO;
    }
    
    [self calcInsulin];
}

- (void)calcInsulin {
    
    float bs=0;
    float c=0;
    float totalUnits=0;
    float glucoseUnits=0;
    float carbUnits=0;
    float IOBUnits=0;
    float exerciseUnits=0;  //Model Object Implementation Guide says float is inherently inaccurate and " It may be more appropriate to use an NSNumber or NSDecimalNumber representation, as these provide greater accuracy and a rich set of rounding behaviors." May want to change this to use one of those classes
	
    event.glucose = [settings glucoseConvert:[numFmt numberFromString:glucose.text] toExternal:NO];
    
    event.totalCarb = [numFmt numberFromString:totalCarb.text];
    
    if ([event.calcType intValue] == INSULIN_CALC_FORMULA) {
        
        if (corrFactor == 0) corrFactor = 1;
        if (carbFactor == 0) carbFactor = 1;
        
        if (glucose.text.length == 0) {
            bs = targetRate;  //"nullifies" glucose part of formula so only carb part is used for dose calc.
        } else {
            bs = [event.glucose floatValue];
        }
        
        c = [event.totalCarb floatValue];
        
        glucoseUnits    = ((bs - targetRate) / corrFactor);
        carbUnits       = (c / carbFactor);
        
        totalUnits = glucoseUnits + carbUnits;
        
    } else { // sliding scale
        
        totalUnits = 0;
        for (int i=[settings.insulinScaleArray count] - 1 ; i >= 0 ; i--) {
            if ([event.glucose intValue] >= [[[settings.insulinScaleArray objectAtIndex:i] rangeMin] intValue]) {
                totalUnits = [[[settings.insulinScaleArray objectAtIndex:i] units] floatValue];
                break;
            }
        }
        glucoseUnits = totalUnits;
    }

    //default to zero above
    if ([event.exerciseFactor floatValue])
        exerciseUnits   = (totalUnits * [event.exerciseFactor floatValue]) - totalUnits;
    
    if (event.lastRapidDose) 
        IOBUnits = [event.lastRapidDose floatValue] * ([event.iobFactor floatValue] / 100.0f);

    if ([event.disableIOB boolValue] == NO) {
        totalUnits -= IOBUnits;
    }
    
    totalUnits += exerciseUnits;

    if (totalUnits < 0) {
        totalUnits = 0;
    }
    
    //setup display of above calculations

    if ([insulinAmt isFirstResponder] || [event.insulinAmtIsManual boolValue] == YES) {  //prevents infinite loop and saves value keyed, bypassing calculations
        insulinAmt.textColor = settings.kRedColor;
        unitsLabel.textColor = settings.kRedColor;
        calcNoCalc.textColor = settings.kRedColor;
        calcNoCalc.text = @"Keyed";
        [self setHiddenOnAllStrikes:NO];
        event.insulinAmt = [numFmt numberFromString:insulinAmt.text];
        didChangeStuff = YES;
        //return;
    } else {
        if (self.noCalc) { // just display total units from database using rounding from event record.
            if (!event.roundingAccuracy || [event.roundingAccuracy floatValue] == 0)
                event.roundingAccuracy = settings.roundingAccuracy;
            insulinAmt.text = [settings formatToRoundedString:event.insulinAmt accuracy:event.roundingAccuracy]; 
        } else {
            insulinAmt.text = [settings formatToRoundedString:[NSNumber numberWithFloat:totalUnits] accuracy:nil];
            event.insulinAmt = [settings roundTheNumber:[NSNumber numberWithFloat:totalUnits] accuracy:nil];
            event.roundingAccuracy = settings.roundingAccuracy;
        }
        insulinAmt.textColor = settings.kGreenColor;
        unitsLabel.textColor = settings.kGreenColor;
        calcNoCalc.textColor = settings.kGreenColor;
        calcNoCalc.text = @"Calculated";
        self.noCalc = NO;
    }
    
    calcLabelGlucose.text = [self calcLabelGlucoseString];
    calcLabelCarb.text = [self calcLabelCarbString];
    
    NSNumber *round = [NSNumber numberWithFloat:0.01f];
    componentGlucose.text = [settings formatToRoundedString:[NSNumber numberWithFloat:glucoseUnits] accuracy:round];
    componentCarb.text = [settings formatToRoundedString:[NSNumber numberWithFloat:carbUnits] accuracy:round];
    componentIOB.text = [settings formatToRoundedString:[NSNumber numberWithFloat:IOBUnits] accuracy:round];
    calcLabelIOB.text = [self calcLabelIOBString];    
    
    if (exerciseUnits < 0) {
        exerciseUnits *= -1;
        componentExerciseSign.text = @"-";
        componentExerciseSign.textColor = settings.kRedColor;
        componentExercise.textColor = settings.kRedColor;
    } else {
        componentExerciseSign.text = @"+";
        componentExerciseSign.textColor = [UIColor blackColor];
        componentExercise.textColor = [UIColor blackColor];
    }
    
    componentExercise.text = [settings formatToRoundedString:[NSNumber numberWithFloat:exerciseUnits] accuracy:round];
    
    calcLabelExercise.text = [event.exerciseType substringFromIndex:1];
    
}

#pragma mark - Show and Remove Pickers

-(BOOL)removePickersAndResignButNot:(UITextField *)notTextField { //BOOL is used to decide if delay should happen on become first resp
   
    if ([glucose isFirstResponder] && notTextField != totalCarb) {
        [glucose resignFirstResponder];
        return YES;
    }
    
    if ([totalCarb isFirstResponder] && notTextField != glucose) {
        [totalCarb resignFirstResponder];
        return YES;
    }
    
    if ([insulinAmt isFirstResponder]) {
        [insulinAmt resignFirstResponder];
        return YES;
    }
    
    if ([eventDate isFirstResponder]) {
        [eventDate resignFirstResponder];
        datePicker = nil;
        return YES;
    }
    
    if ([ketone isFirstResponder]) {
        [ketone resignFirstResponder];
        ketonePicker = nil;
        return YES;
    }
    
    if ([calcLabelExercise isFirstResponder]) {
        [calcLabelExercise resignFirstResponder];
        exercisePicker = nil;
        return YES;
    }
    
    if ([site isFirstResponder]) {
        [site resignFirstResponder];
        sitePicker = nil;
        return YES;
    }
    
    if ([insulinBrand isFirstResponder]) {
        [insulinBrand resignFirstResponder];
        insulinPicker = nil;
        return YES;
    }
    
    if ([timeOfDay isFirstResponder]) {
        [timeOfDay resignFirstResponder];
        timeOfDayPicker = nil;
        return YES;
    }

    return NO;
    
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

-(UIView *)accessoryView {

    if (_accessoryView) {
        return _accessoryView;
    }
    
    NSArray *buttonView = [[NSBundle mainBundle] loadNibNamed:@"InputAccessory" owner:self options:nil];
    _accessoryView = [buttonView objectAtIndex:0];
    
    self.theCloseButton = (UIButton *)[_accessoryView viewWithTag:CLOSE_BUTTON_TAG];
    [self.theCloseButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return _accessoryView;
    
}


- (void)showTheDatePicker {

    eventDate.inputView = datePicker;
    eventDate.inputAccessoryView = self.accessoryView;
    
    eventDate.canBecomeFirstResponder=YES;
    [eventDate becomeFirstResponder];

}

- (void)showEventDatePicker:(id)sender {
    
    if (datePicker) {
        return;
    }
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker addTarget:self action:@selector(updateEventDate) forControlEvents:UIControlEventValueChanged];
    datePicker.hidden = NO;
    datePicker.minuteInterval = [settings.datePickerInterval intValue];
    datePicker.date = event.eventDate;
	
	datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    if (![self removePickersAndResignButNot:nil]) //delay is to give whatever was first responder to disappear (for animation sake)
        [self showTheDatePicker];
    else
        [self performSelector:@selector(showTheDatePicker) withObject:nil afterDelay:0.3f];

}

-(NSUInteger) indexOfCurrentSched {
    
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *comps = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:event.eventDate];
    [comps setYear:2000];
    [comps setMonth:1];
    [comps setDay:1];
    [comps setSecond:59];
    
    NSDate *theEventDate = [cal dateFromComponents:comps];
    int i=0;
    for (DailySchedule *sched in settings.dailyScheduleArray) {
        if ([[theEventDate earlierDate:sched.endTime] isEqualToDate:theEventDate] && [sched.anyTime boolValue] == NO) {
            break;
        }
        i++;
    }
    if (i == [settings.dailyScheduleArray count]) {
        i--;
    }
    return i;
}

- (void)showThePicker:(NSDictionary *)pickerInfo {
    
    PickerLabel  *theLabel  = [pickerInfo valueForKey:@"label"];
    UIPickerView *thePicker = [pickerInfo valueForKey:@"picker"];
                   
    theLabel.inputView = thePicker;
    theLabel.inputAccessoryView = self.accessoryView;
    theLabel.canBecomeFirstResponder = YES;
    [theLabel becomeFirstResponder];
    
}

- (void)showTimeOfDayPicker:(id)sender {
  
    if (timeOfDayPicker) return;
    
	timeOfDayPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    
	timeOfDayPicker.showsSelectionIndicator = YES;	
	timeOfDayPicker.delegate = self;
	timeOfDayPicker.dataSource = self;
    
    if (!event.DailySchedule) {
        event.DailySchedule = [settings.dailyScheduleArray objectAtIndex:[self indexOfCurrentSched]];
        event.isBeforeSchedule = [NSNumber numberWithBool:YES];
        timeOfDay.text = [self timeOfDayStringWithSched:event.DailySchedule.name];
    }
    
    int i=0;
    for (DailySchedule *loopSched in settings.dailyScheduleArray) {
        if ([loopSched.name isEqualToString:event.DailySchedule.name]) break;
        i++;
    }
    [timeOfDayPicker selectRow:i inComponent:1 animated:NO];
    if ([event.isBeforeSchedule boolValue] == YES) {
        [timeOfDayPicker selectRow:0 inComponent:0 animated:NO];
    } else {
        [timeOfDayPicker selectRow:1 inComponent:0 animated:NO];
    }
	
	timeOfDayPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
//    [self placeCloseButtonOnPicker:timeOfDayPicker];
    
    NSDictionary *pickerInfo = [[NSDictionary alloc] initWithObjectsAndKeys:timeOfDayPicker, @"picker",
                                                                            timeOfDay,       @"label", nil];
    
    if (![self removePickersAndResignButNot:nil]) //delay is to give whatever was first responder to disappear (for animation sake)
        [self showThePicker:pickerInfo];
    else
        [self performSelector:@selector(showThePicker:) withObject:pickerInfo afterDelay:0.3f];
    

        
}

- (void)showSitePicker:(id)sender {
    
    if (sitePicker) return;
    
	sitePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    
	sitePicker.showsSelectionIndicator = YES;	
	sitePicker.delegate = self;
	sitePicker.dataSource = self;
    
    if (event.Site) {
        int i=0;
        for (Site *loopSite in sitesArray) {
            if ([loopSite.name isEqualToString:event.Site.name]) break;
            i++;
        }
        [sitePicker selectRow:i inComponent:0 animated:NO];
    } else {
        event.Site = [sitesArray objectAtIndex:0];
        site.text = event.Site.name;
    }
	
	sitePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
//    [self placeCloseButtonOnPicker:sitePicker];
    
    NSDictionary *pickerInfo = [[NSDictionary alloc] initWithObjectsAndKeys:sitePicker, @"picker",
                                site,       @"label", nil];
    
    if (![self removePickersAndResignButNot:nil]) //delay is to give whatever was first responder to disappear (for animation sake)
        [self showThePicker:pickerInfo];
    else
        [self performSelector:@selector(showThePicker:) withObject:pickerInfo afterDelay:0.3f];
    
}
- (void)showKetonePicker:(id)sender {
    
    if (ketonePicker) return;
    
	ketonePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	ketonePicker.showsSelectionIndicator = YES;	
    ketonePicker.hidden = NO;
	ketonePicker.delegate = self;
	ketonePicker.dataSource = self;
    
    if (event.KetoneValue) {
        int i=0;
        for (KetoneValue *loopKetone in ketoneArray) {
            if (loopKetone == event.KetoneValue) break;
            i++;
        }
        [ketonePicker selectRow:i inComponent:0 animated:NO];
    } else {
        event.KetoneValue = [ketoneArray objectAtIndex:0];
        ketone.text = event.KetoneValue.name;
    }
    
	ketonePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
//    [self placeCloseButtonOnPicker:ketonePicker];
    
    NSDictionary *pickerInfo = [[NSDictionary alloc] initWithObjectsAndKeys:ketonePicker, @"picker",
                                ketone,       @"label", nil];
    
    if (![self removePickersAndResignButNot:nil]) //delay is to give whatever was first responder to disappear (for animation sake)
        [self showThePicker:pickerInfo];
    else
        [self performSelector:@selector(showThePicker:) withObject:pickerInfo afterDelay:0.3f];
    
}

- (IBAction)showExercisePicker:(id)sender {
    
    if ([event.insulinAmtIsManual boolValue] == YES) {
        [self  doExerciseIOBButtonDisableAlert];
        return;
    }

    if (exercisePicker) return;
    
	exercisePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	exercisePicker.showsSelectionIndicator = YES;	
    exercisePicker.hidden = NO;
	exercisePicker.delegate = self;
	exercisePicker.dataSource = self;
    
    if (event.exerciseType) {
        int i=0;
        for (ExerciseType *exerciseType in settings.exerciseTypeArray) {
            if ([exerciseType.typeName isEqualToString:event.exerciseType]) break;
            i++;
        }
        [exercisePicker selectRow:i inComponent:0 animated:NO];
    } else {
        event.exerciseType = [[settings.exerciseTypeArray objectAtIndex:0] typeName];
        calcLabelExercise.text = [event.exerciseType substringFromIndex:1];
    }
    
	exercisePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

//    [self placeCloseButtonOnPicker:exercisePicker];

    NSDictionary *pickerInfo = [[NSDictionary alloc] initWithObjectsAndKeys:exercisePicker, @"picker",
                                calcLabelExercise,       @"label", nil];
    
    if (![self removePickersAndResignButNot:nil]) //delay is to give whatever was first responder to disappear (for animation sake)
        [self showThePicker:pickerInfo];
    else
        [self performSelector:@selector(showThePicker:) withObject:pickerInfo afterDelay:0.3f];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        return;
    }
    
    if (alertView == alertInsulin) {
        InsulinBrandsController *controller = [[InsulinBrandsController alloc] initWithNibName:@"InsulinBrandsController" bundle:nil];
        controller.settings = self.settings;
        controller.fromSettings = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (alertView == alertTargetRate) {
        InsulinFactorController *controller = [[InsulinFactorController alloc] initWithNibName:@"InsulinFactorController" bundle:nil];
        controller.settings = self.settings;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)showInsulinPicker:(id)sender {
    
    if (![settings.prescribedInsulinArray count]) {
        [alertInsulin show];
        return;
    }
    
    if  (insulinPicker) return;
    
	insulinPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
    insulinPicker.hidden = NO;
	insulinPicker.showsSelectionIndicator = YES;	
    
	// this view controller is the data source and delegate
	insulinPicker.delegate = self;
	insulinPicker.dataSource = self;
    
   
    if (event.InsulinBrand) {
        int i=0;
        for (InsulinBrand *loopInsulin in settings.prescribedInsulinArray) {
            if (loopInsulin == event.InsulinBrand) break;
            i++;
        }
        [insulinPicker selectRow:i inComponent:0 animated:NO];
    } else {
        event.InsulinBrand = [settings.prescribedInsulinArray objectAtIndex:0];
        [self setTextForInsulinRows];
    }
	
	insulinPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

//    [self placeCloseButtonOnPicker:insulinPicker];

    NSDictionary *pickerInfo = [[NSDictionary alloc] initWithObjectsAndKeys:insulinPicker, @"picker",
                                insulinBrand,       @"label", nil];
    
    if (![self removePickersAndResignButNot:nil]) //delay is to give whatever was first responder to disappear (for animation sake)
        [self showThePicker:pickerInfo];
    else
        [self performSelector:@selector(showThePicker:) withObject:pickerInfo afterDelay:0.3f];
    
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView == sitePicker) {
        //decrement old one
        event.Site = [sitesArray objectAtIndex:row];
        site.text = event.Site.name;
    } else if (pickerView == ketonePicker ) {
        event.KetoneValue = [ketoneArray objectAtIndex:row];
        ketone.text = event.KetoneValue.name;
    } else if (pickerView == exercisePicker ) {
        event.exerciseType = [[settings.exerciseTypeArray objectAtIndex:row] typeName];
        event.exerciseFactor = [[settings.exerciseTypeArray objectAtIndex:row] factorValue];
        calcLabelExercise.text = [event.exerciseType substringFromIndex:1];
        [self calcInsulin];
    } else if (pickerView == insulinPicker ) {
        event.InsulinBrand = [settings.prescribedInsulinArray objectAtIndex:row];
        insulinBrand.text = event.InsulinBrand.brandName;
        if ([[event.InsulinBrand.classification substringFromIndex:1] isEqualToString:RAPID_INSULIN]) {
            takeAsPrescribed.hidden = YES;
        } else {
            takeAsPrescribed.hidden = NO;
            takeAsPrescribed.text = [NSString stringWithFormat:@"Take %@ As Prescribed",event.InsulinBrand.brandName];
        }
    } else if (pickerView == timeOfDayPicker ) {
        NSString *part1;
        NSString *part2;
        if ([[event valueForKey:@"isBeforeSchedule"] boolValue] == YES) {
            part1 = @"Before ";
        } else {
            part1 = @"After ";
        }
        part2 = event.DailySchedule.name;
        if (component == 0) {
            if (row == 0) {
                [event setValue:[NSNumber numberWithBool:YES] forKey:@"isBeforeSchedule"];
                part1 = @"Before ";
                
            } else {
                [event setValue:[NSNumber numberWithBool:NO] forKey:@"isBeforeSchedule"];
                part1 = @"After ";
            }
        } else {
            event.DailySchedule = [settings.dailyScheduleArray objectAtIndex:row];
            part2 = event.DailySchedule.name;
        }
        timeOfDay.text = [part1 stringByAppendingString:part2];
    } 
    
    return;              
    
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
	if (pickerView == sitePicker) {
        float temp = ([[[sitesArray objectAtIndex:row] useCount] floatValue] / totalSites) * 100;
        NSNumber *rounded = [settings roundTheNumber:[NSNumber numberWithFloat:temp] accuracy:[NSNumber numberWithFloat:1.0f]];
        NSString *siteString = [NSString stringWithFormat:@"%3d%% : %@",[rounded intValue],[[sitesArray objectAtIndex:row] name]];
        return siteString;
    } else if (pickerView == ketonePicker) {
        return [[ketoneArray objectAtIndex:row] name];
    } else if (pickerView == exercisePicker) {
        return [[[settings.exerciseTypeArray objectAtIndex:row] typeName] substringFromIndex:1];
    } else if (pickerView == insulinPicker) {
        return [[settings.prescribedInsulinArray objectAtIndex:row] brandName];
    } else if (pickerView == timeOfDayPicker) {
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
    if (pickerView == timeOfDayPicker) {
        if (component == 0)
            return 80;
        else
            return 220;
    } else if (pickerView == sitePicker) {
        return 300;
    } else {
        return 200;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 35.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == sitePicker) {
        return [sitesArray count];
    } else if (pickerView == ketonePicker) {
        return [ketoneArray count];
    } else if (pickerView == exercisePicker) {
        return [settings.exerciseTypeArray count];
    } else if (pickerView == insulinPicker) {
        return [settings.prescribedInsulinArray count];
    } else if (pickerView == timeOfDayPicker) {
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
    if (pickerView == timeOfDayPicker) {
        return 2;
    } else {
        return 1;
    }
}

#pragma mark - Done Button


- (void)closeButton:(id)sender {
    
    [self removePickersAndResignButNot:nil];
    
}

- (void)viewDidUnload {
    
    unitsLabel = nil;
    [self setUnitsLabel:nil];
    [self setCalcNoCalc:nil];
    [self setUnitsLabel:nil];
    ExerciseStrike = nil;
    carbStrike = nil;
    glucoseStrike = nil;
    IOBView = nil;
    ExerciseView = nil;
    foodButton = nil;
    [super viewDidUnload];
    
}

@end
