//
//  InsulinFormulaController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InsulinFactorController.h"
#import "InsulinFactor.h"
#import "PickerLabel.h"

#define TIME_TAG 91
#define VALUE_TAG 92


@interface InsulinFactorController ();
- (void) showDatePicker:(NSDate *)theDate;
- (void)doRemoveTransition; 
@end

@implementation InsulinFactorController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;

@synthesize settings;
@synthesize selectedIndexPath;
@synthesize insulinFactorCell;

@synthesize activeField;

@synthesize numericChars;

int fullTableHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        numFmt = [[NSNumberFormatter alloc] init];
        dateFmt = [[NSDateFormatter alloc] init];
        sectionViews = [[NSMutableArray alloc] initWithObjects:@"0",@"1",@"2",nil];
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
        
    self.managedObjectContext = settings.managedObjectContext;
    
    self.title = @"Insulin Factors";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.numericChars = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];

    [settings setView:self.view toColorScheme:nil];

    fullTableHeight = self.tableView.frame.size.height - 29;
    self.tableView.sectionFooterHeight = 50;

    self.tableView.backgroundView = settings.tableViewBgView;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 50)];
    self.tableView.tableFooterView = view;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

    // will cause save in textdidEndEdit...
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    UITextField *value = (UITextField *)[cell viewWithTag:VALUE_TAG];
    [value resignFirstResponder]; 
    
    [settings saveSettings];
}

-(void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:NO];
    fetchedResultsController_ = nil;
    
}


- (void)viewDidUnload
{    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) resignTextResponder {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    if (cell) {
        UITextField *value = (UITextField *)[cell viewWithTag:VALUE_TAG];
        if ([value isFirstResponder]) [value resignFirstResponder];
    }

}

-(void) resignPickerResponder {

    if (selectedIndexPath) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        PickerLabel *time = (PickerLabel *)[cell viewWithTag:TIME_TAG];
        time.textColor = [UIColor blackColor];
        [time resignFirstResponder];
    }

    datePicker = nil;

}

-(void) resetAfterEdit {

    [self resignPickerResponder];
    self.selectedIndexPath = nil;
    
    [self.tableView reloadData];  // reload needed so viewSections is accurate after delete

}

#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    [self resignPickerResponder];
    [self resignTextResponder];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];

    if ([sectionInfo numberOfObjects] > 1) return YES;
    return NO;
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;

}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath]; 
    CGRect bounds = cell.contentView.bounds;
    bounds.size.width -= 30;
    cell.contentView.bounds = bounds;
    
    return UITableViewCellEditingStyleDelete;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   
    NSString *factorId = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    if ([factorId isEqualToString:@"1TR"]) {
        return [NSString stringWithFormat:@"%@ (%@)",@"Target Rate",[settings glucoseLiteral]];
    } else if ([factorId isEqualToString:@"2CF"]) {
        return [NSString stringWithFormat:@"%@ (%@)",@"Corrective Factor",[settings glucoseLiteral]];
    } else if ([factorId isEqualToString:@"3KF"]) {
        return @"Carbohydrate Factor";
    } else {
        return @"Unknown Factor Value!! Call Support!" ;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Tap Here To Add Time Slot";
    label.textColor = [UIColor colorWithWhite:0.3f alpha:1];
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.backgroundColor = settings.kTblBgColor;
    [view addSubview:label];

    view.userInteractionEnabled = YES;
    UIGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTapped:)];
    [view addGestureRecognizer:singleTap];
    
    [sectionViews replaceObjectAtIndex:section withObject:view];

    return view;
}

- (void)addTapped:(id)sender {
    
    [self resignPickerResponder];
    
    int section = [sectionViews indexOfObject:[sender view]];
    if (section == NSNotFound) { // failsafe: views messed up in array, redo...
        [self.tableView reloadData];
        NSLog(@"sectionViews messed up, table reloaded");
        return;
    }

    id copyFrom = [[[[self.fetchedResultsController sections] objectAtIndex:section] objects] lastObject];

    InsulinFactor *newFactor = [NSEntityDescription insertNewObjectForEntityForName:@"InsulinFactor" inManagedObjectContext:self.managedObjectContext];
    newFactor.timeOfDayBegin = [NSDate dateWithTimeInterval:1 sinceDate:[copyFrom valueForKey:@"timeOfDayBegin"]]; // add a second so new one goes at bottom of section
    newFactor.factorId = [copyFrom valueForKey:@"factorId"];
    newFactor.factorValue = [copyFrom valueForKey:@"factorValue"];

    [self.tableView reloadData];  //needed so viewSections is accurate after add
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    [dateFmt setDateStyle:NSDateFormatterNoStyle];
    [dateFmt setTimeStyle:NSDateFormatterShortStyle];
    
    PickerLabel *time = (PickerLabel *)[cell viewWithTag:TIME_TAG];
    UITextField *value = (UITextField *)[cell viewWithTag:VALUE_TAG];
    value.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];

    value.textAlignment = NSTextAlignmentRight;
    
    time.text       = [dateFmt stringFromDate:[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"timeOfDayBegin"]];
    if (indexPath.section < 2) {
        float x = 1.0f;
        if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
            x = 0.1f;
        }
        value.text = [settings formatToRoundedString:[settings glucoseConvert:[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"factorValue"] toExternal:YES] accuracy:[NSNumber numberWithFloat:x]]; 
    } else {
        value.text = [numFmt stringFromNumber:[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"factorValue"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([indexPath compare:selectedIndexPath] == NSOrderedSame) {
        time.textColor = [UIColor redColor];
    } else {
        time.textColor = [UIColor blackColor];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"InsulinFactorCell" owner:self options:nil];
        cell = insulinFactorCell;
        self.insulinFactorCell = nil;
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    //NSLog(@"%d",[[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] numberOfObjects]);
    if (editingStyle == UITableViewCellEditingStyleDelete &&
        [[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] numberOfObjects] != 1) { // don't delete last one
        // Delete the row from the data source
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [self resetAfterEdit];
    }   
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //this happens only when tap is outside of text field
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    PickerLabel *time = nil;
    
    UITableViewCell *prevCell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    if (prevCell) {
        time = (PickerLabel *)[prevCell viewWithTag:TIME_TAG];
        time.textColor = [UIColor blackColor];
        UITextField *value = (UITextField *)[prevCell viewWithTag:VALUE_TAG];
        if ([value isFirstResponder]) [value resignFirstResponder];
    }
    
    UITableViewCell *curCell =  [self.tableView cellForRowAtIndexPath:indexPath];
    if (curCell) {
        time = (PickerLabel *)[curCell viewWithTag:TIME_TAG];
        time.textColor = [UIColor redColor];
    }
    
    self.selectedIndexPath = indexPath;

    [self showDatePicker:[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"timeOfDayBegin"]];

    prevCell = nil;
    curCell = nil;
    time = nil;
    
    //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}

#pragma mark -
#pragma mark TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string length] > 0 && ![numericChars characterIsMember:[string characterAtIndex:0]])
        return NO;
    
    if ([settings.glucoseUnit intValue] != GLUCOSE_UNIT_MMOL && [string isEqualToString:@"."]) {
        return NO;
    }
    
    if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL && [string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location != NSNotFound) {
        return NO;
    }
    
    return YES;
    
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return YES;
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    if (datePicker) {
        [datePicker resignFirstResponder];
        datePicker = nil;
    }
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (selectedIndexPath) {  // cleanup previously selected cell
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        PickerLabel *time = (PickerLabel *)[cell viewWithTag:TIME_TAG];
        time.textColor = [UIColor blackColor];
        UITextField *value = (UITextField *)[cell viewWithTag:VALUE_TAG];
        value.textColor = [UIColor blackColor];
    }

    textField.textColor = [UIColor redColor];

    self.selectedIndexPath = [self.tableView indexPathForCell:[self cellFromObject:textField]];

    if (selectedIndexPath.section == 0 && [textField.text isEqualToString:@"0"]) { // sections are constant and defined by first char in database
        textField.text = @" ";
    } else if ([textField.text isEqualToString:@"1"]) { // other two factors have defaults of 1
        textField.text = @" ";
    }
    
    activeField = textField;
    
}
//////// test commit
-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    textField.textColor = [UIColor blackColor];
    
    if (selectedIndexPath.section > 0 && [[numFmt numberFromString:textField.text] intValue] == 0) {
        textField.text = @"1";
    }
    
    if ([[self.tableView indexPathForCell:[self cellFromObject:textField]] section] < 2) { //last section does not change based on glucose unit
        [[self.fetchedResultsController objectAtIndexPath:selectedIndexPath] setValue:[settings glucoseConvert:[numFmt numberFromString:textField.text] toExternal:NO] forKey:@"factorValue"];
    } else {
        [[self.fetchedResultsController objectAtIndexPath:selectedIndexPath] setValue:[numFmt numberFromString:textField.text] forKey:@"factorValue"];    
    }

    selectedIndexPath = nil;

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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InsulinFactor" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"factorId" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"timeOfDayBegin" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    NSFetchedResultsController *aFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:self.managedObjectContext 
                                          sectionNameKeyPath:@"factorId" 
                                                   cacheName:nil];
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
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
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
            self.selectedIndexPath = newIndexPath;
            [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}



 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    // In the simplest, most efficient, case, reload the table view.
//    [self.tableView reloadData];
//}


#pragma mark pickers
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
                                   screenRect.size.height - 42.0 - size.height,
                                   size.width,
                                   size.height);
	return pickerRect;
}

-(void)doRemoveTransition {
    
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    [self resetAfterEdit];
    
}

- (void)showDatePicker:(NSDate *)theDate {
    
    [activeField resignFirstResponder];
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    datePicker.hidden = NO;
    datePicker.minuteInterval = [settings.datePickerInterval intValue];
    datePicker.datePickerMode = UIDatePickerModeTime;
    [datePicker addTarget:self action:@selector(updateTime:) forControlEvents:UIControlEventValueChanged];
        
    [datePicker setDate:theDate animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    PickerLabel *time = (PickerLabel *)[cell viewWithTag:TIME_TAG];
    
    time.inputView = datePicker;
    time.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    time.canBecomeFirstResponder = YES;
    [time becomeFirstResponder];
    activeField = time;

}

-(void)updateTime:(UIDatePicker *)sender {
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDateComponents *comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[sender date]];
    [comps setYear:2000];
    [comps setMonth:1];
    [comps setDay:1];
    
    [[self.fetchedResultsController objectAtIndexPath:selectedIndexPath] setValue:[calendar dateFromComponents:comps] forKey:@"timeOfDayBegin"];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    
    PickerLabel *time = (PickerLabel *)[cell viewWithTag:TIME_TAG];
    time.text = [dateFmt stringFromDate:(NSDate *)[sender date]];
    
}

- (void)doneButton:(id)sender {

    if ([activeField isMemberOfClass:[PickerLabel class]]) {
        [self resignPickerResponder];
    } else {
        [activeField resignFirstResponder];
    }

    activeField = nil;
    settings.accessoryView = nil;
   
}

@end
