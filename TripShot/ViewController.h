//
//  ViewController.h
//  TripShot
//
//  Created by YuzuruIshii on 2014/05/09.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MapView.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *userLocationBtn;

@property NSUserDefaults *mydefault;
@property NSTimer* timer;
@property BOOL isChasing;

- (IBAction)tapUserLocationBtn:(UIButton *)sender;

@end
