
//  DiabetesAppDelegate.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 12/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DiabetesAppDelegate.h"
#import "RootViewController.h"
#import "SetupViewController.h"
#import "InsulinFactorController.h"
#import "InsulinScaleController.h"
#import "InsulinBrandsController.h"
#import "InsulinOnBoardController.h"
#import "DailyScheduleController.h"
#import "PumpSiteController.h"
#import "ActiveDatabaseVC.h"
#import "Event.h"
#import "Site.h"
#import "Appirater.h"

@interface DiabetesAppDelegate () <UIAlertViewDelegate>
-(void)scanAndFixInvalidSectionKeys;
@end

@implementation DiabetesAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize settings;
@synthesize activeDBName=_activeDBName;

@synthesize loadStaticTables;

#pragma mark -
#pragma mark Application lifecycle

-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    NSLog(@"\n\n%@\n\n",[self applicationDocumentsDirectory]);
    
    //shipped plist is in app bundle, if doc dir doesn't have one, copy shipped on in there so updates to it will persist when app is relaunched.  plist in app bundle does not persist.
    NSString *activePlistPath  = [[NSBundle mainBundle] pathForResource:@"ActiveDBName" ofType:@"plist"];
    NSString *docDirPlistPath  = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"ActiveDBName.plist"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
	if ( ! [fileManager fileExistsAtPath:docDirPlistPath]) {
        [fileManager copyItemAtPath:activePlistPath toPath:docDirPlistPath error:NULL];
    }
    
    NSMutableDictionary *plistRoot = [[NSMutableDictionary alloc] initWithContentsOfFile:docDirPlistPath]; //root of plist
    self.activeDBName = [plistRoot valueForKey:@"ActiveDBName"];
    
    if (!self.activeDBName) {
        self.activeDBName = @"Diabetes.sqlite";
    }
    
    self.settings = [[DataService alloc] init];
    secondaryQueue = dispatch_queue_create("secondary", DISPATCH_QUEUE_SERIAL);

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    NSLog(@"%@",[NSBundle mainBundle]);

    dispatch_async(secondaryQueue, ^{
        [self scanAndFixInvalidSectionKeys];
        [self handleSites];
        [self handleDummyEvents];
    });
    
    navigationController = [[UINavigationController alloc] init];

    //settings.runInitialSetup = [NSNumber numberWithInt:1];  //forces welcome display for testing
    if ([settings.runInitialSetup intValue]) {
        SetupViewController *setupController = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
        setupController.settings = self.settings;
        [self.navigationController pushViewController:setupController animated:YES];
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            NSLog(@"Pad");
        }
        RootViewController *rootController;
        rootController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
        rootController.managedObjectContext = self.managedObjectContext;
        rootController.settings = self.settings;
        [self.navigationController pushViewController:rootController animated:YES];
    }
    
    [Appirater appLaunched:YES];
    settings.runInitialSetup = [NSNumber numberWithBool:NO];
    navigationController.navigationBar.tintColor = settings.kNavBarColor;
    
#ifdef LOG_MAX_FOR_LITE
    self.settings.useIOB = NO;
#endif
    
    self.criteriaVC = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"UIApplicationSupportedInterfaceOrientationIsEnabled"];

    [self checkCloud];
    
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];

    return YES;
}

-(void)checkCloud {
    
    CKDatabase *privateDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordChangeTag = %@", @"jqobrl37"];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Event" predicate:predicate];
    [privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"%@",error.userInfo);
            // Error handling for failed fetch from public database
        }
        else {
            NSLog(@"%@",results);
            // Display the fetched records
        }
    }];
    
}

-(void)handleSites {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Site"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"active = YES"];
    request.predicate = pred;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];

    if ([result count] == 0) {
        //no active sites, activate all.
        request.predicate = nil;
        result = [self.managedObjectContext executeFetchRequest:request error:nil];
        for (Site *site in result) {
            site.active = [NSNumber numberWithBool:YES];
        }

        [self.managedObjectContext save:nil];
        
    }

}

-(void)handleDummyEvents {
    
    //delete any dummy events:
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:settings.managedObjectContext];
    [request setEntity:entity];
    [request setSortDescriptors:nil];
    
    NSError *error = nil;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isDummy = %@", [NSNumber numberWithBool:YES]];
    [request setPredicate:pred];
    NSArray *result = [settings.managedObjectContext executeFetchRequest:request error:&error];
    if (error) [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ viewWillAppear",self.class]];
    
    if ([result count] > 0) {
        for (Event *event in result) {
            [settings.managedObjectContext deleteObject:event];
        }
    }

    
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {  // this only happens if application is in foreground see doc for background handling
    
    NSLog(@"background notification = \n%@",notification);
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    BOOL pump = NO;
    NSInteger i=0; //all pump site notifications count as 1 on badge
    
    for (UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
    
        //NSLog(@"%@",[notif.userInfo valueForKey:@"type"]);
        if ([[notif.userInfo valueForKey:@"type"] isEqualToString:PUMP_SITE_TYPE]) {
        
            if (pump == NO) {
                i++;
                pump = YES; // count it once;
            }
            
        } else {
            
            i++;
            
        }
    }
    
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:i];
    
    [settings saveSettings];

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    [settings saveSettings];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [Appirater appEnteredForeground:YES];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */

}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    [settings saveSettings];
	
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Diabetes" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
    
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:self.activeDBName];
    NSURL *storeURL = nil;

    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary *options = nil;
    BOOL pscCompatible = NO;

	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if ([fileManager fileExistsAtPath:storePath]) {
        // if existing model is compatible with new one, fall thru otherwise, lightweight migration performed
        storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:self.activeDBName]];
        NSDictionary *sourceMetadata =
        [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                   URL:storeURL
                                                                 error:&error];
        
        if (sourceMetadata == nil) {
            // deal with error
        }
        
        NSString *configuration = nil /* name of configuration, or nil */ ;
        NSManagedObjectModel *destinationModel = [persistentStoreCoordinator_ managedObjectModel];
        pscCompatible = [destinationModel
                         isConfiguration:configuration
                         compatibleWithStoreMetadata:sourceMetadata];
        
        if (!pscCompatible) {
            NSLog(@"Lightweight Migration will run!!");
            // Allow inferred migration from the original version of the application.
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        }
        
    } else {
        //If no store database copy in the default one that is packaged with the app
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Diabetes" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
		storeURL = [NSURL fileURLWithPath:storePath];
        pscCompatible = YES;  // static tables are included in default database
        NSLog(@"Database was copied from default");
    }

    error = nil;
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"%@",error);
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ persistentStoreCoordinator",self.class]];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        NSString *theFileName = [[[[self.persistentStoreCoordinator persistentStores] objectAtIndex:0] URL] lastPathComponent];
        NSArray *comps = [theFileName componentsSeparatedByString:@"."];
        theFileName = [NSString stringWithFormat:@"%@~.%@",[comps objectAtIndex:0],[comps objectAtIndex:1]];
        storeURL = [storeURL URLByDeletingLastPathComponent];
        storeURL = [storeURL URLByAppendingPathComponent:theFileName];
        [fileManager removeItemAtURL:storeURL error:&error];
    }

    self.loadStaticTables = [NSNumber numberWithBool:NO]; // this is used in settings class init method
    if (!pscCompatible) {  // need store added and migrated to do this. pscCompatible is set when test is performed above.
        ActiveDatabaseVC *activeDBVC = [[ActiveDatabaseVC alloc] init];
        [activeDBVC buildActiveDBArray];
        activeDBVC = nil;
        self.loadStaticTables = [NSNumber numberWithBool:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Validate IOB" message:@"There is a new feature\nin this version to disable IOB.\nPlease check that it is set as you wish in all logs you have set up." delegate:self cancelButtonTitle:@"Go There" otherButtonTitles:nil];
        [alert show];
    }

    return persistentStoreCoordinator_;
}

#pragma mark - Check Database Integrity
-(void)scanAndFixInvalidSectionKeys {

    //runs on secondary thread and only when app is not launching from suspended state.
    
    NSDateFormatter *dateFmt1 = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFmt2 = [[NSDateFormatter alloc] init];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext_];
    [request setEntity:entity];
    [request setSortDescriptors:nil];
    
    NSError *error = nil;
    NSMutableArray *result = [[managedObjectContext_ executeFetchRequest:request error:&error] mutableCopy];
    
    if (error != nil) {
        [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ scanAndFixInvalidSectionKeys-read",self.class]];
    }	

    [dateFmt1 setDateFormat:@"yyyy-MM-dd"];
    [dateFmt2 setDateFormat:@"yyyy-MM"];
    
    NSMutableString *fmtDateShouldBe  = nil;
    NSMutableString *fmtMonthShouldBe = nil;
    
    BOOL saveDB = NO;
    for (Event *event in result) {
        fmtDateShouldBe  = [[dateFmt1 stringFromDate:event.eventDate] mutableCopy];
        fmtMonthShouldBe = [[dateFmt2 stringFromDate:event.eventDate] mutableCopy];
        if (![event.fmtDate isEqualToString:fmtDateShouldBe]) {
            NSLog(@"fmtDate changed from %@ to %@",event.fmtDate, fmtDateShouldBe);
            event.fmtDate = fmtDateShouldBe;
            saveDB = YES;
         }
        if (![event.fmtMonth isEqualToString:fmtMonthShouldBe]) {
            NSLog(@"fmtMonth changed from %@ to %@",event.fmtMonth, fmtMonthShouldBe);
            event.fmtMonth = fmtMonthShouldBe;
            saveDB = YES;
        }
    }
    
    if (saveDB) {
        error = nil;
        if (![managedObjectContext_ save:&error]) {
            [settings databaseErrorAlert:error more:[NSString stringWithFormat:@"%@ scanAndFixInvalidSectionKeys-save",self.class]];
            NSLog(@"scanAndFix %@",[error userInfo]);
        }
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    InsulinOnBoardController *controller = [[InsulinOnBoardController alloc] initWithNibName:@"InsulinOnBoardController" bundle:nil];
    controller.settings = self.settings;
    
    RootViewController *rootController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    rootController.managedObjectContext = settings.managedObjectContext;
    rootController.settings = self.settings;
    
    NSArray *newStack = [[NSArray alloc] initWithObjects:rootController, controller, nil];
    [self.navigationController setViewControllers:newStack animated:YES];

}

#pragma mark - Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    NSLog(@"memory low in %@!!!",[self class]);
    if (self.criteriaVC) {
        self.criteriaVC.cancelBuild = [NSNumber numberWithBool:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too Many Days Selected" message:@"Please Narrow the Date Range" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    
}


@end

