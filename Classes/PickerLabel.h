//
//  PickerLabel.h
//  Diabetes
//
//  Created by Joseph DiMaggio on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerLabel : UILabel

@property (readwrite, strong) UIView *inputView;
@property (readwrite, strong) UIView *inputAccessoryView;
@property (assign) BOOL canBecomeFirstResponder;

@end
