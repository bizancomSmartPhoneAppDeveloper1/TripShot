//
//  CustomAnnotation.m
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "CustomAnnotation.h"
#import "NSObject+Extension.h"

@implementation CustomAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if(self)
    {
        self.coordinate = coordinate;
        self.annotationTitle = @"Sample\nLocation";
        self.annotationSubtitle = @"";
        self.cameraName = @"image1.jpg";
        self.mainColor = MYCOLOR(0xFF9966, 1.0);
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}


@end
