//
//  InsulinScaleController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"


@interface InsulinOnBoardController : UITableViewController <UITextFieldDelegate> {
    
    DataService *settings;
    
    UITableViewCell *insulinOnBoardCell;

@private

    NSNumberFormatter *numFmt;
    NSCharacterSet *numericChars;
    BOOL swipeDelete;

}
@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;

@property (nonatomic,strong) DataService *settings;
@property (nonatomic,strong) IBOutlet UITableViewCell *insulinOnBoardCell;
@property (nonatomic,strong) NSCharacterSet *numericChars;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UISwitch *useIOBUI;
@property (nonatomic,strong) UITextField *activeField;
@end
