//
//  DailySchedule.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 9/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, InsulinBrand;

@interface DailySchedule : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * reminder;
@property (nonatomic, strong) NSDate * beginTime;
@property (nonatomic, strong) NSDate * endTime;
@property (nonatomic, strong) NSNumber * insulinDose;
@property (nonatomic, strong) NSNumber * anyTime;
@property (nonatomic, strong) NSNumber * complexCarb;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * carbToIngest;
@property (nonatomic, strong) NSSet *Events;
@property (nonatomic, strong) InsulinBrand *InsulinBrand;
@end

@interface DailySchedule (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
@end
