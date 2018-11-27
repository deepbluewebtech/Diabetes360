//
//  DailySchedDtlController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailySchedule.h"
#import "DataService.h"
#import "PickerLabel.h"

@protocol AddSchedItemDelegate;

@interface DailySchedDtlController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
    DailySchedule *schedule;
    DataService  *settings;
    
    UITableViewCell *nameCell;
    UITableViewCell *beginTimeCell;
    UITableViewCell *endTimeCell;
    UITableViewCell *reminderCell;
    UITableViewCell *carbsCell;
    UITableViewCell *anyTimeCell;
    UITableViewCell *insulinDoseCell;
    UITableViewCell *insulinBrandCell;
    
    UITextField *name;
    UITextField *carbsToIngest;
    UISwitch    *reminder;
    UISwitch    *complexCarb;
    PickerLabel *beginTime;
    PickerLabel *endTime;
    UISwitch    *anyTime;
    UITextField *insulinDose;
    PickerLabel *insulinBrand;
    

@private
    
    NSIndexPath     *selectedIndexPath;
    UIDatePicker    *datePicker;

    UIPickerView    *insulinPicker;
    
    NSDateFormatter     *dateFmt;
    NSNumberFormatter   *numFmt;
    NSCharacterSet      *numericChars;
    
}

@property (nonatomic,strong) DailySchedule *schedule;
@property (nonatomic,strong) DataService *settings;

@property (nonatomic,strong) NSIndexPath *selectedIndexPath;

@property (nonatomic,strong) IBOutlet UITableViewCell *nameCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *beginTimeCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *endTimeCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *reminderCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *carbsCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *anyTimeCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *insulinDoseCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *insulinBrandCell;

@property (nonatomic,strong) IBOutlet UITextField *name;
@property (nonatomic,strong) IBOutlet UITextField *carbsToIngest;
@property (nonatomic,strong) IBOutlet UISwitch    *reminder;
@property (nonatomic,strong) IBOutlet UISwitch    *complexCarb;
@property (nonatomic,strong) IBOutlet UILabel     *beginTime;
@property (nonatomic,strong) IBOutlet UILabel     *endTime;
@property (nonatomic,strong) IBOutlet UISwitch    *anyTime;
@property (nonatomic,strong) IBOutlet UITextField *insulinDose;
@property (nonatomic,strong) IBOutlet UILabel *insulinBrand;

@property (nonatomic,strong) NSCharacterSet *numericChars;

@property (nonatomic,strong) id activeField;

@property (nonatomic, unsafe_unretained) id <AddSchedItemDelegate> delegate;

@end

@protocol AddSchedItemDelegate <NSObject>
        
-(void) dismissAddSchedItem;

@end