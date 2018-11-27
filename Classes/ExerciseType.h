//
//  ExerciseType.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 10/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExerciseType : NSManagedObject

@property (nonatomic, strong) NSNumber * factorValue;
@property (nonatomic, strong) NSString * typeName;

@end
