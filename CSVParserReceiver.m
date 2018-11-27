//
//  EntryReceiver.m
//  CSVImporter
//
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "CSVParserReceiver.h"

@implementation CSVParserReceiver

@synthesize outputArray;
@synthesize dateFmt;

- (id)init {
    
	self = [super init];
	if (self) {

        outputArray = [[NSMutableArray alloc] initWithCapacity:300];  // this is the max size on an export
        dateFmt = [[NSDateFormatter alloc] init];
	
    }
    
	return self;
}

- (void)receiveRecord:(NSDictionary *)aRecord {

    NSMutableDictionary *mutableRecord = [[NSMutableDictionary alloc] initWithDictionary:aRecord];
    [dateFmt setDateFormat:@"yyyy-MM-dd HH:mm"];
    //NSLog(@"%@",dateFmt.dateFormat);
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",[aRecord valueForKey:@"date"],[aRecord valueForKey:@"time"]];
    NSDate *dateTime = [dateFmt dateFromString:dateString];

    [mutableRecord removeObjectForKey:@"date"];
    [mutableRecord setObject:dateTime forKey:@"date"];
    //NSLog(@"mutable record=%@",mutableRecord);
    [outputArray addObject:mutableRecord];
    
}

@end
