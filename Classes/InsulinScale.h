//
//  InsulinScale.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 8/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InsulinScale : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * units;
@property (nonatomic, strong) NSNumber * rangeMin;

@end
