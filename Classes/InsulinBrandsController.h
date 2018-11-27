//
//  InsulinBrands.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event,InsulinBrands,DataService;

@interface InsulinBrandsController : UITableViewController <UITextFieldDelegate, NSFetchedResultsControllerDelegate> {

    Event *event;
    BOOL fromSettings;
    DataService *settings;
    
    UITableViewCell *insulinBrandCell;
    UITextField *activeField;
    
@private
    
    NSNumberFormatter *numFmt;
    NSCharacterSet *numericChars;
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;

}

@property (nonatomic,strong)  Event *event;
@property (nonatomic)         BOOL fromSettings;
@property (nonatomic,strong)  DataService *settings;
@property (nonatomic,strong)  IBOutlet UITableViewCell *insulinBrandCell;
@property (nonatomic,strong)  UITextField *activeField;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSCharacterSet *numericChars;

-(void)closeButton:(id)sender;

@end
