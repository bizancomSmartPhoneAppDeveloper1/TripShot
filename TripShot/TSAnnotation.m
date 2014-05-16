//
//  TSAnnotation.m
//  TripShot
//
//  Created by bizan.com.mac05 on 2014/05/15.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "TSAnnotation.h"

@implementation TSAnnotation

//イニシャライザ
- (id) initWithCoordinate:(CLLocationCoordinate2D)pinCoordinate title:(NSString *)pinTitle subtitle:(NSString *)pinSubtitle idnumb:(int)pinid{
    //座標
    _coordinate = pinCoordinate;
    _title = pinTitle;
    _subtitle = pinSubtitle;
    _idnumb = pinid;
    
    return 0;
}



@end
