//
//  InsulinScaleController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InsulinScaleController.h"
#import "InsulinScale.h"

#define RANGE_LOW_TAG         91
#define RANGE_HIGH_TAG        92
#define RANGE_UNITS_TAG       93
#define RANGE_UNITS_LABEL_TAG 94

@interface InsulinScaleController ()
-(void)doHighTagsWithBaseCell:(UITableViewCell *)cell;
@end

@implementation InsulinScaleController

@synthesize settings;
@synthesize insulinScaleCell;
@synthesize numericChars;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize activeField;

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
    
    self.activeField = nil;
    
    self.title = @"Insulin Scale";
    
    numFmt = [[NSNumberFormatter alloc] init];
    self.numericChars = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
    
    swipeDelete = NO;

    self.tableView.backgroundView = settings.tableViewBgView;

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [settings sortScale];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.editing) {
        return [settings.insulinScaleArray count] + 1;
    } else {
        return [settings.insulinScaleArray count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [NSString stringWithFormat:@"Glucose (%@)",[settings glucoseLiteral]];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[settings setView:self.tableView toColorScheme:nil];
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    NSArray *lastIndex = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[settings.insulinScaleArray count] inSection:0]];
    if (editing == YES) {
        for (int i=0; i < [settings.insulinScaleArray count]; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            UITextField *textFld = (UITextField *)[cell viewWithTag:RANGE_LOW_TAG];
            textFld.textColor = [UIColor blackColor];
            textFld = (UITextField *)[cell viewWithTag:RANGE_UNITS_TAG];
            textFld.textColor = [UIColor blackColor];
        }
        if (!swipeDelete) {
            [self.tableView insertRowsAtIndexPaths:lastIndex withRowAnimation:UITableViewRowAnimationLeft];
        }
    } else {
        for (int i=0; i < [settings.insulinScaleArray count]; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            UITextField *textFld = (UITextField *)[cell viewWithTag:RANGE_LOW_TAG];
            textFld.textColor = [UIColor blueColor];
            textFld = (UITextField *)[cell viewWithTag:RANGE_UNITS_TAG];
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
        [[NSBundle mainBundle] loadNibNamed:@"InsulinScaleCell" owner:self options:nil];
        cell = insulinScaleCell;
        self.insulinScaleCell = nil;
    }
    
    UITextField *low = (UITextField *)[cell viewWithTag:RANGE_LOW_TAG];
    UILabel *high = (UILabel *)[cell viewWithTag:RANGE_HIGH_TAG];
    UITextField *units = (UITextField *)[cell viewWithTag:RANGE_UNITS_TAG];
    units.textAlignment = UITextAlignmentRight;
    
    //UILabel *unitsLabel = (UILabel *)[cell viewWithTag:RANGE_UNITS_LABEL_TAG];
    
    int size = [settings.insulinScaleArray count];
    float x = 1.0f;
    if (indexPath.row < size) {
        NSNumber *lowValue = [settings glucoseConvert:[[settings.insulinScaleArray objectAtIndex:indexPath.row] rangeMin] toExternal:YES];
        if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
            x = 0.1f;
        }
        low.text = [settings formatToRoundedString:lowValue accuracy:[NSNumber numberWithFloat:x]];
        if (indexPath.row < size - 1) {
            int i = indexPath.row + 1;
            float highValue = [[settings glucoseConvert:[[settings.insulinScaleArray objectAtIndex:i] rangeMin] toExternal:YES] floatValue];
            high.text = @" to ";
            high.text = [high.text stringByAppendingString:[settings formatToRoundedString:[NSNumber numberWithFloat:highValue - x] accuracy:[NSNumber numberWithFloat:x]]];
        } else {
            high.text = @" and up";
        }
        units.text = [[(InsulinScale *)[settings.insulinScaleArray objectAtIndex:indexPath.row] units] stringValue];
        if (self.editing) {
            low.textColor = [UIColor blackColor];
            units.textColor = [UIColor blackColor];
        } else {
            low.textColor = [UIColor blueColor];
            units.textColor = [UIColor blueColor];
        }
    } else {
        low.text = @"0";
        high.text = @"  New";
        units.text = @"0";
        low.textColor = [UIColor blueColor];
        units.textColor = [UIColor blueColor];
    }
    
    return cell;
    
}

//  puts editing acc inside grouped table.  Also in xib for cell but not working for me
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == [settings.insulinScaleArray count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }

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
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.row != [settings.insulinScaleArray count]) {
        // Delete the row from the data source
        [managedObjectContext_ deleteObject:[settings.insulinScaleArray objectAtIndex:indexPath.row]];
        [settings.insulinScaleArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

    [self doHighTagsWithBaseCell:[self.tableView cellForRowAtIndexPath:indexPath]];
    
    [settings saveSettings];

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

    return;

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

#pragma mark - Text field delegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {

    if (self.editing) {
        if ([[self.tableView indexPathForCell:[self cellFromObject:textField]] row] == [settings.insulinScaleArray count]) {
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
    for (i=0; i < [settings.insulinScaleArray count]; i++) {
        if ([[[settings.insulinScaleArray objectAtIndex:i] valueForKey:@"rangeMin"] floatValue] > [compValue floatValue]) {
            break;
        }
    }
    
    if (startRow < i) {
        i--;
    }
    NSIndexPath *thePath = [NSIndexPath indexPathForRow:i  inSection:section];
    
    return thePath;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {

    textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.activeField = textField;
    self.activeField.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];


    if ([textField.text isEqualToString:@"0"]) {
        textField.text = @" ";
    }
}

-(void) doHighTagsWithBaseCell:(UITableViewCell *)cell {
    
    UITextField *low = (UITextField *)[cell viewWithTag:RANGE_LOW_TAG];
    NSNumber *lowValue = [numFmt numberFromString:low.text];

    float x = 1.0f;
    for (int i = 0; i < [settings.insulinScaleArray count]; i++) { //redo high label based on new values
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField *high = (UITextField *)[cell viewWithTag:RANGE_HIGH_TAG];
        if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL) {
            x = 0.1f;
        }
        low.text = [settings formatToRoundedString:lowValue accuracy:[NSNumber numberWithFloat:x]];
        if (i < [settings.insulinScaleArray count] - 1) {
            int z = i + 1;
            float highValue = [[settings glucoseConvert:[[settings.insulinScaleArray objectAtIndex:z] rangeMin] toExternal:YES] floatValue];
            high.text = @" to ";
            high.text = [high.text stringByAppendingString:[settings formatToRoundedString:[NSNumber numberWithFloat:highValue - x] accuracy:[NSNumber numberWithFloat:x]]];
        } else {
            high.text = @" and up";
        }
    }
    
}- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    
    if ([string length] > 0 && ![numericChars characterIsMember:[string characterAtIndex:0]])
        return NO;
    
    if ([string isEqualToString:@"."])
        if (textField == [[[textField superview] superview] viewWithTag:RANGE_UNITS_TAG])
          if ([textField.text rangeOfString:@"."].location == NSNotFound) { // always accept one ...........decimal for insulin dose field
        return YES; 
    }
    
    if ([settings.glucoseUnit intValue] != GLUCOSE_UNIT_MMOL && [string isEqualToString:@"."]) {
        return NO;
    }
    
    if ([settings.glucoseUnit intValue] == GLUCOSE_UNIT_MMOL && [string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location != NSNotFound) {
        return NO;
    }
    
    return YES;
    
}

-(void) textFieldDidEndEditing:(UITextField *)textField {

    UITableViewCell *cell = [self cellFromObject:textField] ;

    UITextField *low = (UITextField *)[cell viewWithTag:RANGE_LOW_TAG];
    UITextField *units = (UITextField *)[cell viewWithTag:RANGE_UNITS_TAG];

    NSNumber *lowValue = [numFmt numberFromString:low.text];

    if (!lowValue) {
        lowValue = [NSNumber numberWithFloat:0.0f];
    }

    NSNumber *unitsValue = [numFmt numberFromString:units.text];

    if (!unitsValue) {
        unitsValue = [NSNumber numberWithFloat:0.0f];
    }
    
    int curRow = (int)[[self.tableView indexPathForCell:cell] row];
    
    if (curRow < [settings.insulinScaleArray count]) {
        
        NSNumber *settinglowValue = [settings glucoseConvert:[[settings.insulinScaleArray objectAtIndex:curRow] rangeMin] toExternal:YES];
        
        if ( textField == low && ![settinglowValue isEqualToNumber:lowValue] ) { //it changed
            
            NSLog(@"rangeMin changed");
            
            NSIndexPath *newPath = [self newIndexPathForRangeValue:lowValue inSection:0 startRow:curRow];
            
            if (curRow == newPath.row) {
                
                [[settings.insulinScaleArray objectAtIndex:curRow] setRangeMin:[settings glucoseConvert:lowValue toExternal:NO]]; //order in sorted array not changed, just update value
                
            } else {

                if (curRow > newPath.row) { //without conditional begin/end wrong indexPath is passed to cellForRowAtIndexPath on insert. This is a workaround.

                    [self.tableView beginUpdates];
                
                }

                [managedObjectContext_ deleteObject:[settings.insulinScaleArray objectAtIndex:curRow]];
                [settings.insulinScaleArray removeObjectAtIndex:curRow];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:curRow inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                
                InsulinScale *newScale = [NSEntityDescription insertNewObjectForEntityForName:@"InsulinScale" inManagedObjectContext:managedObjectContext_];
                newScale.rangeMin = [settings glucoseConvert:lowValue toExternal:NO];
                newScale.units = unitsValue;

                if (newPath.row < [settings.insulinScaleArray count]) {

                    [settings.insulinScaleArray insertObject:newScale atIndex:newPath.row];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationLeft];

                } else {

                    [settings.insulinScaleArray addObject:newScale];
                    [self.tableView reloadData];

                }
                
                if (curRow > newPath.row) {
                
                    [self.tableView endUpdates];
                
                }
                
            }
            
            
        } else if (textField == units && [[[settings.insulinScaleArray objectAtIndex:curRow] units] floatValue] != [unitsValue floatValue]) {

            NSLog(@"units changed");
            [[settings.insulinScaleArray objectAtIndex:curRow] setUnits:unitsValue];

        }

        [settings saveSettings];
        
    } else {
        
        if ([lowValue floatValue] != 0 && [unitsValue floatValue] != 0 ) {
            [self.tableView beginUpdates];
            InsulinScale *newScale = [NSEntityDescription insertNewObjectForEntityForName:@"InsulinScale" inManagedObjectContext:managedObjectContext_];
            newScale.rangeMin = [settings glucoseConvert:lowValue toExternal:NO];
            newScale.units = unitsValue;
            NSIndexPath *newPath = [self newIndexPathForRangeValue:lowValue inSection:0 startRow:NSIntegerMax];
            [settings.insulinScaleArray insertObject:newScale atIndex:newPath.row];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
            [settings saveSettings];
            units.text = @"0";
            low.text = @"0";
        }
    }
    
    [self doHighTagsWithBaseCell:cell];
}

#pragma mark - Done Button


- (void)doneButton:(id)sender {

    [activeField resignFirstResponder];
    activeField = nil;
    settings.accessoryView = nil;

}


@end
