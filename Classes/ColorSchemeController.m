//
//  ColorSchemeController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorSchemeController.h"

@interface ColorSchemeController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation ColorSchemeController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize schemeArray;
@synthesize settings;

@synthesize schemeCell;

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

- (void) dealloc {
    
    [schemeArray release];
    [settings release];
    [fetchedResultsController_ release];
    [managedObjectContext_ release];
    [super dealloc];
    
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Color Schemes";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addScheme:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	NSMutableArray *mutableFetchResults = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    
	self.schemeArray = mutableFetchResults;

 	[mutableFetchResults release];
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
    self.title = @"Color Schemes";
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
- (void)addScheme:(id)sender {
    
    ColorScheme *newScheme = [NSEntityDescription insertNewObjectForEntityForName:@"ColorScheme" inManagedObjectContext:self.managedObjectContext];
    
    ColorSchemeDtlController *addController = [[ColorSchemeDtlController alloc] initWithNibName:@"ColorSchemeDtlController" bundle:nil];
    
    newScheme.textNormal = settings.colorScheme.textNormal;
    newScheme.textHightlight = settings.colorScheme.textHightlight;
    newScheme.viewBackground = settings.colorScheme.viewBackground;
    newScheme.tableCell = settings.colorScheme.tableCell;
    newScheme.tableCellAlternate = settings.colorScheme.tableCellAlternate;
    newScheme.buttonBackground = settings.colorScheme.buttonBackground;
    newScheme.buttonTitle = settings.colorScheme.buttonTitle;
    newScheme.tableCellAlternate = settings.colorScheme.tableCellAlternate;
    
    addController.colorScheme = newScheme;
    
    addController.managedObjectContext = self.managedObjectContext;
    addController.settings = self.settings;
    addController.delegate = self;
    
    // Create the nav controller and add the view controllers.
    UINavigationController *theNavController = [[UINavigationController alloc]
                                                initWithRootViewController:addController];
    
    [self presentModalViewController:theNavController animated:YES];
    
    [theNavController release];
    [addController release];
}

- (void)dismissAddScheme {
    
    //reset the checkmark on visible cells
    NSArray *visibleCells = [self.tableView visibleCells];
    for (UITableViewCell *cell in visibleCells) {
        if ([self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]] == settings.colorScheme) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    [self dismissModalViewControllerAnimated:YES];
   
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ColorSchemeCell" owner:self options:nil];
        cell = schemeCell;
        self.schemeCell = nil;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
 
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITextField *schemeName = (UITextField *)[cell viewWithTag:96];
    UILabel *color1 = (UILabel *)[cell viewWithTag:91];
    UILabel *color2 = (UILabel *)[cell viewWithTag:92];
    UILabel *color3 = (UILabel *)[cell viewWithTag:93];
    UILabel *color4 = (UILabel *)[cell viewWithTag:94];
    UILabel *color5 = (UILabel *)[cell viewWithTag:95];
    
    schemeName.text = [managedObject valueForKey:@"name"];
    color1.backgroundColor = [managedObject valueForKey:@"viewBackground"];
    color2.backgroundColor = [managedObject valueForKey:@"textNormal"];
    color3.backgroundColor = [managedObject valueForKey:@"buttonTitle"];
    color4.backgroundColor = [managedObject valueForKey:@"buttonBackground"];
    color5.backgroundColor = [managedObject valueForKey:@"textHightlight"];  //typo in database
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (managedObject == settings.colorScheme) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    ColorSchemeDtlController *detailController = [[ColorSchemeDtlController alloc] initWithNibName:@"ColorSchemeDtlController" bundle:nil];
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    detailController.colorScheme = (ColorScheme *)selectedObject;
    detailController.managedObjectContext = self.managedObjectContext;
    detailController.settings = self.settings;
    detailController.delegate = nil;
    detailController.schemeTableView = tableView;
    
    self.title = @"Schemes";
    [self.navigationController pushViewController:detailController animated:YES];
    
    
    [detailController release];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[self.fetchedResultsController objectAtIndexPath:indexPath] name] isEqualToString:@"Default"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Default Scheme Can't Be Deleted."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
        [alert release];
        //NSLog(@"cant delete default");
        return;
    }
    
    if ([self.fetchedResultsController objectAtIndexPath:indexPath] == settings.colorScheme) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"That Scheme is Active\nSwitch To Another, Then Delete."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
        [alert release];
        //NSLog(@"cant delete active");
        return;
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ commitEditingStyle",self.class]];
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ColorScheme" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    [NSFetchedResultsController deleteCacheWithName:@"scheme"];
    NSFetchedResultsController *aFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:self.managedObjectContext 
                                          sectionNameKeyPath:nil
                                                   cacheName:@"scheme"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ fetchedResultsController",self.class]];
    }
    
    return fetchedResultsController_;
}    


#pragma mark -
#pragma mark Fetched results controller delegate

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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    //[self.tableView reloadData];
    [self.tableView endUpdates];
    NSError *error = nil;
    
	if (![self.managedObjectContext save:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ controllerDidChangeContent",self.class]];
	}
    
}

@end
