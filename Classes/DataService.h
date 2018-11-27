//
//  SettingsClass.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColorScheme.h"
#import "BuyItVC.h"
@class DailySchedule, InsulinBrand;

@interface DataService : NSObject {
    
    NSNumber *calcType;

    NSMutableArray *insulinScaleArray;
    NSMutableArray *IOBFactorArray;
    NSMutableArray *exerciseTypeArray;
    NSMutableArray *dailyScheduleArray;
    NSMutableArray *prescribedInsulinArray;
    
    NSNumber *datePickerInterval;
    NSNumber *glucoseUnit;
    NSNumber *pumpSiteInterval;
    NSDate   *pumpSiteTime;
    NSNumber *pumpSiteAlert;
    NSNumber *roundingAccuracy;
    NSNumber *ketoneThreshold;
    NSNumber *quickSettings;
    NSNumber *runInitialSetup;
    
    NSString *activeDBName;
    
    UIColor *kTblBgColor;
    UIColor *kNavBarColor;
    UIColor *kTblRowSelColor;
    
    ColorScheme *colorScheme;
    
    BOOL manualCarb;
    
    NSManagedObjectContext *managedObjectContext;
    
}

@property (nonatomic, strong) UIView *accessoryView;
@property (nonatomic, strong) UIButton *theCloseButton;

@property (nonatomic,strong) NSNumber *calcType;

@property (nonatomic,strong) NSMutableArray *insulinScaleArray;
@property (nonatomic,strong) NSMutableArray *IOBFactorArray;
@property (nonatomic,strong) NSMutableArray *exerciseTypeArray;
@property (nonatomic,strong) NSMutableArray *dailyScheduleArray;
@property (nonatomic,strong) NSMutableArray *prescribedInsulinArray;

@property (nonatomic, strong) NSNumber *datePickerInterval;
@property (nonatomic, strong) NSNumber *glucoseUnit;
@property (nonatomic, strong) NSNumber *pumpSiteInterval;
@property (nonatomic, strong) NSDate   *pumpSiteTime;
@property (nonatomic, strong) NSNumber *pumpSiteAlert;
@property (nonatomic, strong) NSNumber *roundingAccuracy;
@property (nonatomic, strong) NSNumber *ketoneThreshold;
@property (nonatomic, strong) NSNumber *quickSettings;
@property (nonatomic, strong) NSNumber *runInitialSetup;
@property (nonatomic, strong) UIView *tableViewBgView;

@property (nonatomic, strong) NSString *activeDBName;

@property (nonatomic,strong) UIColor *kTblBgColor;
@property (nonatomic,strong) UIColor *kNavBarColor;
@property (nonatomic,strong) UIColor *kTblRowSelColor;
@property (nonatomic,strong) UIColor *kRedColor;
@property (nonatomic,strong) UIColor *kGreenColor;

@property (nonatomic) BOOL manualCarb;
@property (nonatomic) BOOL useIOB;

@property (nonatomic) int  logCount;

@property (nonatomic, strong) ColorScheme *colorScheme;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

#define PUMP_SITE_TYPE @"PumpSite"
#define DAILY_SCHED_TYPE @"DailySched"

#define LONG_INSULIN @"Long"
#define RAPID_INSULIN @"Rapid"

#define INSULIN_CALC_FORMULA 0
#define INSULIN_CALC_SCALE 1

#define GLUCOSE_UNIT_MMOL 1
#define mmol2mgdl 0.0555600f;


-(void) quickNPH;
-(void) quickMDI;
-(void) quickPump;
-(BOOL) saveSettings;
-(void) sortScale;
-(void) sortIOBFactor;
-(void) sortSchedule;
-(void) sortExerciseType;
-(BOOL) deleteSchedule:(NSUInteger)row;
-(void) scheduleInsulinNotification:(InsulinBrand *)insulinBrand fromDate:(NSDate *)fromDate;
-(void)cancelNotificationsOfType:(NSString *)notifType;
-(void) setView:(id)view toColorScheme:(ColorScheme *)colorScheme;
-(BOOL) addSchedule:(DailySchedule *)newSched;
-(NSNumber *)glucoseConvert:(NSNumber *)theValue toExternal:(BOOL)toExternal;
-(NSNumber *) roundTheNumber:(NSNumber *)theValue accuracy:(NSNumber *)accuracy;
-(NSString *) formatToRoundedString:(NSNumber *)theValue accuracy:(NSNumber *)accuracy;
-(NSString *) glucoseLiteral;
-(void) loadPrescribedInsulin;
-(void) importCSV;
-(void) loadAllCoreDataArrays;
-(int)  refreshLogCount;
-(void) showBuyFullVersion:(UIViewController *)theVC;
-(void) databaseErrorAlert:(NSError *)error more:(NSString *)more;

@end
