//
//  InsulinFormulaController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"

@class InsulinFactor;

@interface InsulinFactorController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,UITextFieldDelegate> {
  
    DataService  *settings;
    UITableViewCell *insulinFactorCell;
    
@private

    NSMutableArray *sectionViews;
    
    NSIndexPath *selectedIndexPath;

    NSNumberFormatter *numFmt;
    NSDateFormatter *dateFmt;
    NSCharacterSet *numericChars;
    
    UIDatePicker *datePicker;

    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    
    id activeField;
    
}

@property (nonatomic, strong) DataService *settings;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) IBOutlet UITableViewCell *insulinFactorCell;

@property (nonatomic,strong) NSCharacterSet *numericChars;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) id activeField;

@end
