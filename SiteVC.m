//
//  SiteVC.m
//  Diabetes
//
//  Created by Joe DiMaggio on 8/5/12.
//
//

#import "SiteVC.h"
#import "DataService.h"
#import "Site.h"

@interface SiteVC ()

@property (nonatomic,strong) NSArray *siteDataSource;

@end

@implementation SiteVC
@synthesize siteDataSource;
@synthesize settings;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Site"];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    self.siteDataSource = [self.settings.managedObjectContext executeFetchRequest:request error:nil] ;

    self.title = @"Manage Sites";
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.tableView.backgroundView = settings.tableViewBgView;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.siteDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[self.siteDataSource objectAtIndex:indexPath.row] valueForKey:@"name"];

    Site *theSite = [self.siteDataSource objectAtIndex:indexPath.row];
    BOOL isActive = [theSite.active boolValue];
    if (isActive) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Site *theSite = [self.siteDataSource objectAtIndex:indexPath.row];
    BOOL isActive = ! [theSite.active boolValue];
    
    theSite.active = [NSNumber numberWithBool:isActive];

    BOOL found = NO;
    for (Site *site in self.siteDataSource) {
        if ([site.active boolValue] == YES) {
            found = YES;
            break;
        }
    }
    
    if (found == NO) {
        isActive = YES;
        theSite.active = [NSNumber numberWithBool:isActive];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Must have at least one\nactive site" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (isActive) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [self.settings.managedObjectContext  save:nil];

}

@end
