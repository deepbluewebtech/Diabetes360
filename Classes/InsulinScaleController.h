//
//  InsulinScaleController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"


@interface InsulinScaleController : UITableViewController <UITextFieldDelegate> {
    
    DataService *settings;
    
    UITableViewCell *insulinScaleCell;

@private

    NSNumberFormatter *numFmt;
    NSCharacterSet *numericChars;
    BOOL swipeDelete;
    UITextField *activeField;

}

@property (nonatomic,strong) DataService *settings;
@property (nonatomic,strong) IBOutlet UITableViewCell *insulinScaleCell;
@property (nonatomic,strong) NSCharacterSet *numericChars;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) UITextField *activeField;

@end
