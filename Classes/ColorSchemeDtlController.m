//
//  ColorSchemeDtlController.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorSchemeDtlController.h"

#define SCHEME_NAME         0
#define SCREEN_BG           1
#define NORMAL_TEXT         2
#define BUTTON_TEXT         3
#define BUTTON_BG           4
#define HIGHLIGHT_TEXT      5
#define TABLE_CELL_BG       6
#define ALT_TABLE_CELL_BG   7

#define SCHEME_ATTR_COUNT   6

@implementation ColorSchemeDtlController

@synthesize colorScheme;
@synthesize schemeTableView;

@synthesize schemeNameCell;
@synthesize screenBgCell;
@synthesize normalTextCell;
@synthesize highlightedTextCell;
@synthesize tableCellBgCell;
@synthesize altTableCellBgCell;
@synthesize buttonTextCell;
@synthesize buttonBgCell;

@synthesize schemeName;
@synthesize screenBg;
@synthesize normalText;
@synthesize highlightedText;
@synthesize tableCellBg;
@synthesize altTableCellBg;
@synthesize buttonText;
@synthesize buttonBg;

@synthesize settings;
@synthesize managedObjectContext;

@synthesize delegate;

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

    selectedIndexPath = [[NSIndexPath alloc] init];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveScheme:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    [buttonItem release];
    
    settings.colorScheme.active = [NSNumber numberWithBool:NO];
    settings.colorScheme = colorScheme; 
    settings.colorScheme.active = [NSNumber numberWithBool:YES];
    
    if (self.delegate) {
        self.title = @"New Scheme";
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSchemeAdd:)];
        self.navigationItem.leftBarButtonItem = buttonItem;
        [schemeName becomeFirstResponder];
        [buttonItem release];
    } else {
        self.title = colorScheme.name;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    schemeName.text = colorScheme.name;
    screenBg.backgroundColor = colorScheme.viewBackground;
    normalText.backgroundColor = colorScheme.textNormal;
    highlightedText.backgroundColor = colorScheme.textHightlight;
    tableCellBg.backgroundColor = colorScheme.tableCell;
    altTableCellBg.backgroundColor = colorScheme.tableCellAlternate;
    buttonText.backgroundColor = colorScheme.buttonTitle;
    buttonBg.backgroundColor = colorScheme.buttonBackground;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [schemeTableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void) dealloc {
    
    [selectedIndexPath release];
    [colorScheme release];
    [settings release];
    [managedObjectContext release];
    [super dealloc];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    colorScheme.name = schemeName.text;
    self.title = schemeName.text;
    textField.textColor = [UIColor blackColor]; 
    
    return;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    textField.textColor = [UIColor blueColor];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([colorScheme.name isEqualToString:@"Default"]) {
        return NO;
    }
    
    return YES;
}


#pragma mark - App Buttons

-(void)saveScheme:(id)sender {
    
    if ([schemeName.text isEqualToString:@""]) {
        return;
    }
    settings.colorScheme = self.colorScheme;
    settings.colorScheme.active = [NSNumber numberWithBool:YES];
    
    NSError *error = nil;
    
	if (![self.managedObjectContext save:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ saveScheme",self.class]];
	}
    
    [schemeTableView reloadData];
    
    if (self.delegate) {
        [self.delegate dismissAddScheme];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)cancelSchemeAdd:(id)sender {

    [self.managedObjectContext deleteObject:colorScheme];
    [self.delegate dismissAddScheme];
    
}

#pragma mark - Color Picker

- (void)colorPickerViewController:(ColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    
    NSLog(@"color=%@",color);
    switch (selectedIndexPath.row) {
        case SCHEME_NAME:
            break;
        case SCREEN_BG:
            colorScheme.viewBackground = color;
            break;
        case NORMAL_TEXT:
            colorScheme.textNormal = color;
            break;
        case HIGHLIGHT_TEXT:
            colorScheme.textHightlight = color;
            break;
        case TABLE_CELL_BG:
            colorScheme.tableCell = color;
            break;
        case ALT_TABLE_CELL_BG:
            colorScheme.tableCellAlternate = color;
            break;
        case BUTTON_TEXT:
            colorScheme.buttonTitle = color;
            break;
        case BUTTON_BG:
            colorScheme.buttonBackground = color;
            break;
        default:
            break;
    }
    
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
    return SCHEME_ATTR_COUNT;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [settings setView:self.tableView toColorScheme:nil];
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.row) {
        case SCHEME_NAME:
            return schemeNameCell;
        case SCREEN_BG:
            return screenBgCell;
        case NORMAL_TEXT:
            return normalTextCell;
        case HIGHLIGHT_TEXT:
            return highlightedTextCell;
//        case TABLE_CELL_BG:
//            return tableCellBgCell;
//        case ALT_TABLE_CELL_BG:
//            return altTableCellBgCell;
        case BUTTON_TEXT:
            return buttonTextCell;
        case BUTTON_BG:
            return buttonBgCell;
        default:
            break;
    }

    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

    ColorPickerViewController *colorPickerViewController = [[ColorPickerViewController alloc] initWithNibName:@"ColorPickerViewController" bundle:nil];
    colorPickerViewController.delegate = self;

    selectedIndexPath = indexPath;
    
    switch (indexPath.row) {
        case SCHEME_NAME:
            [schemeName becomeFirstResponder];
            return;
        case SCREEN_BG:
            colorPickerViewController.defaultsColor = colorScheme.viewBackground;
            break;
        case NORMAL_TEXT:
            colorPickerViewController.defaultsColor = colorScheme.textNormal;
            break;
        case HIGHLIGHT_TEXT:
            colorPickerViewController.defaultsColor = colorScheme.textHightlight;
            break;
        case TABLE_CELL_BG:
            colorPickerViewController.defaultsColor = colorScheme.tableCell;
            break;
        case ALT_TABLE_CELL_BG:
            colorPickerViewController.defaultsColor = colorScheme.tableCellAlternate;
            break;
        case BUTTON_TEXT:
            colorPickerViewController.defaultsColor = colorScheme.buttonTitle;
            break;
        case BUTTON_BG:
            colorPickerViewController.defaultsColor = colorScheme.buttonBackground;
            break;
        default:
            break;
    }

    [self.navigationController pushViewController:colorPickerViewController animated:YES];
    [colorPickerViewController release];
    
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
}

@end
