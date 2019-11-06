//
//  InsulinScaleController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InsulinOnBoardController.h"
#import "IOBFactor.h"

#define RANGE_HOURS_TAG         91
#define RANGE_PCT_REDUCE_TAG       92

@interface InsulinOnBoardController () <UIAlertViewDelegate>

@end
@implementation InsulinOnBoardController

@synthesize settings;
@synthesize insulinOnBoardCell;
@synthesize numericChars;
@synthesize activeField;
@synthesize managedObjectContext=managedObjectContext_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSLog(@"init");
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    self.title = @"Insulin On Board";
    
    numFmt = [[NSNumberFormatter alloc] init];
    self.numericChars = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
    
    swipeDelete = NO;

    self.tableView.backgroundView = settings.tableViewBgView;
    self.tableHeaderView.backgroundColor = settings.kTblBgColor;
    self.tableView.tableHeaderView = self.tableHeaderView;

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.useIOBUI.on = settings.useIOB;
    activeField = nil;
    
    if (settings.useIOB == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IOB is OFF!"
                                                        message:@"Please be sure this is the setting you want."
                                                       delegate:self cancelButtonTitle:@"Leave Off" otherButtonTitles:@"Turn On", nil];
        [alert show];
    }
    [settings sortIOBFactor];
}

- (void)viewDidUnload
{
    [self setUseIOBUI:nil];
    [self setTableHeaderView:nil];
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        return;
    } else {
        settings.useIOB = YES;
        [settings saveSettings];
        self.useIOBUI.on = YES;
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.editing) {
        return [settings.IOBFactorArray count] + 1;
    } else {
        return [settings.IOBFactorArray count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Consult Your Physician\nFor Your Personal Values";
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[settings setView:self.tableView toColorScheme:nil];
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    NSArray *lastIndex = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[settings.IOBFactorArray count] inSection:0]];
    if (editing == YES) {
        for (int i=0; i < [settings.IOBFactorArray count]; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            UITextField *textFld = (UITextField *)[cell viewWithTag:RANGE_HOURS_TAG];
            textFld.textColor = [UIColor blackColor];
            textFld = (UITextField *)[cell viewWithTag:RANGE_PCT_REDUCE_TAG];
            textFld.textColor = [UIColor blackColor];
        }
        if (!swipeDelete) {
            [self.tableView insertRowsAtIndexPaths:lastIndex withRowAnimation:UITableViewRowAnimationLeft];
        }
    } else {
        for (int i=0; i < [settings.IOBFactorArray count]; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            UITextField *textFld = (UITextField *)[cell viewWithTag:RANGE_HOURS_TAG];
            textFld.textColor = [UIColor blueColor];
            textFld = (UITextField *)[cell viewWithTag:RANGE_PCT_REDUCE_TAG];
            textFld.textColor = [UIColor blueColor];
        }
        if (!swipeDelete) {
            [self.tableView deleteRowsAtIndexPaths:lastIndex withRowAnimation:UITableViewRowAnimationLeft];		
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    swipeDelete = YES; //prevents add row cell added when user swipes across cell to delete
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    swipeDelete = NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"InsulinOnBoardCell" owner:self options:nil];
        cell = insulinOnBoardCell;
        self.insulinOnBoardCell = nil;
    }
    
    UITextField *hours = (UITextField *)[cell viewWithTag:RANGE_HOURS_TAG];
    UITextField *percentReduce = (UITextField *)[cell viewWithTag:RANGE_PCT_REDUCE_TAG];
    percentReduce.textAlignment = NSTextAlignmentRight;
    
    int size = [settings.IOBFactorArray count];
    float round = 0.01f;
    if (indexPath.row < size) {
        NSNumber *hoursValue = [[settings.IOBFactorArray objectAtIndex:indexPath.row] hours];
        hours.text = [settings formatToRoundedString:hoursValue accuracy:[NSNumber numberWithFloat:round]];
        percentReduce.text = [[(IOBFactor *)[settings.IOBFactorArray objectAtIndex:indexPath.row] percentReduce] stringValue];
        if (self.editing) {
            hours.textColor = [UIColor blackColor];
            percentReduce.textColor = [UIColor blackColor];
        } else {
            hours.textColor = [UIColor blueColor];
            percentReduce.textColor = [UIColor blueColor];
        }
    } else {
        hours.text = @"0";
        percentReduce.text = @"0";
        hours.textColor = [UIColor blueColor];
        percentReduce.textColor = [UIColor blueColor];
    }
    
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == [settings.IOBFactorArray count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }

}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.row != [settings.IOBFactorArray count]) {
        // Delete the row from the data source
        [managedObjectContext_ deleteObject:[settings.IOBFactorArray objectAtIndex:indexPath.row]];
        [settings.IOBFactorArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

    [settings saveSettings];

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    return;

}

#pragma mark - Text Field delegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {

    UITableViewCell *theCell = [self cellFromObject:textField];
    
    if (self.editing) {
        if ([[self.tableView indexPathForCell:theCell] row] == [settings.IOBFactorArray count]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }

}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;

}

-(NSIndexPath *)newIndexPathForRangeValue:(NSNumber *)value inSection:(NSUInteger)section startRow:(NSUInteger)startRow {
    
    int i=0;
    NSNumber *compValue = [settings glucoseConvert:value toExternal:NO];
    for (i=0; i < [settings.IOBFactorArray count]; i++) {
        if ([[[settings.IOBFactorArray objectAtIndex:i] valueForKey:@"hours"] floatValue] > [compValue floatValue]) {
            break;
        }
    }
    
    if (startRow < i) {
        i--;
    }
    NSIndexPath *thePath = [NSIndexPath indexPathForRow:i  inSection:section];
    
    return thePath;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    
    if ([string length] > 0 && ![numericChars characterIsMember:[string characterAtIndex:0]])
        return NO;
    
    if ([string isEqualToString:@"."])
        if ([textField.text rangeOfString:@"."].location != NSNotFound) { // accept one decimal point
            return NO; 
    }
    
    return YES;
    
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([textField.text isEqualToString:@"0"]) {
        textField.text = @" ";
    }
    
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.activeField = textField;
    self.activeField.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];

}

-(void) textFieldDidEndEditing:(UITextField *)textField {

    UITableViewCell *cell = [self cellFromObject:textField];

    UITextField *hours = (UITextField *)[cell viewWithTag:RANGE_HOURS_TAG];
    UITextField *percentReduce = (UITextField *)[cell viewWithTag:RANGE_PCT_REDUCE_TAG];

    NSNumber *hoursValue = [numFmt numberFromString:hours.text];

    if (!hoursValue) {
        hoursValue = [NSNumber numberWithFloat:0.0f];
    }

    NSNumber *percentReduceValue = [numFmt numberFromString:percentReduce.text];

    if (!percentReduceValue) {
        percentReduceValue = [NSNumber numberWithFloat:0.0f];
    }
    
    int curRow = [[self.tableView indexPathForCell:cell] row];
    
    if (curRow < [settings.IOBFactorArray count]) {
        
        //this rounding is necessary because of floating point inaccuracies. Need to convert all this floating point to decimalNumbers.
        NSNumber *settingHoursValue = [settings roundTheNumber:[[settings.IOBFactorArray objectAtIndex:curRow] hours] accuracy:[NSNumber numberWithFloat:0.01f]];
        NSNumber *roundedHoursValue = [settings roundTheNumber:hoursValue accuracy:[NSNumber numberWithFloat:0.01f]];
        
        if ( textField == hours && ![settingHoursValue isEqualToNumber:roundedHoursValue] ) { //it changed
            
            //NSLog(@"hours changed");
            
            NSIndexPath *newPath = [self newIndexPathForRangeValue:hoursValue inSection:0 startRow:curRow];
            
            if (curRow == newPath.row) {
                
                [[settings.IOBFactorArray objectAtIndex:curRow] setHours:hoursValue]; //order in sorted array not changed, just update value
                
            } else {

                if (curRow > newPath.row) { //without conditional begin/end wrong indexPath is passed to cellForRowAtIndexPath on insert. This is a workaround.

                    [self.tableView beginUpdates];
                
                }

                [managedObjectContext_ deleteObject:[settings.IOBFactorArray objectAtIndex:curRow]];
                [settings.IOBFactorArray removeObjectAtIndex:curRow];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:curRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                
                IOBFactor *newFactor = [NSEntityDescription insertNewObjectForEntityForName:@"IOBFactor" inManagedObjectContext:managedObjectContext_];
                newFactor.hours = hoursValue;
                newFactor.percentReduce = percentReduceValue;

                if (newPath.row < [settings.IOBFactorArray count]) {

                    [settings.IOBFactorArray insertObject:newFactor atIndex:newPath.row];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationLeft];

                } else {

                    [settings.IOBFactorArray addObject:newFactor];
                    [settings sortIOBFactor];
                    [self.tableView reloadData];

                }
                
                if (curRow > newPath.row) {
                
                    [self.tableView endUpdates];
                
                }
                
            }
            
            
        } else if (textField == percentReduce && [[[settings.IOBFactorArray objectAtIndex:curRow] percentReduce] floatValue] != [percentReduceValue floatValue]) {

            NSLog(@"percentReduce changed");
            [[settings.IOBFactorArray objectAtIndex:curRow] setPercentReduce:percentReduceValue];

        }

        [settings saveSettings];
        
    } else {
        
        if ([hoursValue floatValue] != 0 ) {
            [self.tableView beginUpdates];
            IOBFactor *newFactor = [NSEntityDescription insertNewObjectForEntityForName:@"IOBFactor" inManagedObjectContext:managedObjectContext_];
            newFactor.hours = hoursValue;
            newFactor.percentReduce = percentReduceValue;
            NSIndexPath *newPath = [self newIndexPathForRangeValue:hoursValue inSection:0 startRow:NSIntegerMax];
            [settings.IOBFactorArray insertObject:newFactor atIndex:newPath.row];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
            [settings saveSettings];
            percentReduce.text = @"0";
            hours.text = @"0";
        }
    }
    
}

- (IBAction)IOBSwitchChanged:(id)sender {
    
    UISwitch *theSwitch = (UISwitch *) sender;
    settings.useIOB = theSwitch.on;
    [settings saveSettings];
    
    if (settings.useIOB == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Be Aware" message:@"...that turning IOB off here will disable it in the entire app.  To use IOB selectively, leave it on here and disable it when logging." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

#pragma mark - Done Button

- (void)doneButton:(id)sender {
    
    [self.activeField resignFirstResponder];
    activeField = nil;
    settings.accessoryView = nil;
}


@end
