//
//  CustomAnnotation.m
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize coordinate;
@synthesize annotationTitle;
@synthesize annotationSubtitle;

- (NSString *)title {
    return annotationTitle;
}

- (NSString *)subtitle {
    return annotationSubtitle;
}

//取得した位置情報を代入することにより初期化する関数
- (id)initWithLocationCoordinate:(CLLocationCoordinate2D) _coordinate
                           title:(NSString *)_annotationTitle subtitle:(NSString *)_annotationSubtitle
{
    self.coordinate = _coordinate; //取得した位置情報をCLLocationCoordinate2Dクラスのcoordinateプロパティへ代入する
    self.annotationTitle = _annotationTitle;
    self.annotationSubtitle = _annotationSubtitle;
    return self;
}

@end
