//
//  Site.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 11/16/11.
//  Copyright (c) 2011 Deep Blue Web Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Site : NSManagedObject

@property (nonatomic, strong) NSNumber * active;
@property (nonatomic, strong) NSNumber * useWithPump;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * useCount;
@property (nonatomic, strong) NSSet *Events;
@end

@interface Site (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
@end
