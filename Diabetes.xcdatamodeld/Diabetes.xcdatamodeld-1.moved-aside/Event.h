//
//  Event.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Event :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * actUnits;
@property (nonatomic, retain) NSNumber * suggUnits;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * bloodSugar;
@property (nonatomic, retain) NSNumber * totalCarb;
@property (nonatomic, retain) NSNumber * type;

@end



