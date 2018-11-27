//
//  Event.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 11/15/11.
//  Copyright (c) 2011 Deep Blue Web Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DailySchedule, EventFood, InsulinBrand, KetoneValue, Site;

@interface Event : NSManagedObject

@property (nonatomic, strong) NSNumber * iobFactor;
@property (nonatomic, strong) NSNumber * exerciseFactor;
@property (nonatomic, strong) NSNumber * lastRapidDose;
@property (nonatomic, strong) NSString * fmtDate;
@property (nonatomic, strong) NSString * fmtMonth;
@property (nonatomic, strong) NSNumber * isBeforeSchedule;
@property (nonatomic, strong) NSDate * eventDate;
@property (nonatomic, strong) NSNumber * corrFactor;
@property (nonatomic, strong) NSNumber * insulinAmt;
@property (nonatomic, strong) NSString * exerciseType;
@property (nonatomic, strong) NSNumber * isDummy;
@property (nonatomic, strong) NSNumber * exerciseMinutes;
@property (nonatomic, strong) NSNumber * calcType;
@property (nonatomic, strong) NSString * note;
@property (nonatomic, strong) NSNumber * glucose;
@property (nonatomic, strong) NSNumber * targetRate;
@property (nonatomic, strong) NSDate * lastRapidEventDate;
@property (nonatomic, strong) NSNumber * disableIOB;
@property (nonatomic, strong) NSNumber * roundingAccuracy;
@property (nonatomic, strong) NSNumber * totalCarb;
@property (nonatomic, strong) NSNumber * carbFactor;
@property (nonatomic, strong) NSNumber * insulinAmtIsManual;
@property (nonatomic, strong) Site *Site;
@property (nonatomic, strong) InsulinBrand *InsulinBrand;
@property (nonatomic, strong) NSSet *EventFoods;
@property (nonatomic, strong) DailySchedule *DailySchedule;
@property (nonatomic, strong) KetoneValue *KetoneValue;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addEventFoodsObject:(EventFood *)value;
- (void)removeEventFoodsObject:(EventFood *)value;
- (void)addEventFoods:(NSSet *)values;
- (void)removeEventFoods:(NSSet *)values;
@end
