//
//  CustomAnnotationView.h
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/14.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotationView : MKPinAnnotationView

@property (strong, nonatomic) UIView *tmpCalloutView;

- (CGRect)infoPlaceFrame;

@end
