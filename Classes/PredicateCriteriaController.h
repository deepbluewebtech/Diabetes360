//
//  PredicateCriteriaController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class DataService, DailySchedule, PickerLabel;

@interface PredicateCriteriaController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate> {
    
    DataService *settings;
    
    UITableViewCell *startDateCell;
    UITableViewCell *endDateCell;
    UITableViewCell *timeOfDayCell;
    
    PickerLabel *startDate;
    PickerLabel *endDate;
    PickerLabel *timeOfDay;
    UIButton *executeButton;
    UIButton *resetButton;
    UIButton *waitingCancel;
    
    int nextController;

@private
    
    UIDatePicker    *datePicker;
    UIPickerView    *timeOfDayPicker;
    
    NSDateFormatter     *dateFmt;
    NSNumberFormatter   *numFmt;
    NSNumberFormatter *numFmt1;
    
    NSString *csvString;
    NSString *csvFoodString;
    NSString *emailBody;
    
    NSIndexPath   *selectedIndexPath;
    
    NSDate        *theStartDate;
    NSDate        *theEndDate;
    
    NSDateFormatter *csvDateFmt;
    NSDateFormatter *csvTimeFmt;
    
    DailySchedule *theSchedule;
    BOOL          isBeforeSchedule;  
    BOOL          pickerStartDate;

    NSArray *tblSections;
    NSArray *tblSection0Cells;
    NSArray *tblSection1Cells;
    
    UIView  *waiting;
    UIProgressView *waitingProgress;
    NSNumber *cancelBuild;
    
    dispatch_queue_t secondaryQueue;

}

#define NEXT_IS_GRAPH 0
#define NEXT_IS_MAIL 1

@property (nonatomic,strong) DataService *settings;

@property (nonatomic,strong) NSDate        *theStartDate;
@property (nonatomic,strong) NSDate        *theEndDate;

@property (nonatomic,strong) DailySchedule *theSchedule;
@property (nonatomic) int nextController;

@property (nonatomic, strong) NSString *csvString;
@property (nonatomic, strong) NSString *csvFoodString;
@property (nonatomic, strong) NSString *emailBody;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic,strong) IBOutlet UITableViewCell *startDateCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *endDateCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *timeOfDayCell;
@property (nonatomic,strong) IBOutlet UILabel *startDate;
@property (nonatomic,strong) IBOutlet UILabel *endDate;
@property (nonatomic,strong) IBOutlet UILabel *timeOfDay;
@property (nonatomic,strong) IBOutlet UIButton *executeButton;
@property (nonatomic,strong) IBOutlet UIButton *resetButton;
@property (nonatomic,strong) IBOutlet UIButton *waitingCancel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *formatSegCtl;

@property (nonatomic,strong) IBOutlet UIView *waiting;
@property (nonatomic,strong) IBOutlet UIProgressView *waitingProgress;
@property (nonatomic,strong) NSDateFormatter *csvDateFmt;
@property (nonatomic,strong) NSDateFormatter *csvTimeFmt;
@property (nonatomic,strong) NSNumberFormatter *numFmt1;
@property (nonatomic,strong) NSNumberFormatter *numFmt;

@property (nonatomic,strong) NSNumber *cancelBuild;

-(IBAction)buildResultGoNext:(id)sender;
-(IBAction)resetCriteria:(id)sender;
-(IBAction)cancelExport:(id)sender;

@end
