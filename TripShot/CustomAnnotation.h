//
//  CustomAnnotation.h
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface CustomAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *annotationTitle;
@property (nonatomic, copy) NSString *annotationSubtitle;
@property (nonatomic, copy) NSString *cameraName;
@property (nonatomic, copy) UIColor *mainColor;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
