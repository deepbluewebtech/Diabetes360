//
//  InsulinScaleController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExerciseController.h"
#import "ExerciseType.h"

#define EXERCISE_FACTOR_TAG         91
#define EXERCISE_TYPE_TAG           92

@implementation ExerciseController

@synthesize settings;
@synthesize exerciseCell;
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
    
    self.title = @"Exercise Factor";
    
    numFmt = [[NSNumberFormatter alloc] init];
    self.numericChars = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
    
    activeField = nil;
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.editing) {
        return [settings.exerciseTypeArray count] + 1;
    } else {
        return [settings.exerciseTypeArray count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Consult Your Physician\nFor Your Personal Values";
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[settings setView:self.tableView toColorScheme:nil];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ExerciseCell" owner:self options:nil];
        cell = exerciseCell;
        self.exerciseCell = nil;
    }
    
    UILabel *exerciseTypeFld = (UILabel *)[cell viewWithTag:EXERCISE_TYPE_TAG];
    UITextField *factorValueFld = (UITextField *)[cell viewWithTag:EXERCISE_FACTOR_TAG];
    factorValueFld.textAlignment = NSTextAlignmentRight;
    factorValueFld.inputAccessoryView = settings.accessoryView;
    [settings.theCloseButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];

    
    exerciseTypeFld.text = [[[settings.exerciseTypeArray objectAtIndex:indexPath.row] typeName] substringFromIndex:1];
    factorValueFld.text = [settings formatToRoundedString:[(ExerciseType *)[settings.exerciseTypeArray objectAtIndex:indexPath.row] factorValue] accuracy:[NSNumber numberWithFloat:0.01]];
    
    if (indexPath.row == 0) {
        factorValueFld.userInteractionEnabled = NO;
        factorValueFld.textColor = [UIColor blackColor];
    } else {
        factorValueFld.userInteractionEnabled = YES;
        factorValueFld.textColor = [UIColor blueColor];
    }
    
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == [settings.exerciseTypeArray count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }

}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.row != [settings.exerciseTypeArray count]) {
        // Delete the row from the data source
        [managedObjectContext_ deleteObject:[settings.exerciseTypeArray objectAtIndex:indexPath.row]];
        [settings.exerciseTypeArray removeObjectAtIndex:indexPath.row];
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

    if (self.editing) {
        if ([[self.tableView indexPathForCell:[self cellFromObject:textField]] row] == [settings.exerciseTypeArray count]) {
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
    for (i=0; i < [settings.exerciseTypeArray count]; i++) {
        if ([[[settings.exerciseTypeArray objectAtIndex:i] valueForKey:@"hours"] floatValue] > [compValue floatValue]) {
            break;
        }
    }
    
    if (startRow < i) {
        i--;
    }
    NSIndexPath *thePath = [NSIndexPath indexPathForRow:i  inSection:section];
    
    return thePath;
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

-(void) textFieldDidBeginEditing:(UITextField *)textField {

    if ([textField.text isEqualToString:@"0"]) {
        textField.text = @" ";
    }
    
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.activeField = textField;
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

-(void) textFieldDidEndEditing:(UITextField *)textField {

    UITableViewCell *cell = [self cellFromObject:textField];

    UITextField *factorOnVC = (UITextField *)[cell viewWithTag:EXERCISE_FACTOR_TAG];

    NSNumber *factorValue = [numFmt numberFromString:factorOnVC.text];

    if (!factorValue) {
        factorValue = [NSNumber numberWithFloat:0.0f];
    }
    
    int curRow = [[self.tableView indexPathForCell:cell] row];
    
    NSNumber *settingFactorValue = [[settings.exerciseTypeArray objectAtIndex:curRow] factorValue];
    
    if ( textField == factorOnVC && ![settingFactorValue isEqualToNumber:factorValue] ) { //it changed
        
        NSLog(@"factor changed");
        
            
        [[settings.exerciseTypeArray objectAtIndex:curRow] setFactorValue:factorValue]; //order in sorted array not changed, just update value
            
        
        [settings saveSettings];
    }
    
}

#pragma mark - Done Button


- (void)doneButton:(id)sender {
    
    [self.activeField resignFirstResponder];
    activeField = nil;
    settings.accessoryView = nil;
}

@end
