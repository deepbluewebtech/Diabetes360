//
//  InsulinBrands.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InsulinBrandsController.h"
#import "InsulinBrand.h"
#import "Event.h"
#import "DataService.h"

@implementation InsulinBrandsController

@synthesize event;
@synthesize fromSettings;
@synthesize settings;
@synthesize insulinBrandCell;

@synthesize activeField;

@synthesize numericChars;

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;


#define BRAND_TAG 91
#define REMINDER_TAG 92

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
    
    self.title = @"Insulin Brands";

    self.numericChars = [NSCharacterSet decimalDigitCharacterSet];
    
    self.managedObjectContext = settings.managedObjectContext;
    self.activeField = nil;
    
    UIView  *tblHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UILabel *tblHeaderText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    tblHeaderText.backgroundColor = settings.kTblBgColor;
    tblHeaderText.text = @"Tap Below To Prescribe";
    tblHeaderText.textAlignment = NSTextAlignmentCenter;
    tblHeaderText.textColor = [UIColor darkGrayColor];
    [tblHeader addSubview:tblHeaderText];
    self.tableView.tableHeaderView = tblHeader;
    numFmt = [[NSNumberFormatter alloc] init];

    self.tableView.backgroundView = settings.tableViewBgView;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [settings saveSettings];
    [settings loadPrescribedInsulin];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    fetchedResultsController_ = nil;
}

- (void)viewDidUnload
{

    [super viewDidUnload];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(UITableViewCell *)cellFromObject:(id)theObject {
    
    do {
        if ([[theObject superview] isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)[theObject superview];
        }
        
        theObject = [theObject superview];
        
    } while (theObject != nil);
    
    return nil;
    
}


#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string length] > 0 && ![numericChars characterIsMember:[string characterAtIndex:0]])
        return NO;
    
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    textField.textColor = [UIColor blackColor];
    UITableViewCell *cell = [self cellFromObject:textField];
    [[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]] setDoseInterval:[numFmt numberFromString:textField.text]];
    self.activeField = nil;

}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    textField.textColor = [UIColor blueColor];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];

    self.activeField = textField;
    
}

-(void)closeButton:(id)sender {
    
    [self.activeField resignFirstResponder];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *returnString = [[[[self.fetchedResultsController sections] objectAtIndex:section] name] substringFromIndex:1];

    if ([returnString isEqualToString:@"Long"]) {
        returnString = [returnString stringByAppendingString:@"                      Hourly Interval*"];
    }
    
    return returnString;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 1) {
        return @"*Reminder";
    } else {
        return nil;
    }
    
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [self setView:self.tableView toColorScheme:nil];
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"InsulinBrandCell" owner:self options:nil];
        cell = insulinBrandCell;
        self.insulinBrandCell = nil;
    }
    
	NSManagedObject *InsulinBrand = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *cellLabel;
    UITextField *cellTextField;
    
    cellLabel = (UILabel *)[cell viewWithTag:BRAND_TAG];   
    cellTextField = (UITextField *) [cell viewWithTag:REMINDER_TAG];
    
    cellLabel.text = [InsulinBrand valueForKey:@"brandName"];

    if (fromSettings) { //view controller is being used to setup prescribed insulin brands from settings area of app
        if ([[InsulinBrand valueForKey:@"prescribed"] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            if ([[[InsulinBrand valueForKey:@"classification"] substringFromIndex:1] isEqualToString:LONG_INSULIN]) {
                cellTextField.text = [[InsulinBrand valueForKey:@"doseInterval"] stringValue];
                cellTextField.hidden = NO;
            } else {
                cellTextField.hidden = YES;
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cellTextField.hidden = YES;
        }
    } else {
        cellTextField.hidden = YES;
        if (InsulinBrand == event.InsulinBrand) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField *theTextField = (UITextField *)[theCell viewWithTag:REMINDER_TAG];
    
    if ( [[[self.fetchedResultsController objectAtIndexPath:indexPath] prescribed] boolValue] == YES) {
        [[self.fetchedResultsController objectAtIndexPath:indexPath] setPrescribed:[NSNumber numberWithBool:NO]];
        [theCell setAccessoryType:UITableViewCellAccessoryNone];
        theTextField.hidden = YES;
    } else   {
        UITableViewCell *tempCell;
        int i = 0;
        NSString *insulinClass = [[[self.fetchedResultsController objectAtIndexPath:indexPath] classification] substringFromIndex:1];
        if (![insulinClass isEqualToString:@"Oral"] && ![insulinClass isEqualToString:@"Miscellaneous"]) {
            for (InsulinBrand *insulinBrand in [[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] objects]) {
                insulinBrand.prescribed = [NSNumber numberWithBool:NO];
                tempCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                [tempCell setAccessoryType:UITableViewCellAccessoryNone];
                i++;
            }
        }
        [[self.fetchedResultsController objectAtIndexPath:indexPath] setPrescribed:[NSNumber numberWithBool:YES]];
        [theCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        theTextField.text = [[[self.fetchedResultsController objectAtIndexPath:indexPath] doseInterval] stringValue];
        if ([[[[self.fetchedResultsController objectAtIndexPath:indexPath] classification] substringFromIndex:1] isEqualToString:LONG_INSULIN]) {
            theTextField.hidden = NO;
        }
    }
    
    // Deselect the row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"InsulinBrand"];
    [fetchRequest setFetchBatchSize:20];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"InsulinBrands" ofType:@"plist"];
    
    if (path) {
        //scan plist in case new ones were added between app version updates

        NSMutableDictionary *plistRoot = [[NSMutableDictionary alloc] initWithContentsOfFile:path]; //root of plist
        NSArray *insulinFromPlist = [[NSArray alloc] initWithArray:[plistRoot valueForKey:@"InsulinBrands"]];
        
        InsulinBrand *insulinBrandObj = nil;
        
        for (NSDictionary *brandFromPlist in insulinFromPlist) {
            
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"brandName = %@",[brandFromPlist valueForKey:@"brandName"]]];
            NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            if (result.count == 0 ) {
            
                insulinBrandObj = (InsulinBrand *)[NSEntityDescription insertNewObjectForEntityForName:@"InsulinBrand" inManagedObjectContext:self.managedObjectContext];
                insulinBrandObj.brandName = [brandFromPlist valueForKey:@"brandName"];
                insulinBrandObj.classification = [brandFromPlist valueForKey:@"classification"];
                insulinBrandObj.prescribed = [NSNumber numberWithBool:NO];
                insulinBrandObj.doseInterval = [brandFromPlist valueForKey:@"doseInterval"];
            
            } else {
                InsulinBrand *brandFromDB = (InsulinBrand *)[result objectAtIndex:0];
                if (![[brandFromPlist valueForKey:@"classification"] isEqualToString:brandFromDB.classification]) {
                    brandFromDB.classification = [brandFromPlist valueForKey:@"classification"];
                }
            }
            
        }
        
    }
    
    fetchRequest.predicate = nil;
    [self.managedObjectContext save:nil];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"classification" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"brandName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    [NSFetchedResultsController deleteCacheWithName:@"Rootx"];
    NSFetchedResultsController *aFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:self.managedObjectContext 
                                          sectionNameKeyPath:@"classification" 
                                                   cacheName:@"Rootx"];
    aFetchedResultsController.delegate = self;
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
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

#pragma mark - Done Button


- (void)doneButton:(id)sender {

    [self.activeField resignFirstResponder];
    settings.accessoryView = nil; //prevents crash on next VC to use
    
}


@end
