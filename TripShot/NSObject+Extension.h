//
//  NSObject+Extension.h
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MYCOLOR(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:a]

@interface NSObject (Extension)

+ (UIColor *)hex:(NSString *)hex alpha:(CGFloat)a;
- (double)division:(double)numberA by:(double)numberB;
- (void)set_popup_animation:(UIView *)view;
- (void)asyncMain:(void(^)(void))block;
- (void)asyncAfterDelay:(NSTimeInterval)delay block:(void(^)(void))block;
- (void)asyncAfterDate:(NSDate *)date block:(void(^)(void))block;

@end
