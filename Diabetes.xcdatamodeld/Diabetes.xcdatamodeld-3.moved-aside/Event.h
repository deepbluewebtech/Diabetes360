//
//  Event.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 2/18/11.
//  Copyright 2011 Deep Blue Web Technology. All rights reserved.
//

#import <CoreData/CoreData.h>

@class FoodItem;

@interface Event :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * bloodSugar;
@property (nonatomic, retain) NSNumber * totalCarb;
@property (nonatomic, retain) NSNumber * suggInsulin;
@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSNumber * actInsulin;
@property (nonatomic, retain) NSSet* fooditems;

@end


@interface Event (CoreDataGeneratedAccessors)
- (void)addFooditemsObject:(FoodItem *)value;
- (void)removeFooditemsObject:(FoodItem *)value;
- (void)addFooditems:(NSSet *)value;
- (void)removeFooditems:(NSSet *)value;

@end

