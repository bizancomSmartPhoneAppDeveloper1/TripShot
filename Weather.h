//
//  Weather.h
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/11.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Weather : NSObject<CLLocationManagerDelegate>
-(void)getLocation;
-(NSString *)getWeather; //現在地から天気を取得するメソッド

@end
