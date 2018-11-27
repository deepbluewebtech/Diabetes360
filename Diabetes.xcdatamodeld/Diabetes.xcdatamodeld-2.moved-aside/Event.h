//
//  Event.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Event :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * suggInsulin;
@property (nonatomic, retain) NSNumber * bloodSugar;
@property (nonatomic, retain) NSNumber * totalCarb;
@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSNumber * actInsulin;

@end



