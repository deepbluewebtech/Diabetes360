//
//  ColorTransformer.m
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorTransformer.h"

@implementation ColorTransformer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
    
	NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:value];
	return colorAsData;
}


- (id)reverseTransformedValue:(id)value {
    
	UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:value];
	return color;
}


@end
