//
//  NSObject+Extension.m
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)

//16進を表す文字列をUIColorに変換する
+(UIColor *)hex:(NSString *)hex alpha:(CGFloat)a
{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


#pragma mark -
#pragma mark 計算用

//割り算(分子/分母)
- (double)division:(double)numberA by:(double)numberB
{
    double result = 0.0f;
    @autoreleasepool
    {
        NSDecimalNumber *nume = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:numberA] decimalValue]];
        NSDecimalNumber *beno = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:numberB] decimalValue]];
        result = [[nume decimalNumberByDividingBy:beno] doubleValue];
    }
    return result;
}


#pragma mark -
#pragma mark アニメーション用

//ポップアップアニメーションを付ける
-(void)set_popup_animation:(UIView *)view
{
    @autoreleasepool
    {
        //アニメーションインターバル
        NSTimeInterval interval = 0.3f;
        
        //アニメーション配列
        NSMutableArray *anims = [NSMutableArray array];
        
        //スケールアニメーション
        CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
        CATransform3D scale2 = CATransform3DMakeScale(1.0, 1.0, 1);
        CATransform3D scale3 = CATransform3DMakeScale(0.95, 0.95, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:scale1],
                                [NSValue valueWithCATransform3D:scale2],
                                [NSValue valueWithCATransform3D:scale3],
                                [NSValue valueWithCATransform3D:scale4],
                                nil];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:0.85],
                               [NSNumber numberWithFloat:1.0],
                               nil];
        
        scaleAnim.fillMode = kCAFillModeForwards;
        scaleAnim.removedOnCompletion = NO;
        scaleAnim.duration = interval;
        [scaleAnim setValues:frameValues];
        [scaleAnim setKeyTimes:frameTimes];
        [anims addObject:scaleAnim];
        
        //透過アニメーション
        CABasicAnimation *alphaAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        alphaAnim.duration = interval;
        alphaAnim.fromValue = [NSNumber numberWithFloat:0.5f];
        alphaAnim.toValue = [NSNumber numberWithFloat:1.0f];
        [anims addObject:alphaAnim];
        
        //アニメーショングループ
        CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
        groupAnimation.duration=interval;
        groupAnimation.animations = anims;
        
        //アニメーション設定
        [view.layer addAnimation:groupAnimation forKey:@"popup"];
    }
}


#pragma mark -
#pragma mark Dispatch

- (void)asyncGlobal:(void(^)(void))block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, block);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    });
    dispatch_group_wait(group, DISPATCH_TIME_NOW);
}

- (void)asyncMain:(void(^)(void))block
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    __block dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, block);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    });
    dispatch_group_wait(group, DISPATCH_TIME_NOW);
}

- (void)asyncAfterDelay:(NSTimeInterval)delay block:(void(^)(void))block
{
    [self asyncAfterDate:[NSDate dateWithTimeIntervalSinceNow:delay] block:block];
}

- (void)asyncAfterDate:(NSDate *)date block:(void(^)(void))block
{
    dispatch_time_t delta = getDispatchTimeByDate(date);
	dispatch_after(delta, dispatch_get_main_queue(), block);
}

dispatch_time_t getDispatchTimeByDate(NSDate *date)
{
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    return milestone;
}

@end
