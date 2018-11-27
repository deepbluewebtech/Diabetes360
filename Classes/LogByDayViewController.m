//
//  RootViewController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 12/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "LogByDayViewController.h"
#import "LogByMonthViewController.h"
#import "Event.h"
#import "EventFood.h"
#import "FoodItem.h"
#import "InsulinBrand.h"
#import "PeriodStatistics.h"

@interface LogByDayViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation LogByDayViewController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize settings;
@synthesize logCell;
@synthesize baseLine;

@synthesize detailMonth;

@synthesize viewForSelectedCell;

#define TIME_TAG            92
#define GLUCOSE_TAG         93
#define CARB_TAG            94
#define GLUCOSE_AVG_TAG     95
#define CARB_AVG_TAG        96
#define GLUCOSE_THIS_TAG    97
#define CARB_THIS_TAG       98

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.navigationItem.title = @"Injection Log";

    // Set up the edit and add buttons.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
    self.navigationItem.rightBarButtonItem = addButton;
	
    dateFmt = [[NSDateFormatter alloc] init];
    numFmt  = [[NSNumberFormatter alloc] init];
    
    self.tableView.rowHeight = 50;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                              style: UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];

    stats = [[PeriodStatistics alloc] init];

    self.tableView.backgroundView = settings.tableViewBgView;

}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [dateFmt setDateFormat:@"MMMM, y"];
    self.title = [dateFmt stringFromDate:detailMonth];
    
    [stats getHiLoAvgUsing:[[self.fetchedResultsController fetchedObjects] mutableCopy]]; //change parameter type to NSArray if this effort to work straight off FRC works
    
}

-(void) viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    fetchedResultsController_ = nil; //FRC's walk in each other and deallocate from under us without this

}

- (void)addEvent:(id)sender {

#ifdef LOG_MAX_FOR_LITE
    
    if ([settings refreshLogCount] >= LOG_MAX_FOR_LITE) {
        [settings showBuyFullVersion:self];
        return;
    }
    
#endif
    
    EventDetailTblController *addController = [[EventDetailTblController alloc] initWithNibName:@"EventDetailTblController" bundle:nil];

    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
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

-(void)setRecalcMonthSections {

    NSArray *navStack = self.navigationController.viewControllers;
    for (int i=0 ; i < [navStack count] ; i++) {
        if ([[[[navStack objectAtIndex:i] class] description] isEqualToString:@"LogByMonthViewController"]) {
            [(LogByMonthViewController *)[navStack objectAtIndex:i] setRecalcSections:YES];
            break;
        }
    }
}

- (void)dismissAddEvent {
    
    [self setRecalcMonthSections];
    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [[self.fetchedResultsController sections] count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    //Comes in as a sortable date in event.fmtDate, leaves as a nice Month dd, yyyy for display
	[dateFmt setDateFormat:@"yyyy-MM-dd"];
    NSString *x = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    NSDate *y = [dateFmt dateFromString:x]; 
    
    [dateFmt setDateStyle:NSDateFormatterMediumStyle];
    [dateFmt setTimeStyle:NSDateFormatterNoStyle];
    
    return [dateFmt stringFromDate:y];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LogByDayCell" owner:self options:nil];
        cell = logCell;
        self.logCell = nil;
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Loads a cell
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *cellLabel = nil;
    UIImageView *imageView = nil;
    
    cellLabel = (UILabel *)[cell viewWithTag:TIME_TAG];
    [dateFmt setDateStyle:NSDateFormatterNoStyle];
    [dateFmt setTimeStyle:NSDateFormatterShortStyle];
    NSString *asterisk = @"";
    if ([[managedObject valueForKey:@"insulinAmtIsManual"] boolValue] == YES) {
        asterisk = @"**";
    } 
    
    cellLabel.text = [NSString stringWithFormat:@"%@%@",[dateFmt stringFromDate:[managedObject valueForKey:@"eventDate"]],asterisk];
    
    cellLabel = (UILabel *)[cell viewWithTag:GLUCOSE_TAG];
    cellLabel.text = [settings formatToRoundedString:[settings glucoseConvert:[managedObject valueForKey:@"glucose"] toExternal:YES] accuracy:[NSNumber numberWithFloat:1.0f]];
    
    float kBase = baseLine.frame.origin.x; // origin of Bg line in xib
    float kSize = baseLine.frame.size.width;
    CGRect frame; 
    
    cellLabel = (UILabel *)[cell viewWithTag:CARB_TAG];
    float thisCarb = [[managedObject valueForKey:@"totalCarb"] floatValue];
    cellLabel.text = [numFmt stringFromNumber:[managedObject valueForKey:@"totalCarb"]];

    imageView = (UIImageView *)[cell viewWithTag:CARB_THIS_TAG];
    frame = imageView.frame;
    if (stats.HiCarb > 0) {
        frame.origin.x = kBase + (thisCarb / stats.HiCarb * kSize) - (imageView.frame.size.width/2); 
        if (frame.origin.x < kBase) frame.origin.x = kBase;
    } else {
        frame.origin.x = kBase;
    }
    imageView.frame = frame;
    
    imageView = (UIImageView *)[cell viewWithTag:GLUCOSE_THIS_TAG];
    frame = imageView.frame;
    
    float thisGlucose = [[settings glucoseConvert:[managedObject valueForKey:@"glucose"] toExternal:YES] floatValue];
    if (stats.HiGlucose > 0) {
        frame.origin.x = kBase + (thisGlucose / stats.HiGlucose * kSize) - (imageView.frame.size.width / 2); 
        if (frame.origin.x < kBase) frame.origin.x = kBase;
    } else {
        frame.origin.x = kBase;
    }
    imageView.frame = frame;
    
    imageView = (UIImageView *)[cell viewWithTag:CARB_AVG_TAG];
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
    
    imageView = (UIImageView *)[cell viewWithTag:GLUCOSE_AVG_TAG];
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //be very careful here--remember the cocoa error - can't update a row that was never inserted fiasco!
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        //[context processPendingChanges]; //fixes "fulfill fault" crash after add and cancel.
        //[tableView reloadData]; // without this NSInternalInconsistency Exception raised after add and cancel.
        
        // Save the context.
        NSError *error = nil;
        
        if (![context save:&error]) {
            [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ commitEditingStyle",self.class]];
            return;
        }
        
        [self setRecalcMonthSections];
    }   
    
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    EventDetailTblController *detailController = [[EventDetailTblController alloc] initWithNibName:@"EventDetailTblController" bundle:nil];
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    detailController.event = (Event *)selectedObject;
    detailController.managedObjectContext = self.managedObjectContext;
    detailController.settings = self.settings;
    detailController.delegate = nil;

    [self.navigationController pushViewController:detailController animated:YES];

}

#pragma mark -
#pragma mark Fetched results controller

-(NSPredicate *) buildMonthPredicate:(NSDate *)theMonth {
    
#define SECONDS_PER_DAY 86400

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSTimeInterval interval;
    NSDate *start;

    NSDateComponents *comps = [[NSDateComponents alloc] init];

//    demonstration of the march bug...
//    for (int theYear=2010; theYear <= 2014; theYear++) {
//
//        for (int month = 1; month <= 12; month++) {
//            
//            comps.year   = theYear;
//            comps.month  = month;
//            comps.day    = 1;
//            comps.hour   = 0;
//            comps.minute = 0;
//            comps.second = 0;
//            [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&start interval:&interval forDate:[calendar dateFromComponents:comps]];
//            int days = interval / SECONDS_PER_DAY;
//            NSLog(@"%@ %@ %d",[calendar dateFromComponents:comps],start, days);
//            
//        }
//
//    }

    [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&start interval:&interval forDate:theMonth];

    //interval is returning 30 days for March for some reason, overriding as quick fix.
    NSDateComponents *whatMonthComps = [calendar components:(NSMonthCalendarUnit) fromDate:start];
    if ([whatMonthComps month] == 3) {
        [comps setDay:31];
    } else {
        [comps setDay:interval / SECONDS_PER_DAY];
    }
    
    NSDate *end = [calendar dateByAddingComponents:comps toDate:start options:0];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"eventDate >= %@ and eventDate <= %@",start,end];
    
    return pred;
    
}

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
    
    [fetchRequest setPredicate:[self buildMonthPredicate:detailMonth]];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = 
                [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                    managedObjectContext:self.managedObjectContext
                                                      sectionNameKeyPath:@"fmtDate" 
                                                               cacheName:nil]; // no cache if changing results
    aFetchedResultsController.delegate = self; // this controller does not alter itself.
    self.fetchedResultsController = aFetchedResultsController;
    
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ fetchedResultsController",self.class]];
    }
    
    return fetchedResultsController_;
}    

#pragma mark -
#pragma mark Fetched results controller delegate

//these are here for deletes only...
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

@end


