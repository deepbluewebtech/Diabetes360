//
//  DailyScheduleController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DailyScheduleController.h"
#import "DailySchedDtlController.h"

@interface DailyScheduleController()

@property (nonatomic) BOOL schedReminders;
@end

@implementation DailyScheduleController

@synthesize settings;


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dateFmt = [[NSDateFormatter alloc] init];
    [dateFmt setDateStyle:NSDateFormatterNoStyle];
    [dateFmt setTimeStyle:NSDateFormatterShortStyle];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSchedItem:)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style: UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil];

    self.tableView.backgroundView = settings.tableViewBgView;
    
    self.schedReminders = NO;
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
    
    self.title = @"Daily Schedule";
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [settings.dailyScheduleArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[settings setView:self.tableView toColorScheme:nil];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 25)];
    if (self.schedReminders) {
        label.text = @"* Reminder Set";
    } else {
        label.text = @"";
    }
    label.textAlignment = UITextAlignmentRight;
    label.textColor = [UIColor colorWithWhite:0.3f alpha:1];
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.backgroundColor = settings.kTblBgColor;
    [view addSubview:label];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    NSString *rmdr;
    
    if ([[[settings.dailyScheduleArray objectAtIndex:indexPath.row] reminder] boolValue] == YES) {
        rmdr = @"*";
        self.schedReminders = YES;
    } else {
        rmdr = @" ";
    }
    
    NSString *rmdrTime;
    if ([[[settings.dailyScheduleArray objectAtIndex:indexPath.row] anyTime] boolValue] == YES) {
        rmdrTime = [rmdr stringByAppendingString:@"AnyTime"];
    } else {
        DailySchedule *schedule = (DailySchedule *)[settings.dailyScheduleArray objectAtIndex:indexPath.row];
        rmdrTime = [rmdr stringByAppendingString:[dateFmt stringFromDate:schedule.beginTime]];
    }
        
    
    cell.detailTextLabel.text = rmdrTime;
    cell.textLabel.text = [[settings.dailyScheduleArray objectAtIndex:indexPath.row] name];

    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [settings deleteSchedule:indexPath.row];
        [self.tableView reloadData];
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     DailySchedDtlController *controller = [[DailySchedDtlController alloc] initWithNibName:@"DailySchedDtlController" bundle:nil];
     controller.schedule = [settings.dailyScheduleArray objectAtIndex:indexPath.row];
     controller.settings = settings;
     
     [self.navigationController pushViewController:controller animated:YES];
}

-(void)addSchedItem:(id)sender{
    
    NSLog(@"addScheduleItem:%@",sender);
    DailySchedule *newSched = [NSEntityDescription insertNewObjectForEntityForName:@"DailySchedule" inManagedObjectContext:settings.managedObjectContext];
    DailySchedDtlController *controller = [[DailySchedDtlController alloc] initWithNibName:@"DailySchedDtlController" bundle:nil];
    controller.schedule = newSched;
    controller.schedule.name = nil;
    controller.settings = settings;
    controller.delegate = self;
    UINavigationController *theNavController = [[UINavigationController alloc]
                                                initWithRootViewController:controller];

    theNavController.navigationBar.tintColor = settings.kNavBarColor;

    [self presentModalViewController:theNavController animated:YES];
        
}

-(void)dismissAddSchedItem {
    
    [self dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
    
}

@end
