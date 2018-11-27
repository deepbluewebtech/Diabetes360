//
//  KetoneValue.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface KetoneValue : NSManagedObject {
@private
}
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * sortOrder;
@property (nonatomic, strong) NSNumber * waterAlert;
@property (nonatomic, strong) NSSet *Events;
@end

@interface KetoneValue (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
@end
