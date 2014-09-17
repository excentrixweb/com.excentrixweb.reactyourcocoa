//
//  UIView+AnimateHidden.h
//  AllAtOnce
//
//  Created by Tami Wright on 07/01/14.
//  Copyright (c) 2014 Excentrix Web. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AnimateHidden)
- (void)setHiddenAnimated:(BOOL)hide;
- (void)setHiddenAnimated:(BOOL)hide
      withCompletionBlock:(void (^)(void))completion;
@end
