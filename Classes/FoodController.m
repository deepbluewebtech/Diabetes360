//
//  FoodController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/8/11.
//  Copyright 2011 Deep Blue Web Technology. All rights reserved.
//

#import "FoodController.h"
#import "EventFoodController.h"
#import "FoodItem.h"
#import "EventFood.h"
#import "Event.h"
#import "DataService.h"


@interface FoodController ()
- (void)configureCell:(UITableView *)tableView cell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation FoodController

@synthesize event;
@synthesize settings;

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize foodArray;
@synthesize filteredFoodArray;
@synthesize activityIndicator;
@synthesize filterTimer;
@synthesize viewForSelectedCell;

const float kfontSize = 12;
const float kcellHeight = 18;

BOOL searchTextIsBlank = NO;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

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

    self.title = @"Select Foods";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                              style: UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Servings" style:UIBarButtonItemStylePlain target:self action:@selector(showServings)];
    self.navigationItem.rightBarButtonItem = buttonItem;

    NSMutableArray *mutableFetchResults = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    
    [self setFoodArray:mutableFetchResults];
    self.filteredFoodArray = [NSMutableArray arrayWithCapacity:[self.foodArray count]];
    
    [self.searchDisplayController setActive:NO];
    self.searchDisplayController.searchBar.showsScopeBar = NO;
    self.searchDisplayController.searchBar.tintColor = [UIColor colorWithRed:204/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f];
    
    //self.tableView.rowHeight = kcellHeight;
    
    if ([event.totalCarb floatValue] > 0  && [event.EventFoods count] == 0) {
        //[settings setManualCarb:[NSNumber numberWithBool:YES]];
        settings.manualCarb = YES;
    } else {
        //[settings setManualCarb:[NSNumber numberWithBool:NO]];
        settings.manualCarb = NO;
    }

    numFmt = [[NSNumberFormatter alloc] init];
    
}

- (void)viewDidUnload {

    [super viewDidUnload];

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
    
    if (settings.manualCarb == NO) {
        float t=0;
        float f;
        for (EventFood *eventFood in [event.EventFoods allObjects]) {
            f = [eventFood.foodCarb floatValue];
            t += f;
        }
        event.totalCarb = [NSNumber numberWithFloat:t];
    }

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
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        if ([self.filteredFoodArray count] == 0) {
            [self.filteredFoodArray addObject:@" "]; //supresses the "No Results" message as user types search string before hitting search button.
        }
        return [self.filteredFoodArray count];
    }
	else
	{
        return [self.foodArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    [self configureCell:tableView cell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    //[settings setView:self.tableView toColorScheme:nil];
    
}

- (void)configureCell:(UITableView *)tableView cell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
	// Loads a cell
    NSUInteger breakPos = 40;
    NSRange firstLine = NSMakeRange(0, breakPos);
	
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = YES;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([[self.filteredFoodArray objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
            cell.textLabel.text = @" ";  //this will be in first element if the table is empty when searching.  supresses "No Results" message as user types search string.
            cell.detailTextLabel.text = @"";
            cell.userInteractionEnabled = NO;
        } else {
            NSString *desc = [[self.filteredFoodArray objectAtIndex:indexPath.row] shortDesc];
            if (breakPos <= [desc length]) {
                NSRange breakAt = [desc rangeOfString:@"," options:(NSBackwardsSearch) range:firstLine];
                if (breakAt.location != NSNotFound) {
                    cell.textLabel.text = [desc substringToIndex:breakAt.location];
                    cell.detailTextLabel.text = [desc substringFromIndex:breakAt.location+1]; //lose the leading comma
                } else {
                    cell.textLabel.text = desc;
                    cell.detailTextLabel.text = @" ";
                }
            } else {
                cell.textLabel.text = desc;
                cell.detailTextLabel.text = @" ";
            }
            for (EventFood *eventFood in [[self.filteredFoodArray objectAtIndex:indexPath.row] EventFoods]) {
                if (eventFood.Event == self.event) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
        }
    } else	{
        NSString *desc = [[self.fetchedResultsController objectAtIndexPath:indexPath] shortDesc];
        if (breakPos <= [desc length]) {
            NSRange breakAt = [desc rangeOfString:@"," options:(NSBackwardsSearch) range:firstLine];
            if (breakAt.location != NSNotFound) {
                cell.textLabel.text = [desc substringToIndex:breakAt.location];
                cell.detailTextLabel.text = [desc substringFromIndex:breakAt.location+1]; //lose the comma
            } else {
                cell.textLabel.text = desc;
                cell.detailTextLabel.text = @" ";
            }
        } else {
            cell.textLabel.text = desc;
            cell.detailTextLabel.text = @" ";
        }
        for (EventFood *eventFood in [[self.fetchedResultsController objectAtIndexPath:indexPath] EventFoods]) {
            if (eventFood.Event == self.event) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }

    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:kfontSize];
    cell.detailTextLabel.font = cell.textLabel.font;
    cell.selectedBackgroundView = viewForSelectedCell;
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
	
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];

    NSManagedObject *selectedFoodItem = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        selectedFoodItem = (FoodItem *)[self.filteredFoodArray objectAtIndex:indexPath.row];
    } else {
        selectedFoodItem = (FoodItem *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    }

    int dup = 0;
    for (EventFood *eventFood in self.event.EventFoods) {
        if ([eventFood.FoodItem.ndbNumber isEqualToNumber:[selectedFoodItem valueForKey:@"ndbNumber"]]) {
            dup = 1;
        }
    }
    
    if (!dup) {
        //create new instance of EventFood and add to event set using core data accessor add__Object.
        int x = [[selectedFoodItem valueForKey:@"usedCount"] intValue];
        [selectedFoodItem setValue:[NSNumber numberWithInt:++x] forKey:@"usedCount"];
        [selectedFoodItem setValue:[NSDate date] forKey:@"lastUsed"];
        EventFood *newEventFood = [NSEntityDescription insertNewObjectForEntityForName:@"EventFood" inManagedObjectContext:managedObjectContext_];
        newEventFood.foodCarb = [(FoodItem *)selectedFoodItem carb];
        newEventFood.servingQty = [NSNumber numberWithInt:1];
        newEventFood.foodWeight = [NSNumber numberWithInt:100];
        newEventFood.foodMeasure = @"100g";
        newEventFood.FoodItem = (FoodItem *)selectedFoodItem;
        newEventFood.Event = self.event;
        [self.event addEventFoodsObject:newEventFood];
        theCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        for (EventFood *eventFood in [(FoodItem *)selectedFoodItem EventFoods]) {
            if (eventFood.Event == self.event) {
                [event removeEventFoodsObject:eventFood];
                int x = [eventFood.FoodItem.usedCount intValue];
                eventFood.FoodItem.usedCount = [NSNumber numberWithInt:--x];
            }
        }
        theCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    settings.manualCarb = NO;

}

#pragma mark -
#pragma mark Navigation

-(void) showServings {

    EventFoodController *efController = [[EventFoodController alloc] initWithNibName:@"EventFoodController" bundle:nil];
    efController.event = self.event;
    efController.settings = self.settings;
    efController.foodTableView = self.tableView;
    [self.navigationController pushViewController:efController animated:YES];
    return;
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FoodItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:100];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortDesc" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:self.managedObjectContext 
                                          sectionNameKeyPath:nil 
                                                   cacheName:nil];
    aFetchedResultsController.delegate = nil; //this controller does not edit results, only displays them
    self.fetchedResultsController = aFetchedResultsController;
    
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ fetchedResultsController",self.class]];
    }
    
    return fetchedResultsController_;
}    


#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Content Filtering

- (BOOL) searchWords:(NSString *)searchText arePresentIn:(NSString *)desc {

    NSArray *words = [searchText componentsSeparatedByString:@" "];
 
    for (NSString *word in words) {
        
        if ([desc rangeOfString:word
                        options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch) 
                          range:NSMakeRange(0, [desc length])].location == NSNotFound) {
            return NO;
        }

    }
    
    return YES;    

}

-(BOOL) isSearchTextBlank:(NSString *)text {
    
    NSCharacterSet *alphaChars = [NSCharacterSet alphanumericCharacterSet];
    
    for (int i=0; i < [text length] ; i++) {
        if ([alphaChars characterIsMember:[text characterAtIndex:i]] ) {
            return NO;
        }
    }
    
    return YES;
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope {
    
    [self.filteredFoodArray removeAllObjects];
	for (FoodItem *foodItem in foodArray) {
        if (scope == 0) {
            if (searchTextIsBlank) {
                [self.filteredFoodArray addObject:foodItem];
            } else if ([self searchWords:searchText arePresentIn:foodItem.shortDesc]){
                [self.filteredFoodArray addObject:foodItem];
            }
        } else {  // scope is most used (1)
            if ([foodItem.usedCount intValue] > 0) {
                if (searchTextIsBlank) {  // all that have been used
                    [self.filteredFoodArray addObject:foodItem];
                } else if ([self searchWords:searchText arePresentIn:foodItem.shortDesc]) {  // all that have been used and match search string
                    [self.filteredFoodArray addObject:foodItem];
                }
            }
        }
    }
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"usedCount" ascending:NO];
    NSArray *sortDescArray = [NSArray arrayWithObject:sortDesc];
    NSArray *temp = [[NSArray alloc] initWithArray:[self.filteredFoodArray sortedArrayUsingDescriptors:sortDescArray]];
    self.filteredFoodArray = [temp mutableCopy];
}

#pragma mark -

#pragma mark UISearchDisplayController Delegate Methods

- (void)timer:(NSTimer *)theTimer {
    
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    if ([[self.filteredFoodArray objectAtIndex:0] isKindOfClass:[NSString class]] && [self.searchDisplayController.searchBar selectedScopeButtonIndex] == 1 && ![self.searchDisplayController.searchBar.text isEqualToString:@" "]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"No Results for \"%@\"\nIn Most Used List\nTry Tapping \"All\"",self.searchDisplayController.searchBar.text]
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
    }
    
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.frame = CGRectMake(140, 50, 40, 40);
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator startAnimating];
    [self.searchDisplayController.searchResultsTableView addSubview:activityIndicator];

    if ([self.searchDisplayController.searchBar.text characterAtIndex:0] == ' ' && ![self.searchDisplayController.searchBar.text isEqualToString:@" "]) { // a space that was put there by searchDisplayController:shouldReloadTableForSearchScope:  Need to get rid of it now or the search won't work '_x' <> 'x' but only if search string is just a space.  nullifying search string causes hidden results.
        [self.searchDisplayController.searchBar setText:[self.searchDisplayController.searchBar.text substringFromIndex:1]];
    }

    searchTextIsBlank = [self isSearchTextBlank:self.searchDisplayController.searchBar.text];
    
    filterTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(timer:) userInfo:nil repeats:NO];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{

    return NO;
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {

    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.frame = CGRectMake(140, 50, 40, 40);
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator startAnimating];

    [self.searchDisplayController.searchResultsTableView addSubview:activityIndicator];

    if ([self.searchDisplayController.searchBar.text length] == 0) {
        [self.searchDisplayController.searchBar setText:@" "];
    }
    
    searchTextIsBlank = [self isSearchTextBlank:self.searchDisplayController.searchBar.text];
    
    filterTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(timer:) userInfo:nil repeats:NO];

    return YES;
}


@end
     