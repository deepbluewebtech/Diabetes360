//
//  IOBFactor.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IOBFactor : NSManagedObject

@property (nonatomic, strong) NSNumber * hours;
@property (nonatomic, strong) NSNumber * percentReduce;

@end
