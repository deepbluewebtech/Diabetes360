//
//  ColorTransformer.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorTransformer : NSValueTransformer {
    
}

+ (BOOL)allowsReverseTransformation;

+ (Class)transformedValueClass;

- (id)transformedValue:(id)value;

- (id)reverseTransformedValue:(id)value;


@end
