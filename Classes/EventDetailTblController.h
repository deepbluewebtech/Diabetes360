//
//  EventDetailTblController.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddEventDelegate;

@class Event, InsulinBrand, DataService, PickerLabel;

@interface EventDetailTblController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate ,UITextViewDelegate> {

    Event                   *event;
    DataService           *settings;

    IBOutlet PickerLabel	*eventDate;
    IBOutlet PickerLabel    *timeOfDay;
    IBOutlet UITextField    *insulinAmt;
    IBOutlet UILabel        *takeAsPrescribed;
    IBOutlet UITextField	*glucose;
    IBOutlet UITextField	*totalCarb;
    IBOutlet UILabel        *totalCarbLabel;
    IBOutlet UILabel        *foodLabel;
    IBOutlet UIButton       *foodButton;
    IBOutlet PickerLabel    *insulinBrand;
    IBOutlet PickerLabel    *site;
    IBOutlet PickerLabel    *ketone;
    IBOutlet UILabel        *calcLabelGlucose;
    IBOutlet UILabel        *calcLabelCarb;
    IBOutlet UILabel        *calcLabelIOB;
    IBOutlet PickerLabel    *calcLabelExercise;
    IBOutlet UIButton       *exerciseButton;
    IBOutlet UIButton       *IOBButton;
    IBOutlet UILabel        *componentGlucose;
    IBOutlet UILabel        *componentCarb;
    IBOutlet UILabel        *componentIOB;
    IBOutlet UILabel        *componentExercise;
    IBOutlet UILabel        *componentExerciseSign;
    IBOutlet UIImageView    *IOBStrike;
    IBOutlet UIImageView    *ExerciseStrike;
    IBOutlet UIImageView    *carbStrike;
    IBOutlet UIImageView    *glucoseStrike;

    IBOutlet UIView *IOBView;
    IBOutlet UIView *ExerciseView;
    
    IBOutlet UILabel        *glucoseUnitLabel;
    IBOutlet UITextView     *note;
    
    BOOL didSelectNewSite;
    
@private

    NSMutableArray          *sitesArray;
    NSMutableArray          *ketoneArray;
    
    UIDatePicker            *datePicker;
    UIPickerView            *sitePicker;
    UIPickerView            *exercisePicker;
    UIPickerView            *ketonePicker;
    UIPickerView            *insulinPicker;
    UIPickerView            *timeOfDayPicker;

    NSNumberFormatter       *numFmt;
    NSDateFormatter         *dateFmt;
    NSCharacterSet          *numericChars;
    
    UIAlertView             *alertTargetRate;
    UIAlertView             *alertInsulin;

    NSArray *tblSections;
    NSArray *tblSection0Cells;
    NSArray *tblSection1Cells;
    NSArray *tblSection2Cells;
    NSArray *tblSection3Cells;

    BOOL reloadNote;
    BOOL noCalc;
    
    UIViewController        *fromViewController;
    
}

@property (nonatomic,strong) DataService *settings;
@property (nonatomic,strong) Event *event;

@property (nonatomic,strong) IBOutlet UITableViewCell *dateCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *glucoseCarbCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *insulinDoseCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *insulinBrandSiteCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *ketoneCell;
@property (nonatomic,strong) IBOutlet UITableViewCell *noteCell;


@property (nonatomic,strong) NSDateFormatter *dateFmt;
@property (nonatomic,strong) NSNumberFormatter *numFmt;
@property (nonatomic,strong) NSCharacterSet *numericChars;

@property (nonatomic,strong) UIAlertView *alertTargetRate;
@property (nonatomic,strong) UIAlertView *alertInsulin;

@property (nonatomic,strong) PickerLabel *eventDate;
@property (nonatomic,strong) PickerLabel *timeOfDay;
@property (nonatomic,strong) UITextField *insulinAmt;
@property (nonatomic,strong) UILabel     *takeAsPrescribed;
@property (nonatomic,strong) UITextField *glucose;
@property (nonatomic,strong) UITextField *totalCarb;
@property (nonatomic,strong) UILabel     *totalCarbLabel;
@property (nonatomic,strong) UILabel     *foodLabel;
@property (nonatomic,strong) UIButton    *foodButton;
@property (nonatomic,strong) PickerLabel *insulinBrand;
@property (nonatomic,strong) PickerLabel *site;
@property (nonatomic,strong) PickerLabel *ketone;
@property (nonatomic,strong) UILabel     *calcLabelGlucose;
@property (nonatomic,strong) UILabel     *calcLabelCarb;
@property (nonatomic,strong) UILabel     *calcLabelIOB;
@property (nonatomic,strong) UILabel     *calcLabelExercise;
@property (nonatomic,strong) UILabel     *componentGlucose;
@property (nonatomic,strong) UILabel     *componentCarb;
@property (nonatomic,strong) UILabel     *componentIOB;
@property (nonatomic,strong) UILabel     *componentExercise;
@property (nonatomic,strong) UILabel     *componentExerciseSign;
@property (nonatomic,strong) UIImageView *IOBStrike;
@property (strong, nonatomic) IBOutlet UILabel *calcNoCalc;
@property (strong, nonatomic) IBOutlet UILabel *unitsLabel;

@property (nonatomic,strong) UILabel     *glucoseUnitLabel;
@property (nonatomic,strong) UITextView  *note;

@property (nonatomic,strong) UIButton    *exerciseButton;
@property (nonatomic,strong) UIButton    *IOBButton;

@property (nonatomic,strong) NSMutableArray *sitesArray;
@property (nonatomic,strong) NSMutableArray *ketoneArray;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) UIViewController *fromViewController;
@property (nonatomic) BOOL noCalc;

@property (nonatomic,unsafe_unretained) id <AddEventDelegate> delegate;


- (IBAction)showExercisePicker:(id)sender;
- (IBAction)IOBButton:(id)sender;
-(IBAction)showFood:(id)sender;
@end



@protocol AddEventDelegate <NSObject>

-(void) dismissAddEvent;

@end

