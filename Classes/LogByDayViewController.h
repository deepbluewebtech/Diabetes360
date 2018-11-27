//
//  RootViewController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 12/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EventDetailTblController.h"
#import "DataService.h"

@class PeriodStatistics;

@interface LogByDayViewController : UITableViewController <AddEventDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {

    DataService *settings;
    NSDate *detailMonth;
    UITableViewCell *logCell;
    UIImageView *baseLine;
    
    UIView *viewForSelectedCell;
	
@private
    NSDateFormatter *dateFmt;
    NSNumberFormatter *numFmt;
    PeriodStatistics *stats;

}

//@property (nonatomic, strong) NSMutableArray *eventsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) DataService *settings;
@property (nonatomic, strong) NSDate *detailMonth;

@property (nonatomic, strong) IBOutlet UITableViewCell *logCell;
@property (nonatomic, strong) IBOutlet UIImageView *baseLine;
@property (nonatomic, strong) IBOutlet UIView *viewForSelectedCell;
@end
