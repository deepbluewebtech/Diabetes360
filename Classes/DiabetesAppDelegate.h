//
//  DiabetesAppDelegate.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 12/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DataService.h"
#import "PredicateCriteriaController.h"

@interface DiabetesAppDelegate : NSObject <UIApplicationDelegate, UINavigationBarDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    DataService *settings;
    NSNumber *loadStaticTables;
    NSString *_activeDBName;

@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
    dispatch_queue_t secondaryQueue;
}

@property (nonatomic, strong) DataService *settings;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSNumber *loadStaticTables;
@property (nonatomic, strong) NSString *activeDBName;

@property (nonatomic, strong) PredicateCriteriaController *criteriaVC;

- (NSString *)applicationDocumentsDirectory;

@end

