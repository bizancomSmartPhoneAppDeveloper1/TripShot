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
{
    CLLocationCoordinate2D coodinate;
    NSString *annotationTitle;
    NSString *annotationSubtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *annotationTitle;
@property (nonatomic, retain) NSString *annotationSubtitle;
- (id)initWithLocationCoordinate:(CLLocationCoordinate2D) _coordinate
                           title:(NSString *)_annotationTitle subtitle:(NSString *)_annotationannSubtitle;
- (NSString *)title;
- (NSString *)subtitle;

@end
