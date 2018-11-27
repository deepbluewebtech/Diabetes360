//
//  ColorSchemeController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsClass.h"
#import "ColorSchemeDtlController.h"


@interface ColorSchemeController : UITableViewController <AddSchemeDelegate, NSFetchedResultsControllerDelegate> {
    
	NSMutableArray *schemeArray;
    SettingsClass *settings;
    UITableViewCell *schemeCell;
	
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, retain) NSMutableArray *schemeArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) SettingsClass *settings;

@property (nonatomic,retain)  IBOutlet UITableViewCell *schemeCell;

@end

