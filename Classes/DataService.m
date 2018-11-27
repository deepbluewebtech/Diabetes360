//
//  Settings.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DataService.h"
#import "InsulinScale.h"
#import "InsulinBrand.h"
#import "Settings.h"
#import "DailySchedule.h"
#import "KetoneValue.h"
#import "Site.h"
#import "ExerciseType.h"
#import "IOBFactor.h"
#import "ColorScheme.h"
#import "DiabetesAppDelegate.h"
#import "CSVParserReceiver.h"
#import "CSVParser.h"

@interface DataService ()


- (void) scheduleNotifications;
- (void) scheduleDailyNotification:(DailySchedule *)schedItem;
- (NSDate *)defaultPumpSiteTime;
- (void) schedulePumpSiteNotifications;
- (void) loadDefaultSchemes;
- (void)loadStaticTablesFromPlists;

@end

@implementation DataService

@synthesize calcType;
@synthesize insulinScaleArray;
@synthesize IOBFactorArray;
@synthesize exerciseTypeArray;
@synthesize dailyScheduleArray;
@synthesize prescribedInsulinArray;

@synthesize datePickerInterval;
@synthesize glucoseUnit;
@synthesize pumpSiteInterval;
@synthesize pumpSiteTime;
@synthesize pumpSiteAlert;
@synthesize roundingAccuracy;
@synthesize ketoneThreshold;
@synthesize quickSettings;
@synthesize runInitialSetup;

@synthesize activeDBName;
@synthesize tableViewBgView;
@synthesize manualCarb;
@synthesize logCount;

@synthesize colorScheme;

@synthesize kTblBgColor;
@synthesize kNavBarColor;
@synthesize kTblRowSelColor;
@synthesize kRedColor;
@synthesize kGreenColor;

@synthesize managedObjectContext;

-(id) init {
    
    self = [super init];
    if (self) {
        
        DiabetesAppDelegate *appDelegate = (DiabetesAppDelegate *) [[UIApplication sharedApplication] delegate];
        managedObjectContext = appDelegate.managedObjectContext;
        
        self.activeDBName = appDelegate.activeDBName;
        
        if ([appDelegate.loadStaticTables boolValue] == YES) {
            [self loadStaticTablesFromPlists];
        }
        
        self.kTblBgColor = [UIColor colorWithRed:204/255.0f green:232/255.0f blue:232/255.0f alpha:1.0f];
        self.kNavBarColor = [UIColor colorWithRed:.5 green:0 blue:0 alpha:1];
        self.kTblRowSelColor = [UIColor colorWithRed:179/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
        self.kRedColor = [UIColor colorWithRed:184.0f/255.0f green:0.0f/255.0f blue:2.0f/255.0f alpha:1.0f];
        self.kGreenColor = [UIColor colorWithRed:57.0f/255.0f green:153.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        
        self.manualCarb = NO;
        [self refreshLogCount];

        [self loadAllCoreDataArrays];
        
    }
    
    return self;
}

-(UIView *)tableViewBgView {
    
    if (tableViewBgView) {
        return tableViewBgView;
    }
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    bgView.backgroundColor = self.kTblBgColor;
    return bgView;
    
}

-(UIView *)accessoryView {
    
    if (_accessoryView) {
        return _accessoryView;
    }
    
    NSArray *buttonView = [[NSBundle mainBundle] loadNibNamed:@"InputAccessory" owner:self options:nil];
    _accessoryView = [buttonView objectAtIndex:0];
    
    self.theCloseButton = (UIButton *)[_accessoryView viewWithTag:99];
    
    return _accessoryView;
    
}


-(void) databaseErrorAlert:(NSError *)error more:(NSString *)more {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Serious Error!!!" message:[NSString stringWithFormat:@"There was an error saving the database!!\nVisit http://diabetes360.deepbluewebtech.com\n for vendor support information.\n%@\n%@\n%@",more, error, error.userInfo] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];	
    
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(void)loadSettingsEntity {

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:managedObjectContext];
    NSError *error = nil;
    [request setEntity:entity];
    [request setSortDescriptors:nil];

    NSMutableArray *settingsResult = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (error != nil) {
        [self databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ init-top",self.class]];
    }	
    
    //when adding settings, remember to add code in saveSettings to save them...
    if ([settingsResult count] == 0) {  //no settings, do defaults
        self.datePickerInterval = [NSNumber numberWithInt:5];
        self.glucoseUnit = [NSNumber numberWithInt:0]; // use enum...
        self.ketoneThreshold = [NSNumber numberWithInt:250];
        self.roundingAccuracy = [NSNumber numberWithFloat:0.01];
        self.pumpSiteAlert = [NSNumber numberWithBool:NO];
        self.pumpSiteInterval = [NSNumber numberWithInt:5];
        self.pumpSiteTime = [self defaultPumpSiteTime];
        self.quickSettings = [NSNumber numberWithInt:0];
        self.calcType = [NSNumber numberWithInt:0];
        self.runInitialSetup = [NSNumber numberWithBool:1];
        self.useIOB = [NSNumber numberWithBool:YES];
        [self saveSettings];
    } else {
        Settings *settings = [settingsResult objectAtIndex:0];
        self.datePickerInterval = settings.datePickerInterval;
        self.glucoseUnit = settings.glucoseUnit;
        self.ketoneThreshold = settings.ketoneThreshold;
        self.roundingAccuracy = settings.roundingAccuracy;
        self.pumpSiteAlert = settings.pumpSiteAlert;
        self.pumpSiteInterval = settings.pumpSiteInterval;
        self.pumpSiteTime = settings.pumpSiteTime;
        self.quickSettings = settings.quickSettings;
        self.calcType = settings.calcType;
        self.runInitialSetup = settings.runInitialSetup;
        self.useIOB = [settings.useIOB boolValue];
    }

}

-(void)loadInsulinScale {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InsulinScale" inManagedObjectContext:managedObjectContext];
    NSError *error = nil;
    [request setEntity:entity];
    [request setSortDescriptors:nil];
    
    NSMutableArray *settingsResult = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if ([settingsResult count]) {
        self.insulinScaleArray = settingsResult;
        [self sortScale];
    } else {  //present vc to set these
        [self saveSettings];
    }
    
}

-(void)loadIOBFactor {

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"IOBFactor" inManagedObjectContext:managedObjectContext];
    NSError *error = nil;
    [request setEntity:entity];
    [request setSortDescriptors:nil];
    
    NSMutableArray *settingsResult = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if ([settingsResult count]) {
        self.IOBFactorArray = settingsResult;
        [self sortIOBFactor];
    }
    
}

-(void)loadExerciseType {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExerciseType" inManagedObjectContext:managedObjectContext];
    NSError *error = nil;
    [request setEntity:entity];
    [request setSortDescriptors:nil];
    
    NSMutableArray *settingsResult = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

    if ([settingsResult count]) {
        self.exerciseTypeArray = settingsResult;
        [self sortExerciseType];
    } else {  //present vc to set these
        NSLog(@"Empty result on IOBFactor");
    }

}

-(void) loadPrescribedInsulin {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"InsulinBrand"];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"classification" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"brandName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor1, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"prescribed = %@", [NSNumber numberWithBool:YES]];
    [request setPredicate:pred];
    
    NSError *error = nil;
    self.prescribedInsulinArray = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy]; //this assumes there is data in the table from the batch loader; crash otherwise
    if (error) [self databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ loadPrescribedInsulin",self.class]];
    
}


-(void)loadColorScheme {

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ColorScheme" inManagedObjectContext:managedObjectContext];
    NSError *error = nil;
    [request setEntity:entity];
    [request setSortDescriptors:nil];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"active = %@", [NSNumber numberWithBool:YES]];
    [request setPredicate:pred];

    NSMutableArray *settingsResult = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

    if (error) [self databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ init-colorscheme",self.class]];
    
    if ([settingsResult count]) {
        self.colorScheme = [settingsResult objectAtIndex:0];
    } else { //setting default scheme here because load utility not setup for iOS (UIColor).  It runs under MAC OS X (NSColor)
        [self loadDefaultSchemes];
        [self saveSettings];
    }

}

-(void)loadDailySchedule {

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DailySchedule" inManagedObjectContext:managedObjectContext];
    NSError *error = nil;
    [request setEntity:entity];
    [request setSortDescriptors:nil];
    
    NSMutableArray *settingsResult = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (error != nil) {
        [self databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ init-DailySchedule",self.class]];
    }	
    
    if ([settingsResult count]) {
        self.dailyScheduleArray = settingsResult;
        [self sortSchedule];
    } else {
        self.dailyScheduleArray = nil;
        NSLog(@"Empty Daily Schedule entity!!");
    }
}

-(void)loadAllCoreDataArrays {
    
    [self loadSettingsEntity];
    [self loadInsulinScale];
    [self loadIOBFactor];
    [self loadExerciseType];
    [self loadPrescribedInsulin];
    [self loadColorScheme];
    [self loadDailySchedule];

}

-(void)importCSV {
    
    //need context undo if anything fails.
    //test for commas in quoted strings.
    
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Diabetes360Log.csv"];
    NSError *error = nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
	if ([fileManager fileExistsAtPath:path]) {
        NSLog(@"File Exists %@",path);
    }
    
    error = nil;
    NSString *theLogFile = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    
    if (error) {
        NSLog(@"Unable to load %@\nerror=%@",path,[error userInfo]);
    }
    
	CSVParserReceiver *receiver = [[CSVParserReceiver alloc] init];
    
	CSVParser *parser = [[CSVParser alloc] initWithString:theLogFile separator:@"," hasHeader:YES
                                               fieldNames:nil]; //uses fieldnames from header.
    
	[parser parseRowsForReceiver:receiver selector:@selector(receiveRecord:)];
    NSArray *logArray = receiver.outputArray;
    //NSLog(@"%@",receiver.outputArray);
    
    path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Diabetes360LogFood.csv"];
    error = nil;
    if ([fileManager fileExistsAtPath:path]) {
        NSLog(@"File Exists %@",path);
    }

    error = nil;
    NSString *theFoodFile = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    
    if (error) {
        NSLog(@"Unable to load %@\nerror=%@",path,[error userInfo]);
    }
    
	receiver = [[CSVParserReceiver alloc] init];

	parser = [[CSVParser alloc] initWithString:theFoodFile separator:@"," hasHeader:YES
                                               fieldNames:nil]; //uses fieldnames from header.
    
	[parser parseRowsForReceiver:receiver selector:@selector(receiveRecord:)];
    NSArray *foodArray = receiver.outputArray;

    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObject:sortDesc];
    NSArray *temp = [[NSArray alloc] initWithArray:[logArray sortedArrayUsingDescriptors:sortDescArray]];
    logArray = temp;
    
    temp = [[NSArray alloc] initWithArray:[foodArray sortedArrayUsingDescriptors:sortDescArray]];
    foodArray = temp;
    
    int l = 0;
    int f = 0;
    int logsCount = [logArray count];
    int foodsCount = [foodArray count];
    NSMutableDictionary *thisLog = nil;
    NSMutableDictionary *thisFood = nil;
    NSDate *thisLogDate = nil;
    NSDate *thisFoodDate = nil;
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy-MM-dd HH:mm";

    do {
        thisLog  = [logArray objectAtIndex:l];
        thisFood = [foodArray objectAtIndex:f];
        thisLogDate = [thisLog valueForKey:@"date"];
        thisFoodDate = [thisFood valueForKey:@"date"];
        if ([thisLogDate isEqualToDate:thisFoodDate]) {
            NSLog(@"%@ = %@",[dateFmt stringFromDate:thisLogDate],[dateFmt stringFromDate:thisFoodDate]);
            f++;
        } else if ([[thisLogDate laterDate:thisFoodDate] isEqualToDate:thisFoodDate]) {
            NSLog(@"%@ < %@",[dateFmt stringFromDate:thisLogDate],[dateFmt stringFromDate:thisFoodDate]);
            l++;
        } else if ([[thisLogDate earlierDate:thisFoodDate] isEqualToDate:thisFoodDate]) {
            NSLog(@"%@ > %@",[dateFmt stringFromDate:thisLogDate],[dateFmt stringFromDate:thisFoodDate]);
            f++;
        }
    } while (l < logsCount && f < foodsCount);
    
//    path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Diabetes360LogFood.csv"];
//    [fileManager removeItemAtPath:path error:&error];
//    if (error) {
//        NSLog(@"Couldn't delete %@",path);
//    }
//    
//    path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Diabetes360LogFood.csv"];
//    [fileManager removeItemAtPath:path error:&error];
//    if (error) {
//        NSLog(@"Couldn't delete %@",path);
//    }

}

-(UIColor *) makeColorFromRGB:(NSDictionary *)theRGBColor {
    
    UIColor *uiColor = [UIColor colorWithRed:[[theRGBColor valueForKey:@"Red"] floatValue]/255.0f green:[[theRGBColor valueForKey:@"Green"] floatValue]/255.0f blue:[[theRGBColor valueForKey:@"Blue"] floatValue]/255.0f alpha:1.0f];
    //NSLog(@"%@",uiColor);
    return uiColor;
    
}

-(void) loadDefaultSchemes {
    
    //see note below after save
    //ColorSchemes from plist
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ColorSchemes" ofType:@"plist"];
    if (path) {
        
        NSDictionary *plistRoot = [[NSDictionary alloc] initWithContentsOfFile:path]; //root of plist
        NSArray *schemesFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"ColorSchemes"]];
        
        ColorScheme *schemeObj = nil;
        
        for (NSDictionary *scheme in schemesFromPlist) {
            schemeObj = (ColorScheme *)[NSEntityDescription insertNewObjectForEntityForName:@"ColorScheme" inManagedObjectContext:managedObjectContext];
            schemeObj.name           = [scheme valueForKey:@"name"];
            if ([schemeObj.name isEqualToString:@"Default"]) {
                self.colorScheme = schemeObj;
                self.colorScheme.viewBackground = [UIColor whiteColor];
                self.colorScheme.textNormal = [UIColor blackColor];
                self.colorScheme.textHightlight = [UIColor blueColor];
                self.colorScheme.buttonTitle = [UIColor blackColor];
                self.colorScheme.buttonBackground = [UIColor whiteColor];
                self.colorScheme.active = [NSNumber numberWithBool:YES];
            } else {
                schemeObj.viewBackground = [self makeColorFromRGB:[scheme valueForKey:@"viewBackground"]];
                schemeObj.textNormal = [self makeColorFromRGB:[scheme valueForKey:@"textNormal"]];
                schemeObj.buttonTitle = [self makeColorFromRGB:[scheme valueForKey:@"buttonTitle"]];
                schemeObj.buttonBackground = [self makeColorFromRGB:[scheme valueForKey:@"buttonBackground"]];
                schemeObj.textHightlight = [self makeColorFromRGB:[scheme valueForKey:@"textHighlight"]];
            }
        }
        
        
    } else {
        NSLog(@"Can't find ColorSchemes.plist");
        self.colorScheme = [NSEntityDescription insertNewObjectForEntityForName:@"ColorScheme" inManagedObjectContext:managedObjectContext];
        self.colorScheme.name = @"Default"; //must be exactly this with case for other parts of app
        self.colorScheme.viewBackground = [UIColor whiteColor];
        self.colorScheme.textNormal = [UIColor blackColor];
        self.colorScheme.textHightlight = [UIColor blueColor];
        self.colorScheme.tableCell = [UIColor whiteColor];
        self.colorScheme.tableCellAlternate = [UIColor whiteColor];
        self.colorScheme.buttonTitle = [UIColor blackColor];
        self.colorScheme.buttonBackground = [UIColor whiteColor];
    }

}

-(void) quickNPH {
    
    NSLog(@"NPH");
    self.quickSettings = [NSNumber numberWithInt:0];
    
    
}

-(void) quickMDI {

    NSLog(@"MDI");
    self.quickSettings = [NSNumber numberWithInt:1];
    
}

-(void) quickPump {

    NSLog(@"Pump");    
    self.quickSettings = [NSNumber numberWithInt:2];
    
}


-(void) sortScale {
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"rangeMin" ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObject:sortDesc];
    NSArray *temp = [[NSArray alloc] initWithArray:[self.insulinScaleArray sortedArrayUsingDescriptors:sortDescArray]];
    self.insulinScaleArray = [temp mutableCopy];
    
}

-(void) sortIOBFactor {
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"hours" ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObject:sortDesc];
    NSArray *temp = [[NSArray alloc] initWithArray:[self.IOBFactorArray sortedArrayUsingDescriptors:sortDescArray]];
    self.IOBFactorArray = [temp mutableCopy];
    
}

-(void) sortExerciseType {
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"typeName" ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObject:sortDesc];
    NSArray *temp = [[NSArray alloc] initWithArray:[self.exerciseTypeArray sortedArrayUsingDescriptors:sortDescArray]];
    self.exerciseTypeArray = [temp mutableCopy];
    
}

-(void) sortSchedule {
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObject:sortDesc];
    NSArray *temp = [[NSArray alloc] initWithArray:[self.dailyScheduleArray sortedArrayUsingDescriptors:sortDescArray]];
    self.dailyScheduleArray = [temp mutableCopy];
   
}

-(BOOL)saveSettings {
    
  //Settings
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    [request setSortDescriptors:nil];

    NSError *error = nil;
    NSMutableArray *settingsResult = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (error != nil) {
        [self databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ saveSettings fetch",self.class]];
    }	
    
    if (![settingsResult count]) { //no row in InsulinFormula table so add one before save.
        NSLog(@"empty fetch on Settings Save!!");
        Settings *newSettings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:managedObjectContext];
        [settingsResult addObject:newSettings];
    }
    
    Settings *settings = (Settings *)[settingsResult objectAtIndex:0];
    [[settingsResult objectAtIndex:0] setDatePickerInterval:self.datePickerInterval];
    [[settingsResult objectAtIndex:0] setGlucoseUnit:self.glucoseUnit];
    [[settingsResult objectAtIndex:0] setKetoneThreshold:self.ketoneThreshold];
    [[settingsResult objectAtIndex:0] setRoundingAccuracy:self.roundingAccuracy];
    [[settingsResult objectAtIndex:0] setPumpSiteInterval:self.pumpSiteInterval];
    [[settingsResult objectAtIndex:0] setPumpSiteTime:self.pumpSiteTime];
    [[settingsResult objectAtIndex:0] setPumpSiteAlert:self.pumpSiteAlert];
    [[settingsResult objectAtIndex:0] setQuickSettings:self.quickSettings];
    [[settingsResult objectAtIndex:0] setCalcType:self.calcType];
    [[settingsResult objectAtIndex:0] setRunInitialSetup:self.runInitialSetup];
    settings.useIOB = [NSNumber numberWithBool:self.useIOB];
    
 //save context
    
    error = nil;
	if (![managedObjectContext save:&error]) {
        [self databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ saveSettings save",self.class]];
		NSLog(@"%@",[error userInfo]);
	}

    [self sortSchedule];
    [self scheduleNotifications];
    
    return YES;
    
}

-(void)cancelNotificationsOfType:(NSString *)notifType {
    
    for (UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[notif.userInfo valueForKey:@"type"] isEqualToString:notifType] || ![notif.userInfo valueForKey:@"type"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notif];
//            NSLog(@"*** %@ type:%@ *** cancelled \n\n",notif.fireDate,[notif.userInfo valueForKey:@"type"]);
        }
    }
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

- (void)scheduleNotifications {

    [self cancelNotificationsOfType:DAILY_SCHED_TYPE];
    for (int i=0; i < [dailyScheduleArray count]; i++) {
        if ([[[dailyScheduleArray objectAtIndex:i] reminder] intValue]) {
            [self scheduleDailyNotification:[dailyScheduleArray objectAtIndex:i]];
        }
    }
    
    [self cancelNotificationsOfType:PUMP_SITE_TYPE];
    if ([pumpSiteAlert boolValue]) {
        [self schedulePumpSiteNotifications];
    }
    
}

- (void)scheduleDailyNotification:(DailySchedule *)schedItem {
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    //extract hour and minute from begin time
    NSDateComponents *beginTimeComps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:schedItem.beginTime];
    //extract rest from today
    NSDateComponents *nowComps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    //merge into beginTimeComps
    [beginTimeComps setYear:[nowComps year]];
    [beginTimeComps setMonth:[nowComps month]];
    [beginTimeComps setDay:[nowComps day]];
    
    NSDate *fireDate = [calendar dateFromComponents:beginTimeComps];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = fireDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.repeatInterval = (NSCalendarUnit)NSDayCalendarUnit;

    NSNumberFormatter *numFmt = [[NSNumberFormatter alloc] init];
    
    NSString *insulinString = [NSString stringWithFormat:@"Take %@ units of %@\n",[self formatToRoundedString:schedItem.insulinDose accuracy:nil],schedItem.InsulinBrand.brandName];
    NSString *carbString    = [NSString stringWithFormat:@"Eat %@g of %@Carbohydrate\n",[numFmt stringFromNumber:schedItem.carbToIngest],([schedItem.complexCarb boolValue] ? @"Complex " : @"")];
    
    NSString *alertBody = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@%@",schedItem.name,([schedItem.insulinDose intValue] ? insulinString : @""),([schedItem.carbToIngest intValue] ? carbString : @"")]];
    localNotif.alertBody = alertBody;
    localNotif.alertAction = @"View Details";
    localNotif.hasAction = YES;
    localNotif.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:DAILY_SCHED_TYPE,@"type",schedItem.name,@"schedName", nil];
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    
}

-(void)schedulePumpSiteNotifications {
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *addComps = [[NSDateComponents alloc] init];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = @"Pump Site Change";
    localNotif.alertAction = @"View Details";
    localNotif.hasAction = YES;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:PUMP_SITE_TYPE,@"type", nil];

    
    int add = [self.pumpSiteInterval intValue];
    for (int i=1; i <= 15; i++) {
        [addComps setDay:(add*i)];
        localNotif.fireDate = [calendar dateByAddingComponents:addComps toDate:self.pumpSiteTime options:0];
        if ([localNotif.fireDate earlierDate:[NSDate date]] != localNotif.fireDate) 
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
    
}

-(void)scheduleInsulinNotification:(InsulinBrand *)insulinBrand fromDate:(NSDate *)fromDate {
    
    if (![[insulinBrand.classification substringFromIndex:1] isEqualToString:LONG_INSULIN]) {
        return;
    }
    
    [self cancelNotificationsOfType:insulinBrand.brandName];

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *addComps = [[NSDateComponents alloc] init];
    [addComps setHour:[insulinBrand.doseInterval intValue]];
    
    NSDate *fireDate = [calendar dateByAddingComponents:addComps toDate:fromDate options:0];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    localNotif.fireDate = fireDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.repeatInterval = 0;
    
    localNotif.alertBody = [NSString stringWithFormat:@"%@ hours\nfrom last dose of %@. \nTime For More %@",insulinBrand.doseInterval,insulinBrand.brandName, insulinBrand.brandName];
    localNotif.alertAction = @"Log";
    localNotif.hasAction = YES;
    localNotif.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:insulinBrand.brandName, @"type", nil];
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];

    
}

-(BOOL) addSchedule:(DailySchedule *)newSched {
   
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:newSched.beginTime];
    [comps setYear:2000];
    [comps setMonth:1];
    [comps setDay:1];
    newSched.beginTime = [calendar dateFromComponents:comps];

    comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:newSched.endTime];
    [comps setYear:2000];
    [comps setMonth:1];
    [comps setDay:1];
    newSched.endTime = [calendar dateFromComponents:comps];
    
    [self.dailyScheduleArray addObject:newSched];
    
    return YES;
}

-(BOOL) deleteSchedule:(NSUInteger)row {
    
    [managedObjectContext deleteObject:[self.dailyScheduleArray objectAtIndex:row]];
    [self.dailyScheduleArray removeObjectAtIndex:row];
    [self scheduleNotifications];
    return YES;
}

-(NSDate *)defaultPumpSiteTime {
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];

    NSDateComponents *nowComps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];  //today's date

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:[nowComps year]];
    [comps setMonth:[nowComps month]];
    [comps setDay:[nowComps day]];
    [comps setHour:9];
    [comps setMinute:00];
    [comps setSecond:0];

    NSDate *aDate =  [calendar dateFromComponents:comps];
    
    
    return aDate;

}

-(NSString *)glucoseLiteral {
    
    if ([self.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
        return @"mmol/L";
    } else {
        return @"mg/dL";
    }
    
}

-(NSNumber *)glucoseConvert:(NSNumber *)theValue toExternal:(BOOL)toExternal {
    
    
    //all glucose values are stored as mg/dL in database.  External means as displayed, internal is database
    float theValuef = [theValue floatValue];
    
    short scale = 0;
    if ([self.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
        scale = 1;
        if (toExternal) {
            theValuef *= mmol2mgdl;
        } else {
            theValuef /= mmol2mgdl;
        }
    }

    NSDecimalNumberHandler *roundingBehavior = 
    [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

    NSDecimalNumber *valueToRound = [[NSDecimalNumber alloc] initWithFloat:theValuef];
    
    NSDecimalNumber *roundedValue = [valueToRound decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    
    return roundedValue;
}

-(NSNumber *)roundTheNumber:(NSNumber *)theValue accuracy:(NSNumber *)accuracy {
    
    float theValuef = [theValue floatValue];
    
    // in spreadsheet lingo: ROUND(rawUnits / acc,0) * acc
    NSDecimalNumberHandler *roundingBehavior = 
    [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
	
    float acc = 0;
    
    if (accuracy) {
        acc = [accuracy floatValue];
    } else {
        acc = [self.roundingAccuracy floatValue];
    }
    
    NSDecimalNumber *valueToRound = [[NSDecimalNumber alloc] initWithFloat:(theValuef / acc)];
    
    NSDecimalNumber *roundUnits = [valueToRound decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    NSNumber *roundedNumber = [NSNumber numberWithFloat:([roundUnits floatValue] * acc)] ;
    return roundedNumber;
}

-(NSString *) formatToRoundedString:(NSNumber *)theValue accuracy:(NSNumber *)accuracy {
    // rounds  returns formatted string.  Use accuracy to override settings roundingAccuracy, nil uses settings.roundingAccuracy

    NSNumberFormatter *numFmt = [[NSNumberFormatter alloc] init];

    float acc = 0;
    
    if (accuracy) {
        acc = [accuracy floatValue];
    } else {
        acc = [self.roundingAccuracy floatValue];
    }

    if        (acc < 0.009) {
        [numFmt setPositiveFormat:@"0.000"];
    } else if (acc < 0.09) {
        [numFmt setPositiveFormat:@"0.00"];
    } else if (acc < 0.9) {
        [numFmt setPositiveFormat:@"0.0"];
    } else if (acc < 9) {
        [numFmt setPositiveFormat:@"0"];
    }

    NSNumber *roundedNumber = [self roundTheNumber:theValue accuracy:accuracy];
    NSString *rval = [numFmt stringFromNumber:roundedNumber];
       
	return rval;

}

-(void)setView:(id)view toColorScheme:(ColorScheme *)theColorScheme {
    
    return;
    //NSLog(@"%@",view);
    if (!theColorScheme) {
        theColorScheme = self.colorScheme;
    }

    if ([view isMemberOfClass:[UIView class]]) {
        [view setBackgroundColor:theColorScheme.viewBackground];
        
    } else if ([view isMemberOfClass:[UITableViewCell class]]) {
        //[[view contentView] setBackgroundColor:theColorScheme.tableCell];
        [view setBackgroundColor:theColorScheme.viewBackground];
        //NSLog(@"%@",[view superview]);
        
    } else if ([view isMemberOfClass:[UILabel class]]) {
        [view setTextColor:theColorScheme.textNormal];
        [view setBackgroundColor:theColorScheme.viewBackground];
        
    } else if ([view isMemberOfClass:[UIButton class]]) {
        if (![[view superview] isMemberOfClass:[UITableViewCell class]]) {  
            [view setTitleColor:theColorScheme.buttonTitle forState:UIControlStateNormal];
            [[view layer] setBackgroundColor:[theColorScheme.buttonBackground CGColor]];
            [[view layer] setCornerRadius:9.0f];
            [[view layer] setMasksToBounds:YES];
            [[view layer] setBorderWidth:1.0f];
        }
        
    } else if ([view isMemberOfClass:[UILabel class]]) {
        [view setTextColor:theColorScheme.textNormal];
        
    } else if ([view isMemberOfClass:[UITextField class]]) {
        [view setBackgroundColor:theColorScheme.viewBackground];
        [view setTextColor:theColorScheme.textHightlight];
    }
    
    if ([[view subviews] count]) {
        for (id subView in [view subviews]) {
            [self setView:subView toColorScheme:nil];  //recursive call for subviews
        }
    }
    
}

-(InsulinBrand *)brandExists:(NSString *)theBrandName in:(NSArray *)existingInsulin {
    
    if (!existingInsulin) return nil;
    
    for (InsulinBrand *existingBrand in existingInsulin) {
        if ([existingBrand.brandName isEqualToString:theBrandName]) {
            return existingBrand;
        }
    }
    
    return nil;
    
}

-(void)showBuyFullVersion:(UIViewController *)theVC {
    
    BuyItVC *buyItVC = [[BuyItVC alloc] initWithNibName:@"BuyItVC" bundle:nil];
    [theVC presentModalViewController:buyItVC animated:YES];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time To Check Out\nThe Full Version of\nDiabetes 360" 
//                                                    message:nil 
//                                                   delegate:nil 
//                                          cancelButtonTitle:@"OK" 
//                                          otherButtonTitles: nil];
//    [alert show];	
    
}

-(int)refreshLogCount {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    [request setSortDescriptors:nil];
    
    NSError *error = nil;
    self.logCount = [[self.managedObjectContext executeFetchRequest:request error:&error] count];
    
    return self.logCount;
    
}

-(void)loadStaticTablesFromPlists {
/*
 this is used during inital migration of v1.02 from v1.00.  See persistentStoreCoordinator getter in appDelegate for migration logic.
 */

    return;  //v1.02 is earliest version ever on app store.  These tables are included in that release.
    
    //Insulin Brands from plist.  This entity exists in v1.00 and has the prescribed attribute set by the user.  existingBrand logic adds new insulinBrands and preserves values in rows that exist except for classification.  Classification is changing for Orals in that they are being broken up by chemical class as in medical texts.
    NSLog(@"Loading Static Tables - SettingsClass");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InsulinBrand" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"classification" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"brandName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor1, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *existingInsulin = nil;
    existingInsulin = [self.managedObjectContext executeFetchRequest:request error:&error];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"InsulinBrands" ofType:@"plist"];
    NSMutableDictionary *plistRoot = [[NSMutableDictionary alloc] initWithContentsOfFile:path]; //root of plist
    NSArray *insulinFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"InsulinBrands"]];
    NSLog(@"%@",insulinFromPlist);
    
    InsulinBrand *insulinBrandObj = nil;
    InsulinBrand *existingBrand = nil;
    
    for (NSDictionary *iBrand in insulinFromPlist) {
        existingBrand = [self brandExists:[iBrand valueForKey:@"brandName"] in:existingInsulin];
        if (existingBrand) {
            existingBrand.classification = [iBrand valueForKey:@"classification"];
        } else {
            insulinBrandObj = (InsulinBrand *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinBrand" inManagedObjectContext:self.managedObjectContext];
            insulinBrandObj.brandName = [iBrand valueForKey:@"brandName"];
            insulinBrandObj.classification = [iBrand valueForKey:@"classification"];
            insulinBrandObj.prescribed = [NSNumber numberWithBool:NO];
            insulinBrandObj.doseInterval = [iBrand valueForKey:@"doseInterval"];
        }
    }
    
    //Insulin On Board from plist
    NSNumberFormatter *numFmt = [[NSNumberFormatter alloc] init];
    path = [[NSBundle mainBundle] pathForResource:@"IOBFactors" ofType:@"plist"];

    plistRoot = [plistRoot initWithContentsOfFile:path]; //root of plist
    NSArray *iobFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"IOBFactors"]];
    NSLog(@"IOBFactors=%@",iobFromPlist);
    
    IOBFactor *IOBObj = nil;
    int i=0;
    for (NSDictionary *iob in iobFromPlist) {
        IOBObj = (IOBFactor *)[NSEntityDescription insertNewObjectForEntityForName:@"IOBFactor" inManagedObjectContext:self.managedObjectContext];
        IOBObj.hours           = [numFmt numberFromString:[iob valueForKey:@"hours"]];
        IOBObj.percentReduce   = [numFmt numberFromString:[iob valueForKey:@"percentReduce"]];
        i++;
    }
    
    //Exercise Types from plist
    path = [[NSBundle mainBundle] pathForResource:@"ExerciseTypes" ofType:@"plist"];
    plistRoot = [plistRoot initWithContentsOfFile:path]; //root of plist
    NSArray *ExTypeFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"ExerciseTypes"]];
    
    ExerciseType *ExTypeObj = nil;
    
    i=0;
    for (NSDictionary *ExType in ExTypeFromPlist) {
        ExTypeObj = (ExerciseType *)[NSEntityDescription insertNewObjectForEntityForName:@"ExerciseType" inManagedObjectContext:self.managedObjectContext];
        ExTypeObj.typeName      = [ExType valueForKey:@"exerciseType"];
        ExTypeObj.factorValue   = [numFmt numberFromString:[ExType valueForKey:@"factorValue"]];
        i++;
    }
    
    error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ loadStaticTablesFromPlists",self.class]];
	}
    
}

@end
