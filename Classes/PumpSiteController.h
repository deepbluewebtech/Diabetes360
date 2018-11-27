//
//  PumpSiteController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"


@interface PumpSiteController : UIViewController <UITextFieldDelegate> {
    
    UIDatePicker *reminderTimePicker;
    UITextField  *pumpSiteInterval;
    UISwitch     *reminderSwitch;
    
    DataService *settings;
    
@private
    NSNumberFormatter *numFmt;
    NSCharacterSet *numericChars;
}

@property (nonatomic,strong) IBOutlet UIDatePicker *reminderTimePicker;
@property (nonatomic,strong) IBOutlet UITextField  *pumpSiteInterval;
@property (nonatomic,strong) IBOutlet UISwitch     *reminderSwitch;

@property (nonatomic,strong) DataService *settings;
@property (nonatomic,strong) NSCharacterSet *numericChars;

@property (nonatomic,strong) UITextField *activeField;


@end
