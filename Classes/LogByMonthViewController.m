//
//  LogByMonthViewController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LogByMonthViewController.h"
#import "LogByDayViewController.h"
#import "Event.h"
#import "PeriodStatistics.h"

#define GLUCOSE_LO_TAG      90
#define GLUCOSE_HI_TAG      91
#define GLUCOSE_AVG_TAG     92
#define GLUCOSE_IMG_TAG     93
#define CARB_AVG_TAG        94
#define CARB_IMG_TAG        95
#define CARB_LO_TAG         96
#define CARB_HI_TAG         97

@interface LogByMonthViewController ()
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)reloadDataSource;
@end

@implementation LogByMonthViewController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize monthsArray;
@synthesize settings;
@synthesize logCell;
@synthesize baseLine;
@synthesize viewForSelectedCell;
@synthesize recalcSections;

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
    
    dateFmt = [[NSDateFormatter alloc] init];
    numFmt = [[NSNumberFormatter alloc] init];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.tableView.backgroundColor = settings.kTblBgColor;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                              style: UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];
    sectionStats = [[NSMutableArray alloc] init];
    recalcSections = NO;
    
    self.tableView.backgroundView = settings.tableViewBgView;
    
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
    self.title = @"Monthly Summary";

    if (recalcSections) {
        [self reloadDataSource];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (![[self.fetchedResultsController sections] count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Tap Add Button Above\nTo Add Log Entry"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
    }
    
}

-(void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    fetchedResultsController_ = nil;
    
}

#pragma mark Add Event

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)addEvent:(id)sender {
    
#ifdef LOG_MAX_FOR_LITE
    
    if ([settings refreshLogCount] >= LOG_MAX_FOR_LITE) {
        [settings showBuyFullVersion:self];
        return;
    }
    
#endif    
    
    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    
    EventDetailTblController *addController = [[EventDetailTblController alloc] initWithNibName:@"EventDetailTblController" bundle:nil];
    
    newEvent.totalCarb = NULL;
    addController.event = newEvent;
    addController.managedObjectContext = self.managedObjectContext;
    addController.settings = self.settings;
    addController.delegate = self;
    
    // Create the nav controller and add the view controllers.
    UINavigationController *theNavController = [[UINavigationController alloc]
                                                initWithRootViewController:addController];
    
    theNavController.navigationBar.tintColor = settings.kNavBarColor;
    
    [self presentModalViewController:theNavController animated:YES];
    
}

- (void)dismissAddEvent {
    
    recalcSections = YES;
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - Table view data source

- (NSDictionary *) calcStatsForSection:(NSUInteger)section {
    
    PeriodStatistics *stats = [[PeriodStatistics alloc] init];
    NSMutableArray *theMonth = [[[[self.fetchedResultsController sections] objectAtIndex:section] objects] mutableCopy];
    [stats getHiLoAvgUsing:theMonth];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:section], @"section", stats, @"sectionStat", nil];
    return dict;
    
}

-(void) reloadDataSource {
    
    [sectionStats removeAllObjects];
    
    for (int i=0 ; i < [[self.fetchedResultsController sections] count] ; i++) {
        [sectionStats addObject:[self calcStatsForSection:i]];
    }
    
    [self.tableView reloadData];
    self.recalcSections = NO;
 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section { 
    
    int i=0;
    for (NSDictionary *stat in sectionStats) {
        if ([[stat valueForKey:@"section"] intValue] == section) {
            break;
        }
        i++;
    }
    
    if (i == [sectionStats count]) { //didn't find entry for this section so create one
        [sectionStats addObject:[self calcStatsForSection:section]];
    }

    [dateFmt setDateFormat:@"yyyy-MM-dd"];
    NSString *x = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    x = [x stringByAppendingString:@"-01"];
    NSDate *y = [dateFmt dateFromString:x]; 
    [dateFmt setDateFormat:@"MMMM, y"];
    return [dateFmt stringFromDate:y];
    
}

- (PeriodStatistics *) statsForSection:(NSUInteger)section {
    
    for (NSDictionary *dict in sectionStats) {
        if ([[dict valueForKey:@"section"] intValue] == section) {
            return [dict valueForKey:@"sectionStat"];
        }
    }
    
    return nil;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 111.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LogByMonthCell" owner:self options:nil];
        cell = logCell;
        self.logCell = nil;
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Loads a cell
    PeriodStatistics *stats = nil;
    for (PeriodStatistics *stat in sectionStats) {
        if ([[stat valueForKey:@"section"] intValue] == indexPath.section) {
            stats = [stat valueForKey:@"sectionStat"];
        }
    }
    
    if (stats == nil) {
        cell = nil;
        return;
    }
    
    
    UILabel *cellLabel = nil;
    UIImageView *imageView = nil;
    
    cellLabel = (UILabel *)[cell viewWithTag:GLUCOSE_LO_TAG];
    cellLabel.text = [settings formatToRoundedString:[settings glucoseConvert:[NSNumber numberWithFloat:stats.LoGlucose] toExternal:YES] accuracy:[NSNumber numberWithFloat:1.0f]];
    
    cellLabel = (UILabel *)[cell viewWithTag:GLUCOSE_HI_TAG];
    cellLabel.text = [settings formatToRoundedString:[settings glucoseConvert:[NSNumber numberWithFloat:stats.HiGlucose] toExternal:YES] accuracy:[NSNumber numberWithFloat:1.0f]];
    
    cellLabel = (UILabel *)[cell viewWithTag:GLUCOSE_AVG_TAG];
    cellLabel.text = [settings formatToRoundedString:[settings glucoseConvert:[NSNumber numberWithFloat:stats.AvgGlucose] toExternal:YES] accuracy:[NSNumber numberWithFloat:1.0f]];
    
    cellLabel = (UILabel *)[cell viewWithTag:CARB_AVG_TAG];
    cellLabel.text = [numFmt stringFromNumber:[NSNumber numberWithInt:stats.AvgCarb]];
    
    cellLabel = (UILabel *)[cell viewWithTag:CARB_LO_TAG];
    if (stats.LoCarb == NSIntegerMax) {
        cellLabel.text = @"";
    } else {
        cellLabel.text = [numFmt stringFromNumber:[NSNumber numberWithInt:stats.LoCarb]];
    }
    
    cellLabel = (UILabel *)[cell viewWithTag:CARB_HI_TAG];
    cellLabel.text = [numFmt stringFromNumber:[NSNumber numberWithInt:stats.HiCarb]];
    

    float kBase = baseLine.frame.origin.x; // origin of Bg line in xib
    float kSize = baseLine.frame.size.width;
    CGRect frame; 
    
    imageView = (UIImageView *)[cell viewWithTag:CARB_IMG_TAG];
    frame = imageView.frame;
    if (stats.HiCarb > 0) {
        frame.origin.x = kBase + (stats.AvgCarb / stats.HiCarb * kSize) - (imageView.frame.size.width / 2);
        if (frame.origin.x < kBase) {
            frame.origin.x = kBase;   
        }
    } else {
        frame.origin.x = kBase;
    }
    imageView.frame = frame;
    
    imageView = (UIImageView *)[cell viewWithTag:GLUCOSE_IMG_TAG];
    frame = imageView.frame;
    if (stats.HiGlucose > 0) {
        frame.origin.x = kBase + (stats.AvgGlucose / stats.HiGlucose * kSize) - (imageView.frame.size.width / 2);
        if (frame.origin.x < kBase) frame.origin.x = kBase;
    } else {
        frame.origin.x = kBase;
    }
    imageView.frame = frame;
    
    cell.selectedBackgroundView = viewForSelectedCell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LogByDayViewController *logController = [[LogByDayViewController alloc] initWithNibName:@"LogByDayViewController" bundle:nil];
    logController.managedObjectContext = self.managedObjectContext;
    logController.settings = self.settings;
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDate *theDate = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"eventDate"];
    
    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:theDate];
    
    logController.detailMonth = [calendar dateFromComponents:comps]; 
    [self.navigationController pushViewController:logController animated:YES];
//    self.title = @"Home";
    

}
#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    [NSFetchedResultsController deleteCacheWithName:@"LogMonth"];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:@"fmtMonth" 
                                                                                                           cacheName:@"LogMonth"];
    aFetchedResultsController.delegate = nil; //controller doesn't alter itself.
    self.fetchedResultsController = aFetchedResultsController;
    
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ fetchedResultsController",self.class]];
    }
    
    return fetchedResultsController_;
}    



@end