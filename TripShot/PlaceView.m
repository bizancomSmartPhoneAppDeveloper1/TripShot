//
//  PlaceView.m
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PlaceView.h"
#import "NSObject+Extension.h"

@interface PlaceView()

@property (nonatomic, assign) BOOL isLayouted;
@end

@implementation PlaceView

+(id)instance
{
    return [[[self class] alloc] init];
}

- (void)awakeFromNib
{
    self.baseColor = [UIColor whiteColor];
    self.strokeColor = [UIColor darkGrayColor];
    self.ballonRadius = 5.0f;
    self.ballonStroke = 2.0f;
    self.tailWidth = 20.0f;
    self.tailHeight = 10.0f;
    self.direction = SFBallonDirectionBottom;
    self.isLayouted = NO;
    [self setupLayouted];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.baseColor = [UIColor whiteColor];
        self.strokeColor = [UIColor darkGrayColor];
        self.ballonRadius = 5.0f;
        self.ballonStroke = 2.0f;
        self.tailWidth = 20.0f;
        self.tailHeight = 10.0f;
        self.direction = SFBallonDirectionBottom;
        self.isLayouted = NO;
        [self setupLayouted];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.baseColor = [UIColor whiteColor];
        self.strokeColor = [UIColor darkGrayColor];
        self.ballonRadius = 5.0f;
        self.ballonStroke = 2.0f;
        self.tailWidth = 20.0f;
        self.tailHeight = 10.0f;
        self.direction = SFBallonDirectionBottom;
        self.isLayouted = NO;
        [self setupLayouted];
    }
    return self;
}

- (void)setupLayouted
{
    if(_isLayouted == NO)
    {
        _isLayouted = YES;
        
        //背景透過
        self.backgroundColor = [UIColor clearColor];
    }
}

//最小サイズ
- (CGSize)minSize
{
    CGFloat w = self.ballonStroke*2 + self.ballonRadius*2;
    CGFloat h = self.ballonStroke*2 + self.ballonRadius*2;
    if(self.direction == SFBallonDirectionLeft || self.direction == SFBallonDirectionRight)
    {
        h += self.tailWidth;
        w += self.tailHeight;
    }
    else if(self.direction == SFBallonDirectionTop || self.direction == SFBallonDirectionBottom)
    {
        w += self.tailWidth;
        h += self.tailHeight;
    }
    return CGSizeMake(w, h);
}

//描画領域サイズ
-(CGRect)innerRect
{
    CGRect innerRect = CGRectZero;
    CGFloat mrg = self.ballonStroke;
    innerRect.origin.x = self.bounds.origin.x + mrg;
    innerRect.origin.y = self.bounds.origin.y + mrg;
    innerRect.size.width = self.bounds.size.width - mrg*2;
    innerRect.size.height = self.bounds.size.height - mrg*2;
    return innerRect;
}

//余白
-(UIEdgeInsets)padding
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if(_direction == SFBallonDirectionLeft)
    {
        insets = UIEdgeInsetsMake(self.ballonStroke, self.ballonStroke+self.tailHeight, self.ballonStroke, self.ballonStroke);
    }
    else if(_direction == SFBallonDirectionRight)
    {
        insets = UIEdgeInsetsMake(self.ballonStroke, self.ballonStroke, self.ballonStroke, self.ballonStroke+self.tailHeight);
    }
    else if(_direction == SFBallonDirectionTop)
    {
        insets = UIEdgeInsetsMake(self.ballonStroke+self.tailHeight, self.ballonStroke, self.ballonStroke, self.ballonStroke);
    }
    else if(_direction == SFBallonDirectionBottom)
    {
        insets = UIEdgeInsetsMake(self.ballonStroke, self.ballonStroke, self.ballonStroke+self.tailHeight, self.ballonStroke);
    }
    
    return insets;
}

- (void)drawRect:(CGRect)rect
{
    @autoreleasepool
    {
        if(rect.size.width >= [self minSize].width &&
           rect.size.height >= [self minSize].height)
        {
            //吹き出し領域からマージンを計算した描画(テキストと添付)計算
            CGRect innerRect = [self innerRect];
            
            //描画コンテキスト
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetAllowsAntialiasing(ctx, true);
            CGContextSetShouldAntialias(ctx, true);
            
            //キャンパス初期化
            CGContextClearRect(ctx, rect);
            CGContextSetStrokeColorWithColor(ctx, [UIColor clearColor].CGColor);
            CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
            CGContextSetShadowWithColor(ctx, CGSizeZero, 0.0, NULL);
            CGContextDrawPath(ctx, kCGPathFillStroke);
            
            //影
            //            CGContextSaveGState(ctx);
            //            [self ContextSetBallonPath:ctx rect:innerRect];
            //            CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
            //            CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 1.0), 5.0, MYCOLOR(0x130f30, 0.75).CGColor);
            //            CGContextFillPath(ctx);
            //            CGContextRestoreGState(ctx);
            
            //グラデーション描画
            CGContextSaveGState(ctx);
            [self ContextSetBallonPath:ctx rect:innerRect];
            CGContextClip(ctx);
            [self ContextGradientDraw:ctx rect:innerRect];
            CGContextRestoreGState(ctx);
            
            //枠線
            CGContextSaveGState(ctx);
            [self ContextSetBallonPath:ctx rect:innerRect];
            CGContextSetLineWidth(ctx, self.ballonStroke);
            CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
            CGContextStrokePath(ctx);
            CGContextRestoreGState(ctx);
        }
    }
}

- (void)ContextSetBallonPath:(CGContextRef)ctx rect:(CGRect)rect
{
    CGFloat rad = self.ballonRadius;        //角の半径
    CGFloat aw = self.tailWidth;            //くちばしの底辺の幅
    CGFloat ah = self.tailHeight;           //くちばしの角までの高さ
    CGFloat lx = CGRectGetMinX(rect);       //X軸左
    CGFloat cx = CGRectGetMidX(rect);       //X軸中
    CGFloat rx = CGRectGetMaxX(rect);       //X軸右
    CGFloat ty = CGRectGetMinY(rect);       //Y軸上
    CGFloat cy = CGRectGetMidY(rect);       //Y軸中
    CGFloat by = CGRectGetMaxY(rect);       //Y軸下
    
    //バルーンの向きによってサイズを調整
    if(_direction == SFBallonDirectionLeft)
    {
        lx += ah;
    }
    else if(_direction == SFBallonDirectionRight)
    {
        rx -= ah;
    }
    else if(_direction == SFBallonDirectionTop)
    {
        ty += ah;
    }
    else if(_direction == SFBallonDirectionBottom)
    {
        by -= ah;
    }
    
    CGContextBeginPath(ctx);
    if(_direction == SFBallonDirectionLeft)
    {
        CGContextMoveToPoint(ctx, lx, ty+rad); //開始点
        CGContextAddArc(ctx, lx+rad, ty+rad, rad, RADIANS(180), RADIANS(270), 0);   //左上のカーブ
        CGContextAddArc(ctx, rx-rad, ty+rad, rad, RADIANS(270), RADIANS(360), 0);   //右上のカーブ
        CGContextAddArc(ctx, rx-rad, by-rad, rad, RADIANS(0), RADIANS(90), 0);      //右下のカーブ
        CGContextAddArc(ctx, lx+rad, by-rad, rad, RADIANS(90), RADIANS(180), 0);    //左下のカーブ
        CGContextAddLineToPoint(ctx, lx, cy+[self division:aw by:2]);
        CGContextAddLineToPoint(ctx, lx-ah, cy);
        CGContextAddLineToPoint(ctx, lx, cy-[self division:aw by:2]);
    }
    else if(_direction == SFBallonDirectionRight)
    {
        CGContextMoveToPoint(ctx, rx, by-rad); //開始点
        CGContextAddArc(ctx, rx-rad, by-rad, rad, RADIANS(0), RADIANS(90), 0);      //右下のカーブ
        CGContextAddArc(ctx, lx+rad, by-rad, rad, RADIANS(90), RADIANS(180), 0);    //左下のカーブ
        CGContextAddArc(ctx, lx+rad, ty+rad, rad, RADIANS(180), RADIANS(270), 0);   //左上のカーブ
        CGContextAddArc(ctx, rx-rad, ty+rad, rad, RADIANS(270), RADIANS(360), 0);   //右上のカーブ
        CGContextAddLineToPoint(ctx, rx, cy-[self division:aw by:2]);
        CGContextAddLineToPoint(ctx, rx+ah, cy);
        CGContextAddLineToPoint(ctx, rx, cy+[self division:aw by:2]);
    }
    else if(_direction == SFBallonDirectionTop)
    {
        CGContextMoveToPoint(ctx, rx-rad, ty); //開始点
        CGContextAddArc(ctx, rx-rad, ty+rad, rad, RADIANS(270), RADIANS(360), 0);   //右上のカーブ
        CGContextAddArc(ctx, rx-rad, by-rad, rad, RADIANS(0), RADIANS(90), 0);      //右下のカーブ
        CGContextAddArc(ctx, lx+rad, by-rad, rad, RADIANS(90), RADIANS(180), 0);    //左下のカーブ
        CGContextAddArc(ctx, lx+rad, ty+rad, rad, RADIANS(180), RADIANS(270), 0);   //左上のカーブ
        CGContextAddLineToPoint(ctx, cx-[self division:aw by:2], ty);
        CGContextAddLineToPoint(ctx, cx, ty-ah);
        CGContextAddLineToPoint(ctx, cx+[self division:aw by:2], ty);
    }
    else if(_direction == SFBallonDirectionBottom)
    {
        CGContextMoveToPoint(ctx, lx+rad, by); //開始点
        CGContextAddArc(ctx, lx+rad, by-rad, rad, RADIANS(90), RADIANS(180), 0);    //左下のカーブ
        CGContextAddArc(ctx, lx+rad, ty+rad, rad, RADIANS(180), RADIANS(270), 0);   //左上のカーブ
        CGContextAddArc(ctx, rx-rad, ty+rad, rad, RADIANS(270), RADIANS(360), 0);   //右上のカーブ
        CGContextAddArc(ctx, rx-rad, by-rad, rad, RADIANS(0), RADIANS(90), 0);      //右下のカーブ
        CGContextAddLineToPoint(ctx, cx+[self division:aw by:2], by);
        CGContextAddLineToPoint(ctx, cx, by+ah);
        CGContextAddLineToPoint(ctx, cx-[self division:aw by:2], by);
    }
    else
    {
        CGContextMoveToPoint(ctx, rx-rad, ty); //開始点
        CGContextAddArc(ctx, rx-rad, ty+rad, rad, RADIANS(270), RADIANS(360), 0);   //右上のカーブ
        CGContextAddArc(ctx, rx-rad, by-rad, rad, RADIANS(0), RADIANS(90), 0);      //右下のカーブ
        CGContextAddArc(ctx, lx+rad, by-rad, rad, RADIANS(90), RADIANS(180), 0);    //左下のカーブ
        CGContextAddArc(ctx, lx+rad, ty+rad, rad, RADIANS(180), RADIANS(270), 0);   //左上のカーブ
    }
    CGContextClosePath(ctx);
}


//グラデーション描画
- (void)ContextGradientDraw:(CGContextRef)ctx rect:(CGRect)rect
{
    @autoreleasepool
    {
        //グラデーション開始終了ポイント
        CGRect frame = rect;
        CGPoint startPoint = frame.origin;
        CGPoint endPoint = CGPointMake(frame.origin.x, frame.origin.y + frame.size.height);
        
        //ロケーション
        CGFloat locations[4] = {0.0, 0.2, 0.4, 1.0};
        
        /* 吹き出し上部に白色スモークをつける場合
         CFArrayRef colors = (__bridge CFArrayRef) [NSArray arrayWithObjects:
         (id)[UIColor whiteColor].CGColor,
         (id)self.baseColor.CGColor,
         (id)self.baseColor.CGColor,
         (id)self.baseColor.CGColor,
         nil];
         */
        //ベタ塗りの場合
        CFArrayRef colors = (__bridge CFArrayRef) [NSArray arrayWithObjects:
                                                   (id)self.baseColor.CGColor,
                                                   (id)self.baseColor.CGColor,
                                                   (id)self.baseColor.CGColor,
                                                   (id)self.baseColor.CGColor,
                                                   nil];
        
        //グラデーション生成
        CGColorSpaceRef colorSpc = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpc, colors, locations);
        
        //グラデーション描画
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
        
        //解放
        CGColorSpaceRelease(colorSpc);
        CGGradientRelease(gradient);
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
