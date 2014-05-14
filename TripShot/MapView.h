//
//  MapView.h
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/14.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CustomAnnotationView.h"

@interface MapView : MKMapView

@property (strong, nonatomic) CustomAnnotationView *currentAnnotationView;

@end
