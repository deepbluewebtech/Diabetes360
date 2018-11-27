//
//  EventFoodController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventFoodController.h"
#import "EventFood.h"
#import "FoodItem.h"
#import "FoodWeight.h"
#import "Event.h"
#import "DataService.h"
#import "PickerLabel.h"

@interface EventFoodController ()
-(void)doRemoveTransition; 
-(NSString *)sumCarbsForLabelShowZero:(BOOL)showZero;
@end

@implementation EventFoodController

@synthesize eventFoodDS;
@synthesize event;
@synthesize settings;

@synthesize eventFoodCell;
@synthesize servingPickerValues;
@synthesize selectedIndexPath;
@synthesize currentEventFood;
@synthesize measureSortDescArray;
@synthesize pickerWeights;
@synthesize foodTableView;
@synthesize viewForSelectedCell;
@synthesize navItemView;
@synthesize carbLabel;

#define FOOD_DESC_TAG 94
#define SERVING_QTY_TAG 91
#define MEASURE_TAG 92
#define FOOD_CARB_TAG 93

float kFracPrecision;

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
    
    numFmt = [[NSNumberFormatter alloc] init];

    self.navigationItem.titleView = navItemView;
    servingPickerValues = [[NSMutableArray alloc] initWithCapacity:200];

    for (int i=0; i<=200; i++) {
        [servingPickerValues addObject:[[NSNumber numberWithInt:i] stringValue]];
    }
    
    servingPickerFractions = [[NSArray alloc] initWithObjects:@"-",@"1/8",@"1/4",@"3/8",@"1/2",@"5/8",@"3/4",@"7/8", nil];
    kFracPrecision = (float)[servingPickerFractions count];

    measureSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"measure" ascending:YES];
    self.measureSortDescArray = [NSArray arrayWithObject:measureSortDesc];

    NSMutableArray *mutableResults = [[event.EventFoods allObjects] mutableCopy];
    
    self.eventFoodDS = mutableResults;
    
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
    carbLabel.text = [self sumCarbsForLabelShowZero:NO];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    
    if (self.measurepicker) {
        [self doRemoveTransition];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [eventFoodDS count];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [settings setView:self.tableView toColorScheme:nil];
//    
//}

- (NSString *)dispServingQty:(NSNumber *)theQty {
    
    float qty = [theQty floatValue];
    
    NSDecimalNumberHandler *roundingBehavior = 
    [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *valueToRound = [[NSDecimalNumber alloc] initWithFloat:qty];
    NSDecimalNumber *qtyWholeDec = [valueToRound decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    float qtyWhole = [qtyWholeDec floatValue];
    float qtyFrac = qty - qtyWhole;
    
    
    float numerator = qtyFrac * kFracPrecision;
    
    NSString *theQtyString = @"";
    if (qtyWhole > 0) {
        theQtyString = [numFmt stringFromNumber:[NSNumber numberWithInt:(int)qtyWhole]];
    }
    
    NSString *aDash = @"";
    NSString *theFraction = @"";
    if (numerator > 0) {
        if (qtyWhole > 0) {
            aDash = @"-";
        }
        theFraction = [servingPickerFractions objectAtIndex:(int)numerator];
    }

    if (qtyWhole == 0 && qtyFrac == 0) {
        theQtyString = @"0";
    }
    
    return [NSString stringWithFormat:@"%@%@%@",theQtyString,aDash,theFraction];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"EventFoodCell" owner:self options:nil];
        cell = eventFoodCell;
        self.eventFoodCell = nil;
    }
    
    UILabel *cellLabel;
    
   
    cellLabel = (UILabel *)[cell viewWithTag:FOOD_DESC_TAG];
    cellLabel.text = [[[eventFoodDS objectAtIndex:indexPath.row] FoodItem] shortDesc];

    cellLabel = (UILabel *)[cell viewWithTag:SERVING_QTY_TAG];
    cellLabel.text = [self dispServingQty:[[eventFoodDS objectAtIndex:indexPath.row] servingQty]];
    
    cellLabel = (UILabel *)[cell viewWithTag:MEASURE_TAG];
    cellLabel.text = [[eventFoodDS objectAtIndex:indexPath.row] foodMeasure];

    cellLabel = (UILabel *)[cell viewWithTag:FOOD_CARB_TAG];
    cellLabel.text = [numFmt stringFromNumber:[[eventFoodDS objectAtIndex:indexPath.row] foodCarb]];
    
    cell.selectedBackgroundView = viewForSelectedCell;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [event removeEventFoodsObject:[eventFoodDS objectAtIndex:indexPath.row]];
        [eventFoodDS removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        carbLabel.text = [self sumCarbsForLabelShowZero:YES];
        [foodTableView reloadData];
        [self doRemoveTransition];
    }   
}

#pragma mark - Table view delegate


- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
                                   screenRect.size.height - 42.0 - size.height,
                                   size.width,
                                   size.height);
	return pickerRect;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.measurepicker && indexPath.row == selectedIndexPath.row) {
        return;
    }
    
    self.selectedIndexPath = indexPath;
    self.currentEventFood = [eventFoodDS objectAtIndex:indexPath.row];
    
	self.measurepicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	self.measurepicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	CGSize pickerSize = [self.measurepicker sizeThatFits:CGSizeZero];
	self.measurepicker.frame = [self pickerFrameWithSize:pickerSize];

	self.measurepicker.delegate = self;
	self.measurepicker.dataSource = self;
	self.measurepicker.hidden = NO;
	self.measurepicker.showsSelectionIndicator = YES;	

    self.pickerWeights = [[[[eventFoodDS objectAtIndex:selectedIndexPath.row] FoodItem] FoodWeights] sortedArrayUsingDescriptors:measureSortDescArray];

    int i=0;
    for (NSString *string in servingPickerValues) {
        if ([self.currentEventFood.servingQty intValue] == [string intValue]) {
            break;
        }
        i++;
    }
    [self.measurepicker selectRow:i inComponent:0 animated:YES];
    
    float qty = [self.currentEventFood.servingQty floatValue];
    NSDecimalNumberHandler *roundingBehavior = 
    [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *valueToRound = [[NSDecimalNumber alloc] initWithFloat:qty];
    NSDecimalNumber *qtyWholeDec = [valueToRound decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    float qtyWhole = [qtyWholeDec floatValue];
    float qtyFrac = qty - qtyWhole;


    i = kFracPrecision * qtyFrac;
    [self.measurepicker selectRow:i inComponent:1 animated:YES];
    
    i=0;
    for (FoodWeight *foodWeight in pickerWeights) {
        if ([foodWeight.measure isEqualToString:currentEventFood.foodMeasure]) {
            break;
        }
        i++;
    }
    [self.measurepicker selectRow:i inComponent:2 animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    PickerLabel *label = nil;
    label = (PickerLabel *)[cell viewWithTag:SERVING_QTY_TAG];
    label.inputView = self.measurepicker;
    label.canBecomeFirstResponder = YES;
    [label becomeFirstResponder];

}

- (void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    CGRect theRect = self.tableView.frame;
    theRect.size.height = 416;
    self.tableView.frame = theRect;

}

-(void)doRemoveTransition {
    
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath]; 
    PickerLabel *label = nil;
    label = (PickerLabel *)[cell viewWithTag:SERVING_QTY_TAG];
    [label resignFirstResponder];
    self.measurepicker = nil;


}

-(NSString *)sumCarbsForLabelShowZero:(BOOL)showZero {

    float totalCarb = 0;
    for (EventFood *eventFood in self.event.EventFoods) {
        totalCarb += [eventFood.foodCarb floatValue];
    }
    
    if (totalCarb == 0 && !showZero) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%@g",[settings formatToRoundedString:[NSNumber numberWithFloat:totalCarb] accuracy:[NSNumber numberWithInt:1.0f]]];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    UILabel *label;
    UITableViewCell *cell;
    
    cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    
    if (component == 2) {
        self.currentEventFood.foodMeasure = [[self.pickerWeights objectAtIndex:row] measure];
        self.currentEventFood.foodWeight = [[self.pickerWeights objectAtIndex:row] weight];
        label = (UILabel *)[cell viewWithTag:MEASURE_TAG];
        label.text = self.currentEventFood.foodMeasure;
    }
    
    float qty = [self.currentEventFood.servingQty floatValue];
    float carb100, weight, thisCarb;

    NSDecimalNumberHandler *roundingBehavior = 
    [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *valueToRound = [[NSDecimalNumber alloc] initWithFloat:qty];
    NSDecimalNumber *qtyWholeDec = [valueToRound decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

    float qtyWhole = [qtyWholeDec floatValue];
    float qtyFrac = qty - qtyWhole;
    

    // if comp = 0 set whole part and preserve fraction
    // if comp = 1 set fraction and preserve whole part
    // whole is row -- decimal part is row / 8.0f
    
    if (component == 0 || component == 1) {
        if (component == 0) {
            qtyWhole = (float)row;
        } else if (component == 1) {
            qtyFrac = (float)row / kFracPrecision; // this is fractional part selected
        }
        
        qty = qtyWhole + qtyFrac;
    }
    
    carb100 = [self.currentEventFood.FoodItem.carb floatValue];
    weight  = [self.currentEventFood.foodWeight floatValue];
    
    thisCarb = qty * carb100 * (weight / 100.0f); 
    
    //NSLog(@"%f %f %f",qty, carb100, weight);

    self.currentEventFood.servingQty = [NSNumber numberWithFloat:qty];
    label = (UILabel *)[cell viewWithTag:SERVING_QTY_TAG];
    label.text = [self dispServingQty:self.currentEventFood.servingQty];
    
    self.currentEventFood.foodCarb = [NSNumber numberWithFloat:thisCarb];
    label = (UILabel *)[cell viewWithTag:FOOD_CARB_TAG];
    label.text = [settings formatToRoundedString:self.currentEventFood.foodCarb accuracy:[NSNumber numberWithInt:1]];

    carbLabel.text = [self sumCarbsForLabelShowZero:YES];
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
    
	if (pickerView == self.measurepicker) {
        
        switch (component) {

            case 0:
                
                if (row == 0) 
                    returnStr = @"-";
                else 
                    returnStr = [servingPickerValues objectAtIndex:row];
                
                break;
            case 1:
                returnStr = [servingPickerFractions objectAtIndex:row];
                break;
            case 2:
                returnStr = [[self.pickerWeights objectAtIndex:row] measure];
                break;
            default:
                break;

        }
    }
	
	return returnStr;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 0.0;
    
	if (component == 0 || component == 1)
		componentWidth = 50.0;
	else
		componentWidth = 210.0;
    
	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{

	return 35.0;

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{

    switch (component) {
        case 0:
            return [servingPickerValues count];
            break;
        case 1:
            return [servingPickerFractions count];
            break;
        case 2:
            return [[[[[eventFoodDS objectAtIndex:selectedIndexPath.row] FoodItem] FoodWeights] allObjects] count];
            break;
        default:
            return 0;
            
    }

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

@end
