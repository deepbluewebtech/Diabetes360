//
//  SettingsController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataService.h"


@interface SettingsController : UITableViewController <UITextFieldDelegate> {

    DataService *settings;
    
@private
    
    NSNumberFormatter   *numFmt;
    NSCharacterSet      *numericChars;

    NSArray *tblSections;
    NSArray *tblSection0Cells;
    NSArray *tblSection1Cells;
    NSArray *tblSection2Cells;
    NSArray *tblSection3Cells;
    NSArray *tblSection4Cells;

    UIView *viewForSelectedCell;
    
}

@property (nonatomic,strong) DataService *settings;

@property (nonatomic,strong) IBOutlet UITableViewCell *ketoneCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *insulinCalcCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *dailyScheduleCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *datePickerIntervalCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *glucoseUnitCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *pumpSiteChangeCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *roundingAccuracyCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *prescribedInsulinCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *upcomingRemindersCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *insulinOnBoardCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *exerciseFactorCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *welcomeCell;
@property (strong,nonatomic) IBOutlet UITableViewCell *switchLogCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sitesCell;

@property (nonatomic,strong) IBOutlet UITextField           *ketoneThreshold;
@property (nonatomic,strong) IBOutlet UISegmentedControl    *insulinCalcMethod;
@property (nonatomic,strong) IBOutlet UITextField           *datePickerInterval;
@property (nonatomic,strong) IBOutlet UISegmentedControl    *glucoseUnit;
@property (nonatomic,strong) IBOutlet UITextField           *roundingAccuracy;
@property (strong, nonatomic) IBOutlet UISwitch *useIOB;

@property (nonatomic,strong) UITextField *activeField;
@property (nonatomic,strong) IBOutlet UIView *viewForSelectedCell;

@property (nonatomic,strong) NSCharacterSet *numericChars;

-(void)resignTextResponders;

@end
