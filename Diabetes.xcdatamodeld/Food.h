//
//  Food.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 2/18/11.
//  Copyright 2011 Deep Blue Web Technology. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Event;

@interface Food :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * NDB;
@property (nonatomic, retain) NSDecimalNumber * Carb;
@property (nonatomic, retain) NSString * ShortDesc;
@property (nonatomic, retain) Event * event;

@end



