//
//  InsulinBrand.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DailySchedule, Event;

@interface InsulinBrand : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * doseType;
@property (nonatomic, strong) NSString * classification;
@property (nonatomic, strong) NSNumber * mixDenominator;
@property (nonatomic, strong) NSNumber * doseReminder;
@property (nonatomic, strong) NSString * genericName;
@property (nonatomic, strong) NSNumber * doseUnits;
@property (nonatomic, strong) NSNumber * durationLow;
@property (nonatomic, strong) NSNumber * peakLow;
@property (nonatomic, strong) NSNumber * onsetLow;
@property (nonatomic, strong) NSNumber * timing;
@property (nonatomic, strong) NSNumber * onsetHigh;
@property (nonatomic, strong) NSNumber * durationHigh;
@property (nonatomic, strong) NSNumber * doseInterval;
@property (nonatomic, strong) NSNumber * mixNumerator;
@property (nonatomic, strong) id profileImage;
@property (nonatomic, strong) NSString * brandName;
@property (nonatomic, strong) NSNumber * peakHigh;
@property (nonatomic, strong) NSNumber * prescribed;
@property (nonatomic, strong) NSSet *Events;
@property (nonatomic, strong) NSSet *DailySchedules;
@end

@interface InsulinBrand (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
- (void)addDailySchedulesObject:(DailySchedule *)value;
- (void)removeDailySchedulesObject:(DailySchedule *)value;
- (void)addDailySchedules:(NSSet *)values;
- (void)removeDailySchedules:(NSSet *)values;
@end
