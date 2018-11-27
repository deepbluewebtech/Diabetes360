//
//  InsulinFactor.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InsulinFactor : NSManagedObject {
@private
}
@property (nonatomic, strong) NSDate * timeOfDayBegin;
@property (nonatomic, strong) NSString * factorId;
@property (nonatomic, strong) NSNumber * factorValue;

@end
