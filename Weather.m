//
//  Weather.m
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/11.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "Weather.h"

@implementation Weather{
    CLLocationManager *locationManager;
    double latitude;
    double longitude;
    
}
-(void)getLocation{

    //現在の位置情報を取得
    //まず位置情報通知の開始
    if([CLLocationManager locationServicesEnabled]){
       locationManager = [[CLLocationManager alloc]init];
        NSLog(@"位置情報取得可能");
    }else{
        NSLog(@"位置情報は使用できません");
    }
    
    //通知イベントをこのクラスで受け取る
    locationManager.delegate = self;
    
    //最高精度を設定
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    //移動距離が変化したときにイベントを起こす値（メートル）を指定、KCLDistanceFilerNoneで逐次
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    //位置情報の取得を開始する
    [locationManager startUpdatingLocation];
    
    NSLog(@"check0===========================");
    
}


//受信した位置情報イベントの処理
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *newLocation = [locations lastObject]; //これでnewLocationがとれてるらしい。
    //    NSDate *eventDate = newLocation.timestamp;
    NSLog(@"check1=============================latitude %+.6f, longitude %+.6f\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);
    
     latitude = newLocation.coordinate.latitude;
     longitude = newLocation.coordinate.longitude;
     
    //位置情報の取得を停止する
    [locationManager stopUpdatingLocation];

}


-(NSString *)getWeather{
    
    //天気を取得
    
    //天気API
    
    //文字列に変換
    
    
    NSString *weather;
    return weather;
}

@end

