//
//  FoodWeight.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodItem;

@interface FoodWeight : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * favorite;
@property (nonatomic, strong) NSNumber * weight;
@property (nonatomic, strong) NSString * measure;
@property (nonatomic, strong) FoodItem * FoodItem;

@end
