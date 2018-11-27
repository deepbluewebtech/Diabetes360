//
//  ColorScheme.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 7/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ColorScheme : NSManagedObject {
@private
}
@property (nonatomic, strong) id tableCellAlternate;
@property (nonatomic, strong) id textHightlight;
@property (nonatomic, strong) NSNumber * active;
@property (nonatomic, strong) id viewBackground;
@property (nonatomic, strong) id textNormal;
@property (nonatomic, strong) id tableCell;
@property (nonatomic, strong) id buttonBackground;
@property (nonatomic, strong) id buttonTitle;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * editable;

@end
