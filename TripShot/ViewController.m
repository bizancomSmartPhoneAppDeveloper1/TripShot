//
//  ViewController.m
//  TripShot
//
//  Created by bizan.com.mac02 on 2014/05/09.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//位置情報が通知された時
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //最新の位置情報を取り出す
    CLLocation *location = [locations lastObject];
    [self.mapView setCenterCoordinate:location.coordinate animated:YES];
    
    //現在地を地図表示
    MKCoordinateRegion region = MKCoordinateRegionMake([location coordinate], MKCoordinateSpanMake(0.01, 0.01));//現在地を地図の中心位置を表した値と、表示領域（地図縮尺）の値をMKCoordinateRegionクラスのインスタンスへ代入
    [self.mapView setRegion:region];//地図表示

}

@end
