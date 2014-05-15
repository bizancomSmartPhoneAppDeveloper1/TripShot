//
//  CustomAnnotationView.m
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/14.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomAnnotation.h"
#import "InfoPlace.h"
#import "NSObject+Extension.h"

@interface CustomAnnotationView ()
@property (nonatomic, assign) BOOL isLayouted;
@property (strong, nonatomic) InfoPlace *infoPlace;
@end

@implementation CustomAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _isLayouted = NO;
        _tmpCalloutView = nil;
        _infoPlace = nil;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    @synchronized(self)
    {
        @autoreleasepool
        {
            if(self.isLayouted == NO)
            {
                self.isLayouted = YES;
                
                //オリジナルコールアウト
                self.infoPlace = [InfoPlace instanceWithAnnotation:self.annotation];
                
                CGRect pinRect = [self convertRect:self.bounds toView:self.tmpCalloutView];
                CGFloat px = CGRectGetMidX(pinRect);
                CGFloat py = CGRectGetMinY(pinRect) - [self division:CGRectGetHeight(self.infoPlace.view.bounds) by:2.0];
                
                //ピンの画像によっては微調整
                px = px - 8.0f;
                py = py - 3.0f;
                
                [self.infoPlace.view setCenter:CGPointMake(px, py)];
                
                [self asyncAfterDelay:0.0f block:^{
                    
                    //iOS7系の場合はアニメーション
                    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
                    {
                        [self set_popup_animation:self.infoPlace.view];
                    }
                    
                    [self.tmpCalloutView addSubview:self.infoPlace.view];
                }];
            }
        }
    }
}

- (void)didAddSubview:(UIView *)subview
{
    //コールアウトへの参照を保持
    //コールアウト上のSubViewをクリア
    if([NSStringFromClass([subview class]) isEqualToString:@"UICalloutView"] ||
       [NSStringFromClass([subview class]) isEqualToString:@"UIView"])
    {
        self.tmpCalloutView = subview;
        for(UIView *sv in [self.tmpCalloutView subviews])
        {
            [sv removeFromSuperview];
        }
        self.tmpCalloutView.backgroundColor = [UIColor clearColor];
        self.tmpCalloutView.clipsToBounds = NO;
        self.isLayouted = NO;
    }
}

- (CGRect)infoWindowFrame
{
    return [[self superview] convertRect:self.infoPlace.view.frame fromView:self.tmpCalloutView];;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
