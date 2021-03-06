//
//  ViewController.m
//  TripShot
//
//  Created by IkumaKomaya on 2014/05/09.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreText/CoreText.h>
#import "ViewController.h"
#import "TSDataBase.h"
#import "CameraViewController.h"



@interface ViewController ()
{
    double longitude;
    double latitude;
    double targetLongitude;
    double targetLatitude;
    CLRegion* distCircularRegion;
    
    NSMutableArray *titleList;
    NSMutableArray *latList;
    NSMutableArray *lonList;
    NSMutableArray *wentFlagList;
   
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //現在地を地図表示
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, 1000, 1000);//現在地を地図の中心位置を表した値と、表示領域（地図縮尺）の値をMKCoordinateRegionクラスのインスタンスへ代入
    
    [self.mapView setRegion:region animated:YES];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    //中心から地図が動かされた事を検知する
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(mapViewPanGesture)];
    
    panGesture.delegate = self;
    
    [self.mapView addGestureRecognizer:panGesture];
    //フラグの初期化
    self.isChasing = YES;
    self.userLocationButton.hidden = YES;

    //tabbar背景色
    [UITabBar appearance].barTintColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.92 alpha:1.0];
    
    //全ての通知を一度キャンセルさせる
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

}

//複数のジェスチャーを同時認識する事を許可
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)mapViewPanGesture
{
    NSLog(@"検知しました");
    self.isChasing = NO;
    
    self.userLocationButton.hidden = NO;
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
    
    if (self.isChasing == YES)
    {
        [self.mapView setCenterCoordinate:location.coordinate animated:YES];

    }
    
    [self saveLocation:location];//値受け渡し用メソッド追加（藤原）
    
    
    //到達点についた時に分かるようにジオフェンスをスタート
    [self.locationManager startMonitoringForRegion:distCircularRegion];
    
    //60秒に一回ロケーションマネージャを立ち上げる
    [self.locationManager stopUpdatingLocation];
     // self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(_turnOnLocationManager)  userInfo:nil repeats:NO];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(_turnOnLocationManager)  userInfo:nil repeats:NO];

}

//現在地ボタンが押された時
- (IBAction)tapUserLocationButton:(UIButton *)sender
{
    //フラグを初期化して、現在地を地図の中心にする
    self.isChasing = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    self.userLocationButton.hidden = YES;
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


// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる関数
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}



- (void)_turnOnLocationManager {
    [self.locationManager startUpdatingLocation];
}



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



// 進入イベント 通知
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
   NSLog(@"ジオフェンス領域%@に入りました",region.identifier);
    
    //バックグラウンドからの通知
    [self LocalNotificationStart:region.identifier];
}


// ジオフェンスしっぱい。
-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"ジオフェンス領域%@しっぱい",region.identifier);
    NSLog(@"%d",error.code);
}

//ジオフェンスキャンセル
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
-(void)LocalNotificationStart:(NSString *)locationName {
    
   //ローカル通知させる時のインスタンス作成
    UILocalNotification *notification = [[UILocalNotification alloc]init];

    if (notification == nil)
    
    NSLog(@"check========================謎通知タイミング");
    
    notification.fireDate = [NSDate new]; //3秒後にメッセ時が表示されるよう設定
    notification.shouldGroupAccessibilityChildren = YES;
    notification.alertBody = [NSString stringWithFormat:@"%@が近くです＾＾",locationName];  //メッセージの内容
    notification.timeZone = [NSTimeZone defaultTimeZone];  //タイムゾーンの設定 その端末にあるローケーションに合わせる
    notification.soundName = UILocalNotificationDefaultSoundName;  //効果音
    notification.applicationIconBadgeNumber = 1;  //通知された時のアイコンバッジの右肩の数字
    [[UIApplication sharedApplication]presentLocalNotificationNow:notification];  //ローカル通知の登録
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

}

#pragma mark - ふじわら追加メソッド

-(void)viewDidAppear:(BOOL)animated{
    
    
    [self.navigationController setNavigationBarHidden:YES];
    self.tabBarController.tabBar.hidden = NO;
    
    //位置情報が使えるか確認する
    [self locationAuth];
    
    //バックグラウンド通信ができるか確認する
    [self backgroundCheck];
    
    //メモリーリーク防止の為に、一旦ジオフェンスを停止
    [self geoFenceCancel];

    //annotation追加
    [self markingPinFromList];
    _mapView.delegate = self;
    
    //tabバーのアイコンの色設定
    [[UITabBar appearance]setTintColor:[UIColor colorWithRed:0.91 green:0.42 blue:0.41 alpha:1.0]];
    //tabbar背景色
    [UITabBar appearance].barTintColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.92 alpha:1.0];

}

-(void)markingPinFromList{
    
    //一度全てのアノテーションを削除
    [_mapView removeAnnotations:self.mapView.annotations];

    
    //DBと接続
    TSDataBase *db = [[TSDataBase alloc]init];
    NSMutableArray *DBData = [db loadDBData];
    
    titleList = [[NSMutableArray alloc]init];
    titleList = DBData[1];
    
    latList =[[NSMutableArray alloc]init];
    latList = DBData[2];
    
    lonList = [[NSMutableArray alloc]init];
    lonList = DBData[3];
    
    wentFlagList = [[NSMutableArray alloc]init];
    wentFlagList = DBData[8];

    NSMutableArray *addressList = [[NSMutableArray alloc]init];
    addressList = DBData[10];
    NSString *temp;
    
    for(int i = 0; i < titleList.count ; i++)
    {
        temp = latList[i];
        double lat = temp.doubleValue;
        temp = lonList[i];
        double lon = temp.doubleValue;

        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(lat, lon);
        MKPointAnnotation *pin = [[MKPointAnnotation alloc]init];
        pin.coordinate = loc;
        pin.title = titleList[i];
        pin.subtitle = addressList[i];
        
        
        CLLocationCoordinate2D finalCoodinates = CLLocationCoordinate2DMake(lat, lon);
        
        distCircularRegion = [[CLCircularRegion alloc]initWithCenter:finalCoodinates radius:300
                                                          identifier:[NSString stringWithFormat:@"%@",titleList[i]]];
        
        NSLog(@"titleList=%@",titleList[i]);
        NSLog(@"wentFlag=%@",[[wentFlagList objectAtIndex:i] description]);
        [_mapView addAnnotation:pin];
        
    //行っていない場所にだけジオフェンスをセット
        if ([[wentFlagList objectAtIndex:i] intValue]==1)
        {
 
            CLLocationCoordinate2D finalCoodinates = CLLocationCoordinate2DMake(lat, lon);
            distCircularRegion = [[CLCircularRegion alloc]initWithCenter:finalCoodinates radius:300
                                                          identifier:[NSString stringWithFormat:@"%@",titleList[i]]];

            //到達点についた時に分かるようにジオフェンスをスタート
            [self.locationManager startMonitoringForRegion:distCircularRegion];
            
        }
    }
    
}


//アノテーションビューが作られたとき
- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views{

    // アノテーションビューを取得する
    for (MKAnnotationView * annotationView in views)
    {
        UIImage *cameraImg = [UIImage imageNamed:@"camera.png"];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(5,0,44,44)];
        [button setBackgroundImage:cameraImg forState:UIControlStateNormal];
        annotationView.leftCalloutAccessoryView = button;
            
//        UIImage *pinImg = [UIImage imageNamed:@"pin.png"];
//        annotationView.image = pinImg;
        
    }
}

//現在地のコールアウトを表示しない
- (MKAnnotationView *) mapView:(MKMapView *)targetMapView
             viewForAnnotation:(id ) annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]]){
        ((MKUserLocation *)annotation).title = nil;
    }
    return nil;
}


//アクセサリーが押された時のイベント
-(void) mapView:(MKMapView *)mapView
    annotationView:(MKAnnotationView *)view
    calloutAccessoryControlTapped:(UIControl *)control{
    
    NSLog(@"%@",view.annotation);
    NSLog(@"title is : %@",view.annotation.title);
    
    CameraViewController *cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraVC"];
    cameraVC.place_nameFromMainPage = view.annotation.title;

    [self.navigationController pushViewController:cameraVC animated:YES];
}



//緯度経度保存
-(void)saveLocation:(CLLocation *)lastLocation{

    NSString *latString = [NSString stringWithFormat:@"%f",lastLocation.coordinate.latitude];
    NSString *lonString = [NSString stringWithFormat:@"%f",lastLocation.coordinate.longitude];
    NSUserDefaults *savedata = [NSUserDefaults standardUserDefaults];
    [savedata setObject:latString forKey:@"latFromMainPage"];
    [savedata setObject:lonString forKey:@"lonFromMainPage"];

}

@end
