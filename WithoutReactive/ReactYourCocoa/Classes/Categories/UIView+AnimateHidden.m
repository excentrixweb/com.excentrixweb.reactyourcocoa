//
//  UIView+AnimateHidden.m
//  AllAtOnce
//
//  Created by Tami Wright on 07/01/14.
//  Copyright (c) 2014 Excentrix Web. All rights reserved.
//

#import "UIView+AnimateHidden.h"

@implementation UIView (AnimateHidden)
- (void)setHiddenAnimated:(BOOL)hide
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
         if (hide)
             self.alpha=0;
         else
         {
             self.hidden= NO;
             self.alpha=1;
         }
     }
                     completion:^(BOOL b)
     {
         if (hide)
             self.hidden= YES;
     }
     ];
}

- (void)setHiddenAnimated:(BOOL)hide
               withCompletionBlock:(void (^)(void))completion
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
         if (hide)
             self.alpha=0;
         else
         {
             self.hidden= NO;
             self.alpha=1;
         }
     }
                     completion:^(BOOL b)
     {
         if (hide)
             self.hidden= YES;
         completion();
     }
     ];
}
@end
