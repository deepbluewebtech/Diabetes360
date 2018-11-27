//
//  LogByMonthViewController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"
#import "EventDetailTblController.h"

@interface LogByMonthViewController : UITableViewController <AddEventDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    
    NSMutableArray *monthsArray;
    DataService *settings;
    UITableViewCell *logCell;
    UIImageView *baseLine;
    UIView *viewForSelectedCell;
    
    BOOL recalcSections;
	
@private
    NSDateFormatter *dateFmt;
    NSNumberFormatter *numFmt;
    NSMutableArray *sectionStats;
}

@property (nonatomic, strong) NSMutableArray *monthsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) IBOutlet UITableViewCell *logCell;
@property (nonatomic, strong) IBOutlet UIImageView *baseLine;
@property (nonatomic, strong) IBOutlet UIView *viewForSelectedCell;

@property (nonatomic, strong) DataService *settings;

@property (nonatomic, assign) BOOL recalcSections;

@end
