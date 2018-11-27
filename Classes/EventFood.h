//
//  EventFood.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, FoodItem;

@interface EventFood : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * foodWeight;
@property (nonatomic, strong) NSNumber * foodCarb;
@property (nonatomic, strong) NSNumber * servingQty;
@property (nonatomic, strong) NSString * foodMeasure;
@property (nonatomic, strong) FoodItem * FoodItem;
@property (nonatomic, strong) Event * Event;

@end
