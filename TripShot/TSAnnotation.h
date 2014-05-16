//
//  TSAnnotation.h
//  TripShot
//
//  Created by bizan.com.mac05 on 2014/05/15.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>


@interface TSAnnotation : NSObject<MKAnnotation>

//MKAnnotationプロトコルにしたがって宣言する
@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *subtitle;
@property(nonatomic) int idnumb;

//カスタムイニシャライザ
- (id) initWithCoordinate:(CLLocationCoordinate2D)pinCoordinate title:(NSString *)pinTitle subtitle:(NSString *)pinSubtitle idnumb:(int)pinid;

@end
