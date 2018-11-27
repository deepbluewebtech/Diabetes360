//
//  InsulinScaleController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"


@interface ExerciseController : UITableViewController <UITextFieldDelegate> {
    
    DataService *settings;
    
    UITableViewCell *exerciseCell;

@private

    NSNumberFormatter *numFmt;
    NSCharacterSet *numericChars;

}

@property (nonatomic,strong) DataService *settings;
@property (nonatomic,strong) IBOutlet UITableViewCell *exerciseCell;
@property (nonatomic,strong) NSCharacterSet *numericChars;
@property (nonatomic,strong) UITextField *activeField;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end
