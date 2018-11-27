//
//  FoodItem.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventFood, FoodWeight;

@interface FoodItem : NSManagedObject {
@private
}
@property (nonatomic, strong) NSString * shortDesc;
@property (nonatomic, strong) NSNumber * favorite;
@property (nonatomic, strong) NSNumber * ndbNumber;
@property (nonatomic, strong) NSNumber * carb;
@property (nonatomic, strong) NSNumber * usedCount;
@property (nonatomic, strong) NSDate * lastUsed;
@property (nonatomic, strong) NSSet *EventFoods;
@property (nonatomic, strong) NSSet *FoodWeights;
@end

@interface FoodItem (CoreDataGeneratedAccessors)

- (void)addEventFoodsObject:(EventFood *)value;
- (void)removeEventFoodsObject:(EventFood *)value;
- (void)addEventFoods:(NSSet *)values;
- (void)removeEventFoods:(NSSet *)values;
- (void)addFoodWeightsObject:(FoodWeight *)value;
- (void)removeFoodWeightsObject:(FoodWeight *)value;
- (void)addFoodWeights:(NSSet *)values;
- (void)removeFoodWeights:(NSSet *)values;
@end
