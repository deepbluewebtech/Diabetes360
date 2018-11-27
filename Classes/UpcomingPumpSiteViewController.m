//
//  UpcomingPumpSiteViewController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UpcomingPumpSiteViewController.h"
#import "DataService.h"

@implementation UpcomingPumpSiteViewController

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
    
    for (UILocalNotification *notif in temp) {
        if ([[notif.userInfo valueForKey:@"type"] isEqualToString:PUMP_SITE_TYPE]) {
            [self.reminders addObject:notif];
        }
    }
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"fireDate" ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObject:sortDesc];
    
    temp = [self.reminders sortedArrayUsingDescriptors:sortDescArray];
    self.reminders = [temp mutableCopy];
    
    self.tableView.backgroundView = settings.tableViewBgView;
    
    self.dateFmt = [[NSDateFormatter alloc] init];
    self.title = @"Upcoming Site Change";
    
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

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0f;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 80.0f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 280, 30)];
    [dateFmt setDateStyle:NSDateFormatterNoStyle];
    [dateFmt setTimeStyle:NSDateFormatterShortStyle];
    textView.text = [NSString stringWithFormat:@"Time Set for %@ on:",[dateFmt stringFromDate:[[self.reminders objectAtIndex:0] fireDate]]];
    
    textView.font = [UIFont fontWithName:@"Helvetica" size:15];
    textView.backgroundColor = settings.kTblBgColor;
    [view addSubview:textView];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 280, 80)];
    textView.text = @"These are automatically scheduled\nseveral weeks in the future.\nEdit Via Pump Site Change Settings";
    
    textView.textAlignment = UITextAlignmentCenter;
    textView.textColor = [UIColor colorWithWhite:0.3f alpha:1];
    textView.font = [UIFont fontWithName:@"Helvetica" size:15];
    textView.backgroundColor = settings.kTblBgColor;
    [view addSubview:textView];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [reminders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [dateFmt setDateStyle:NSDateFormatterMediumStyle];
    [dateFmt setTimeStyle:NSDateFormatterNoStyle];
    cell.textLabel.text = [dateFmt stringFromDate:[[reminders objectAtIndex:indexPath.row] fireDate]];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


@end
