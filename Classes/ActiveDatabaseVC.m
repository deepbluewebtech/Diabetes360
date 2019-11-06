//
//  ActiveDatabaseVC.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 11/11/11.
//  Copyright (c) 2011 Deep Blue Web Technology. All rights reserved.
//

#import "ActiveDatabaseVC.h"
#import "DiabetesAppDelegate.h"
#import "DataService.h"

@interface ActiveDatabaseVC ()

-(BOOL)isStoreCompatible:(NSURL *)storeURL;
-(void)supportSite:(id)sender;

@end


@implementation ActiveDatabaseVC

@synthesize settings;
@synthesize availableDBArray;
@synthesize selectedRow;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    availableDBArray = [[NSMutableArray alloc] init];
    self.title = @"Manage Logs";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLog:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self buildActiveDBArray];
    
    UIView  *tblFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    UITextView *tblFooterView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    tblFooterView.backgroundColor = settings.kTblBgColor;
    tblFooterView.text = @"See Instructions\nOn Support Website\nFor Adding and Managing Logs\n\ndiabetes360.deepbluewebtech.com";
    tblFooterView.textAlignment = NSTextAlignmentCenter;
    tblFooterView.textColor = [UIColor darkGrayColor];
    tblFooterView.font = [UIFont fontWithName:@"Helvetica" size:15];
    tblFooterView.editable = NO;
    
    [tblFooter addSubview:tblFooterView];
    tblFooter.userInteractionEnabled = YES;
    UIGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supportSite:)];
    [tblFooter addGestureRecognizer:singleTap];
    
    self.tableView.tableFooterView = tblFooter;
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
    self.tableView.backgroundColor = settings.kTblBgColor;
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

#pragma mark - Methods

-(void)addLog:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter Name For New Log" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
}

-(void)supportSite:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://diabetes360.deepbluewebtech.com/Log-Management.html"]];
    
}

-(void)otherFileCopyError:(NSError *)error {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating New Log" message:[NSString stringWithFormat:@"Visit\ndiabetes360.deepbluewebtech.com\n for support information.\n%@\n%@",error, error.userInfo] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"error creating new Log %@",error);
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"Create Log %d",buttonIndex);

    if (buttonIndex == 0) {
        return;
    }

    NSString *theDBName = [[alertView textFieldAtIndex:0] text];
    NSLog(@"Text Field %@",[alertView textFieldAtIndex:0]);
    
    if ([theDBName isEqualToString:@""]) {
        return;
    }
    
    NSString *availableDBName = nil;
    for (NSDictionary *availableDB in self.availableDBArray) {
        availableDBName = [[availableDB valueForKey:@"fileName"] stringByDeletingPathExtension];
        if ([availableDBName isEqualToString:theDBName]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ is already used",availableDBName] message:@"Please enter another name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Diabetes" ofType:@"sqlite"];
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",theDBName]];
    NSError *error = nil;
    if (defaultStorePath) {
        [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:&error];
    }
    
    if (error) {
        [self otherFileCopyError:error];
    } else {
        NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@.sqlite",theDBName],@"fileName",[NSNumber numberWithBool:YES],@"compatible", nil];
        [availableDBArray addObject:newDict];
        [self.tableView reloadData];
    }
    
}

-(void)buildActiveDBArray {

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    int incompatibleFound = 0;
    BOOL compatible;
    NSError *error = nil;
    NSMutableArray *temp = [[fileManager contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:&error] mutableCopy];
    NSURL *storeURL = nil;
    for (NSString *file in temp) {
        if ([[file pathExtension] isEqualToString:@"sqlite"]) {
            storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:file]];
            compatible = YES;
            if (![self isStoreCompatible:storeURL]) {
                incompatibleFound++;
                compatible = NO;
                if ([self migrateStore:storeURL]) {
                    compatible = YES;
                    incompatibleFound--;
                }
            }
            [availableDBArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:file,@"fileName",[NSNumber numberWithBool:compatible],@"compatible", nil]];
        }
    }
    
    if (incompatibleFound > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%d Logs were incompatible\nwith this version of Diabetes 360\nThey are marked as such\nand can be deleted by\nswiping across the row.",incompatibleFound] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    

}
-(BOOL) migrateStore:(NSURL *)storeURL {
    
    DiabetesAppDelegate *appDelegate = (DiabetesAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSError *error = nil;
    
    NSPersistentStore *store = [[appDelegate.persistentStoreCoordinator persistentStores] objectAtIndex:0];
    [appDelegate.persistentStoreCoordinator removePersistentStore:store error:&error];
    if (error) {
        NSLog(@"migrateStore: couldn't remove store %@",[error userInfo]);
        return NO;
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![appDelegate.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"migrateStore - couldn't add store %@",[error userInfo]);
        return NO;
    }

    return YES;
}

-(BOOL) switchToStore:(NSString *)newDBName {
    
    DiabetesAppDelegate *appDelegate = (DiabetesAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSError *error = nil;
    
    NSPersistentStore *store = [[appDelegate.persistentStoreCoordinator persistentStores] objectAtIndex:0];
    [appDelegate.persistentStoreCoordinator removePersistentStore:store error:&error];

    error = nil;
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:newDBName]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    

    if (![appDelegate.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ persistentStoreCoordinator",self.class]];
    }
    if (error) {
        NSLog(@"%@",[error userInfo]);
        return NO;
    }
    
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"ActiveDBName.plist"];
    NSMutableDictionary *plistRoot = [[NSMutableDictionary alloc] initWithContentsOfFile:path]; //root of plist
    [plistRoot setValue:newDBName forKey:@"ActiveDBName"];
    [plistRoot writeToFile:path atomically:YES];
    
    settings.activeDBName = newDBName;    
    [settings loadAllCoreDataArrays];
    return YES;
    
}

-(BOOL)isStoreCompatible:(NSURL *)storeURL {
    
    NSError *error = nil;
    NSDictionary *sourceMetadata =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                               URL:storeURL
                                                             error:&error];
    
    if (sourceMetadata == nil) {
        // deal with error
    }
    
    DiabetesAppDelegate *appDelegate = (DiabetesAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *configuration = nil /* name of configuration, or nil */ ;
    NSManagedObjectModel *destinationModel = [appDelegate.persistentStoreCoordinator managedObjectModel];
    
    return  [destinationModel isConfiguration:configuration compatibleWithStoreMetadata:sourceMetadata];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [availableDBArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [[[availableDBArray objectAtIndex:indexPath.row] valueForKey:@"fileName"] stringByDeletingPathExtension];
    if ([[[availableDBArray objectAtIndex:indexPath.row] valueForKey:@"fileName"] isEqualToString:settings.activeDBName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedRow = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if ([[[availableDBArray objectAtIndex:indexPath.row] valueForKey:@"compatible"] boolValue] == NO) {
        cell.detailTextLabel.text = @"incompatible with this version";
    } else {
        cell.detailTextLabel.text = @"";
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSString *theDBName = [[availableDBArray objectAtIndex:indexPath.row] valueForKey:@"fileName"];
        if ([settings.activeDBName isEqualToString:theDBName]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Cannot Delete Active Log!\nSwitch To Another, Then Delete." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[[self.availableDBArray objectAtIndex:indexPath.row] valueForKey:@"fileName"]];
        NSError *error = nil;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtPath:path error:&error];
        if (!error) {
            [availableDBArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }

        [tableView reloadData];
    }   

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *theDBName = [[availableDBArray objectAtIndex:indexPath.row] valueForKey:@"fileName"];

    if ( (! [theDBName isEqualToString:settings.activeDBName]) && [[[availableDBArray objectAtIndex:indexPath.row] valueForKey:@"compatible"] boolValue] == YES) {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[tableView cellForRowAtIndexPath:selectedRow] setAccessoryType:UITableViewCellAccessoryNone];
        selectedRow = indexPath;
        [self switchToStore:theDBName];
    }
    
}

@end
