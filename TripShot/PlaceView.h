//
//  PlaceView.h
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>

//RGMカラー
#define MYCOLOR(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:a]

//角丸計算用
#define RADIANS(D) (D * M_PI / 180)


//くちばしの向き
typedef enum
{
    SFBallonDirectionNone = 0,
    SFBallonDirectionTop,
    SFBallonDirectionLeft,
    SFBallonDirectionRight,
    SFBallonDirectionBottom
} SFBallonDirection;

@interface PlaceView : UIView

//プロパティ
@property (strong, nonatomic) UIColor *baseColor;       //背景色
@property (strong, nonatomic) UIColor *strokeColor;     //枠線の色
@property (nonatomic, assign) CGFloat ballonRadius;     //角丸の半径
@property (nonatomic, assign) CGFloat ballonStroke;     //枠線の幅
@property (nonatomic, assign) CGFloat tailWidth;        //しっぽの幅
@property (nonatomic, assign) CGFloat tailHeight;       //しっぽの高さ
@property (nonatomic, assign) SFBallonDirection direction;    //しっぽの向き

+(id)instance;

//最小サイズ
-(CGSize)minSize;

//描画領域サイズ
-(CGRect)innerRect;

//余白
-(UIEdgeInsets)padding;

@end
