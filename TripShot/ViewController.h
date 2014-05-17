//
//  ViewController.h
//  TripShot
//
//  Created by YuzuruIshii on 2014/05/09.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MapView *mapView;

@property NSUserDefaults *mydefault;
@property NSTimer* timer;

@end
