//
//  UpcomingReminderViewController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UpcomingReminderViewController.h"
#import "UpcomingPumpSiteViewController.h"
#import "DataService.h"

@interface UpcomingReminderViewController()

@property (nonatomic) BOOL schedReminders;

@end

@implementation UpcomingReminderViewController

@synthesize reminders;
@synthesize dateFmt;
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

    self.reminders = [[NSMutableArray alloc] init];
    
    NSArray *temp = [[[UIApplication sharedApplication] scheduledLocalNotifications] mutableCopy];
    
    BOOL addPumpSite = NO;
    for (UILocalNotification *notif in temp) {
        if ([[notif.userInfo valueForKey:@"type"] isEqualToString:PUMP_SITE_TYPE]) {
            addPumpSite = YES;
        } else {
            [self.reminders addObject:notif];
        }
    }
    self.schedReminders = NO;
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"fireDate" ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObject:sortDesc];
    
    temp = [self.reminders sortedArrayUsingDescriptors:sortDescArray];
    self.reminders = [temp mutableCopy];
    
    if (addPumpSite) {
        [self.reminders insertObject: @"Pump Site Change..." atIndex:0];
    }
    
    self.dateFmt = [[NSDateFormatter alloc] init];
    self.title = @"Upcoming Reminders";
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style: UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil];
    
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
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 25)];
    if (self.schedReminders) {
        label.text = @"** Repeats Daily";
    } else {
        label.text = @"";
    }
    label.textAlignment = NSTextAlignmentRight;
    if ([self.reminders count] == 0) {
        label.text = @"No Upcoming Reminders";
        label.textAlignment = NSTextAlignmentCenter;
    }
    label.textColor = [UIColor colorWithWhite:0.3f alpha:1];
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.backgroundColor = settings.kTblBgColor;
    [view addSubview:label];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [reminders count];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[reminders objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        return NO;
    } else {
        NSString *theType = [[[reminders objectAtIndex:indexPath.row] userInfo] valueForKey:@"type"];
        if ([theType isEqualToString:DAILY_SCHED_TYPE] || [theType isEqualToString:PUMP_SITE_TYPE]) {
            return NO;
        } else {  // this will be a long-acting insulin reminder.  This type of reminder can be deleted.
            return YES;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    [dateFmt setDateStyle:NSDateFormatterNoStyle];
    [dateFmt setTimeStyle:NSDateFormatterShortStyle];
    
    if ([[self.reminders objectAtIndex:indexPath.row] isKindOfClass:[UILocalNotification class]]) {
        
        UILocalNotification *notif = [reminders objectAtIndex:indexPath.row];
        
        if (notif.repeatInterval) {
            cell.detailTextLabel.text = @"** ";
            cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:[dateFmt stringFromDate:notif.fireDate]];
        } else {
            cell.detailTextLabel.text = [dateFmt stringFromDate:[[reminders objectAtIndex:indexPath.row] fireDate]];
        }
        
        if ([[notif.userInfo valueForKey:@"type"] isEqualToString:DAILY_SCHED_TYPE]) {
            cell.textLabel.text = [notif.userInfo valueForKey:@"schedName"];
            self.schedReminders = YES;
        } else {
            cell.textLabel.text = [notif.userInfo valueForKey:@"type"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    } else {
    
        cell.textLabel.text = [self.reminders objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    }

    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
  
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 && [[reminders objectAtIndex:0] isKindOfClass:[NSString class]]) {
        UpcomingPumpSiteViewController *controller = [[UpcomingPumpSiteViewController alloc] initWithNibName:@"UpcomingPumpSiteViewController" bundle:nil];
        controller.settings = self.settings;
        [self.navigationController pushViewController:controller animated:YES];
        
    }

}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [[UIApplication sharedApplication] cancelLocalNotification:[reminders objectAtIndex:indexPath.row]];
    [reminders removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
}


@end
