//
//  ViewController.m
//  TripShot
//
//  Created by bizan.com.mac02 on 2014/05/09.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "ViewController.h"
#import "CustomAnnotation.h"
#import "TSDataBase.h"

@interface ViewController ()
{
    double longitude;
    double latitude;
    double targetLongitude;
    double targetLatitude;
    CLRegion* distCircularRegion;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    //位置情報が使えるか確認する
    [self locationAuth];
    
    //バックグラウンド通信ができるか確認する
    [self backgroundCheck];
    
    //住所から緯度経度取得　とりあえず使わない
    //[self webAPI];
    //ジオフェンス作成
    [self createGeofence];
    //到達点についた時に分かるようにジオフェンスをスタート
    [self.locationManager startMonitoringForRegion:distCircularRegion];
    
    //DBからピンぶっさしてます
    [self markingPinFromList];
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
    
    //表示座標
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(34.075222, 134.554028);
    
    //ピン用アノテーションを生成
    MKPointAnnotation *pin = [[MKPointAnnotation alloc]init];
    pin.coordinate = loc; //ピンの座標
    
    
    
    //ピンの設定
    [self.mapView addAnnotation:pin];
    
    [self.mapView setRegion:region];//地図表示

}

- (void)locationAuth{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorized: // 位置情報サービスへのアクセスが許可されている
            NSLog(@"アクセスが許可されている");
            if ([CLLocationManager locationServicesEnabled]) {
                
                // 測位開始
                [self.locationManager startUpdatingLocation];
            }
            break;
            
        case kCLAuthorizationStatusNotDetermined: // 位置情報サービスへのアクセスを許可するか選択されていない
            NSLog(@"アクセスを許可するか選択されていない");
            if ([CLLocationManager locationServicesEnabled]) {
                
                // 測位開始
                [self.locationManager startUpdatingLocation];
            }
            break;
            
        case kCLAuthorizationStatusRestricted: // 設定 > 一般 > 機能制限で利用が制限されている
            NSLog(@"設定 > 一般 > 機能制限で利用が制限されている");
            [self alertViewMethod:@"設定 > 一般 > 機能制限から利用を許可してください。"];
            break;
            
        case kCLAuthorizationStatusDenied: // ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない
            NSLog(@"ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない");
            [self alertViewMethod:@"設定 > プライバシー > 位置情報サービスから利用を許可してください。"];
            break;
            
        default:
            NSLog(@"default");
            if ([CLLocationManager locationServicesEnabled]) {
                
                // 測位開始
                [self.locationManager startUpdatingLocation];
            }
            
            break;
    }
    
    
}

// 位置情報更新関数
- (void)locationManager:(CLLocationManager *)manager//引数managerはシステムからの情報か？CLLocationManagerクラスにある位置情報を取得するlocationManagerメソッド
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //更新された緯度・経度を出力
    NSLog(@"didUpdateToLocation latitude=%f, longitude=%f",
          [newLocation coordinate].latitude,//didUpdateToLocationクラスのcoordinateプロパティに緯度情報を代入
          [newLocation coordinate].longitude);//didUpdateToLocationクラスのcoordinateプロパティに経度情報を代入
    
    longitude = [newLocation coordinate].longitude;
    latitude = [newLocation coordinate].latitude;
    
    
    
//    //現在地を地図表示
//    MKCoordinateRegion region = MKCoordinateRegionMake([newLocation coordinate], MKCoordinateSpanMake(0.04, 0.04));//現在地を地図の中心位置を表した値と、表示領域（地図縮尺）の値をMKCoordinateRegionクラスのインスタンスへ代入
//    [self.mapView setRegion:region];//地図表示
//    
//    //targetにピンを立てる
//    //DBから読み込んだ緯度経度情報が必要
//    targetLatitude = 34.070162;//一時的にトモニプラザの緯度を設定
//    NSLog(@"targetLatitude=%f",targetLatitude);
//    targetLongitude =134.556246;//一時的にトモニプラザの経度を設定
//    
//    [self.mapView addAnnotation:
//     [[CustomAnnotation alloc]initWithLocationCoordinate:CLLocationCoordinate2DMake(targetLatitude,targetLongitude)
//                                                   title:@"Target"
//                                                subtitle:@""]];
//    
    //60秒に一回ロケーションマネージャを立ち上げる
    [self.locationManager stopUpdatingLocation];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(_turnOnLocationManager)  userInfo:nil repeats:NO];
    
    
}

// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる関数
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}



- (void)_turnOnLocationManager {
    [self.locationManager startUpdatingLocation];
}


/*とりあえず使わない
 //住所webAPI
 - (void)webAPI{
 NSDictionary *jsonObjectResults = [[NSDictionary alloc]init];
 NSString *urlApi1 = @"http://maps.google.com/maps/api/geocode/json?address=";
 //double lat= 34.070162;
 //double lon= 134.556246;
 NSString *urlApi2 = @"&sensor=false";
 NSString *urlApi = [NSString stringWithFormat:@"%@%@%@",urlApi1,address,urlApi2];
 NSLog(@"URL=%@",urlApi);
 
 NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlApi]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
 
 //sendSynchronousRequestメソッドでURLにアクセス
 NSHTTPURLResponse* resp;
 NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:nil];
 
 //通信エラーの際の処理を考える必要がある
 if (resp.statusCode != 200){
 [self alertViewMethod:@"読み込みに失敗しました"];
 }
 
 //返ってきたデータをJSONObjectWithDataメソッドで解析
 else{
 jsonObjectResults = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingAllowFragments error:nil];
 
 NSDictionary *status = [jsonObjectResults objectForKey:@"status"];
 NSString *statusString = [status description];
 
 if ([statusString isEqualToString:@"ZERO_RESULTS"]) {
 [self alertViewMethod:@"読み込みに失敗しました"];
 NSLog(@"ZERO_RESULTS");
 }else{
 NSMutableArray *result = [jsonObjectResults objectForKey:@"results"];
 //NSString *str = [result description];
 //NSLog(@"%@",str);
 NSDictionary *resultDic = [result objectAtIndex:0];
 //NSString *str2 = [dic description];
 NSDictionary *geometry = [resultDic objectForKey:@"geometry"];
 NSDictionary *location = [geometry objectForKey:@"location"];
 targetLatitude = [[location objectForKey:@"lat"] doubleValue];
 NSLog(@"targetLatitude=%f",targetLatitude);
 targetLongitude = [[location objectForKey:@"lng"] doubleValue];
 NSLog(@"targetLongitude=%f",targetLongitude);
 
 }
 }
 }
 */


//「Appのバックグラウンド更新」の設定値を取得
- (void)backgroundCheck{
    UIBackgroundRefreshStatus status = [UIApplication sharedApplication].backgroundRefreshStatus;
    
    //判定処理
    switch (status) {
        case UIBackgroundRefreshStatusAvailable:
            //Appの自動更新がON
            NSLog(@"%@",@"利用できる");
            break;
        case UIBackgroundRefreshStatusDenied:
            //Appの自動更新がOFF もしくは、ONだがこのアプリはOFF
            NSLog(@"%@",@"拒否された");
            [self alertViewMethod:@"バックグラウンド動作を設定の一般のAppのバックグラウンド更新から許可してください。"];
            break;
        case UIBackgroundRefreshStatusRestricted:
            //ペアレンタルコントロール時に入るかも
            NSLog(@"%@",@"制限");
            [self alertViewMethod:@"バックグラウンド動作を設定の一般のAppのバックグラウンド更新から許可してください。"];
            break;
        default:
            //どんなケースで入るのか不明
            NSLog(@"%@",@"どれでもない");
            [self alertViewMethod:@"バックグラウンド動作を設定の一般のAppのバックグラウンド更新から許可してください。"];
            break;
    }
}

//ジオフェンス関数
-(void)createGeofence
{
    
    //DBから読み込んだ緯度経度情報が必要
    targetLatitude = 34.070162;//一時的にトモニプラザの緯度を設定
    NSLog(@"targetLatitude=%f",targetLatitude);
    targetLongitude =134.556246;//一時的にトモニプラザの経度を設定
    NSLog(@"targetLongitude=%f",targetLongitude);
    CLLocationCoordinate2D finalCoodinates = CLLocationCoordinate2DMake(targetLatitude, targetLongitude);
    
    distCircularRegion = [[CLCircularRegion alloc]initWithCenter:finalCoodinates radius:500
                                                      identifier:@"targetPlace"];
    
    
}

// 進入イベント 通知
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    // 入った。
    if ([region.identifier isEqualToString:@"targetPlace"]) {
        NSLog(@"ジオフェンス領域%@に入りました",region.identifier);
    }
    //バックグラウンドからの通知
    [self LocalNotificationStart];
}

// 退出イベント 通知
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    // 出た。
    if ([region.identifier isEqualToString:@"targetPlace"]) {
        NSLog(@"ジオフェンス領域%@から出ました",region.identifier);
    }
}

// ジオフェンスしっぱい。
-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"ジオフェンス領域%@しっぱい",region.identifier);
}


//ジオフェンスキャンセル　今回はバックグラウンドで通信を行ない続けるので、使わない
- (void)geoFenceCancel{
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        // 登録してある地点を全て取得し、停止
        [self.locationManager stopMonitoringForRegion:region];
        NSLog(@"monotoring regions:%@", self.locationManager.monitoredRegions);
    }
}

//読み込み失敗時に呼ばれる関数
- (void)alertViewMethod:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}

//バックグラウンド状態の時に通知する
-(void)LocalNotificationStart{
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];  //設定する前に、設定済みの通知をキャンセルする
    UILocalNotification *notification = [[UILocalNotification alloc]init];  //ローカル通知させる時のインスタンス作成
    if (notification == nil)return;
    
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3]; //3秒後にメッセ時が表示されるよう設定
    notification.repeatInterval = NSCalendarUnitDay;  //毎日通知させる設定
    notification.alertBody = @"ジオフェンス領域に入りました";  //メッセージの内容
    notification.timeZone = [NSTimeZone defaultTimeZone];  //タイムゾーンの設定 その端末にあるローケーションに合わせる
    notification.soundName = UILocalNotificationDefaultSoundName;  //効果音
    notification.applicationIconBadgeNumber = 1;  //通知された時のアイコンバッジの右肩の数字
    
    
    [[UIApplication sharedApplication]scheduleLocalNotification:notification];  //ローカル通知の登録
    
}

#pragma mark -
#pragma mark ふじわら追加メソッド

//DBからデータを読み込んで指定のピンをとりあえず刺しまくるメソッド まだデータの受け渡し部分未実装
-(void)markingPinFromList{
    
    //DBと接続
    TSDataBase *db = [[TSDataBase alloc]init];
    NSMutableArray *DBData = [db loadDBData];
    
//    NSMutableArray *idList = DBData[0];

    NSMutableArray *titleList = [[NSMutableArray alloc]init];
    titleList = DBData[1];
    
    NSMutableArray *latList =[[NSMutableArray alloc]init];
    latList = DBData[2];
    
    NSMutableArray *lonList = [[NSMutableArray alloc]init];
    lonList = DBData[3];

    NSMutableArray *addressList = [[NSMutableArray alloc]init];
    addressList = DBData[10];
    NSString *temp;
    
    //こっから刺しまくりんぐ
    for(int i = 0; i < titleList.count ; i++){
        temp = latList[i];
        double lat = temp.doubleValue;
        temp = lonList[i];
        double lon = temp.doubleValue;
        
    //緯度経度からアノテーションをさす（ふつうのやつです）
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(lat, lon);
    MKPointAnnotation *pin = [[MKPointAnnotation alloc]init];
    pin.coordinate = loc;
    pin.title = titleList[i];
    pin.subtitle = addressList[i];

    [_mapView addAnnotation:pin];
    
    }
    
}


@end
