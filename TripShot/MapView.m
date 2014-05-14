//
//  MapView.m
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/14.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "MapView.h"
#import "NSObject+Extension.h"

@implementation MapView

- (BOOL)isCalloutHitPoint:(CGPoint)mapPoint
{
    @autoreleasepool
    {
        if(self.currentAnnotationView == nil)
        {
            return NO;
        }
        else
        {
            //吹き出しのマップ位置を取得
            CGRect infoRect = [self.currentAnnotationView.superview convertRect:[self.currentAnnotationView infoPlaceFrame] toView:self];
            
            //吹き出しタップ判定
            if(CGRectContainsPoint(infoRect, mapPoint))
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }
}

BOOL hasCalloutHit = NO;
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    @synchronized(self)
    {
        if(hasCalloutHit == NO)
        {
            hasCalloutHit = [self isCalloutHitPoint:point];
            if(hasCalloutHit == YES)
            {
                [self.delegate mapView:self annotationView:self.currentAnnotationView calloutAccessoryControlTapped:nil];
                [self asyncAfterDelay:0.1 block:^{
                    hasCalloutHit = NO;
                }];
                return nil;
            }
            else
            {
                return [super hitTest:point withEvent:event];
            }
        }
        else
        {
            return nil;
        }
    }
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
