//
//  ViewController.m
//  TripShot
//
//  Created by IkumaKomaya on 2014/05/09.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
#import "CustomAnnotation.h"
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

@property (strong, nonatomic) CustomAnnotation *annotation;

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
    
    [self.mapView addGestureRecognizer:panGesture];
    //フラグの初期化
    self.isChasing = YES;
    //self.userLocationBtn.hidden = YES;

    
    //位置情報が使えるか確認する
    [self locationAuth];
    
    //バックグラウンド通信ができるか確認する
    [self backgroundCheck];
    
    //到達点についた時に分かるようにジオフェンスをスタート
    [self.locationManager startMonitoringForRegion:distCircularRegion];
    
    
    //tabバーのアイコンの色設定
    [[UITabBar appearance]setTintColor:[UIColor colorWithRed:0.91 green:0.42 blue:0.41 alpha:1.0]];
    //tabbar背景色
    [UITabBar appearance].barTintColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.92 alpha:1.0];
    
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
    
    self.userLocationBtn.hidden = NO;
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
    
    if (self.isChasing)
    {
        [self.mapView setCenterCoordinate:location.coordinate animated:YES];

    }
    
    [self saveLocation:location];//値受け渡し用メソッド追加（藤原）
    
    
    
    //到達点についた時に分かるようにジオフェンスをスタート
    [self.locationManager startMonitoringForRegion:distCircularRegion];
    
    //60秒に一回ロケーションマネージャを立ち上げる
    [self.locationManager stopUpdatingLocation];
      self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(_turnOnLocationManager)  userInfo:nil repeats:NO];
   // self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(_turnOnLocationManager)  userInfo:nil repeats:NO];

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
   
    for (int r = 0; r < titleList.count; r++)
    {
        // 入った。
        if ([region.identifier isEqualToString:[NSString stringWithFormat:@"%@",titleList[r]]]) {
            NSLog(@"ジオフェンス領域%@に入りました",titleList[r]);
            NSLog(@"%d",r);
            //バックグラウンドからの通知
            [self LocalNotificationStart];

        }
    }
}


// ジオフェンスしっぱい。
-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"ジオフェンス領域%@しっぱい",region.identifier);
    NSLog(@"%d",error.code);
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
    //notification.repeatInterval = NSCalendarUnitDay;  //毎日通知させる設定
    notification.alertBody = [NSString stringWithFormat:@"行きたい場所が近くです＾＾"];  //メッセージの内容
    notification.timeZone = [NSTimeZone defaultTimeZone];  //タイムゾーンの設定 その端末にあるローケーションに合わせる
    notification.soundName = UILocalNotificationDefaultSoundName;  //効果音
    notification.applicationIconBadgeNumber = 1;  //通知された時のアイコンバッジの右肩の数字
    
    
    [[UIApplication sharedApplication]scheduleLocalNotification:notification];  //ローカル通知の登録
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
}

#pragma mark - ふじわら追加メソッド

-(void)viewDidAppear:(BOOL)animated{
    
    
    [self.navigationController setNavigationBarHidden:YES];
    self.tabBarController.tabBar.hidden = NO;
    
    //DBからピンぶっさしてます
    [self markingPinFromList];
    _mapView.delegate = self;


}

-(void)markingPinFromList{
    
    //DBと接続
    TSDataBase *db = [[TSDataBase alloc]init];
    NSMutableArray *DBData = [db loadDBData];
    
    titleList = [[NSMutableArray alloc]init];
    titleList = DBData[1];
    
    latList =[[NSMutableArray alloc]init];
    latList = DBData[2];
    
    lonList = [[NSMutableArray alloc]init];
    lonList = DBData[3];
    
    wentFlagList = [[NSMutableArray alloc]init];//行っていない場所にだけジオフェンスをセットするために、wentFlagList作成（石井）
    wentFlagList = DBData[8];//行っていない場所にだけジオフェンスをセットするために、wentFlagList作成（石井）

    NSMutableArray *addressList = [[NSMutableArray alloc]init];
    addressList = DBData[10];
    NSString *temp;
    
    for(int i = 0; i < titleList.count ; i++){
        temp = latList[i];
        double lat = temp.doubleValue;
        temp = lonList[i];
        double lon = temp.doubleValue;

        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(lat, lon);
        MKPointAnnotation *pin = [[MKPointAnnotation alloc]init];
        pin.coordinate = loc;
        pin.title = titleList[i];
        pin.subtitle = addressList[i];
        
        [_mapView addAnnotation:pin];
        
        CLLocationCoordinate2D finalCoodinates = CLLocationCoordinate2DMake(lat, lon);
        
        distCircularRegion = [[CLCircularRegion alloc]initWithCenter:finalCoodinates radius:300
                                                          identifier:[NSString stringWithFormat:@"%@",titleList[i]]];
        
        NSLog(@"%@",titleList[i]);
    /*
    //アノテーションを刺した場所のジオフェンスを開始
    //行っていない場所にだけジオフェンスをセットするために、if文を追加（石井）
    if ([[wentFlagList objectAtIndex:i] intValue]==1) {
 
    CLLocationCoordinate2D finalCoodinates = CLLocationCoordinate2DMake(lat, lon);
        
    distCircularRegion = [[CLCircularRegion alloc]initWithCenter:finalCoodinates radius:500
                                                          identifier:[NSString stringWithFormat:@"%@",titleList[i]]];
    }*/
    }
    
}

//アノテーションビューが作られたとき
- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views{

    // アノテーションビューを取得する
    for (MKAnnotationView* annotationView in views) {
        UIImage *cameraImg = [UIImage imageNamed:@"camera.png"];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(5,0,44,44)];
        
        [button setBackgroundImage:cameraImg forState:UIControlStateNormal];
        
        // コールアウトの左側のアクセサリビューにボタンを追加する
        annotationView.leftCalloutAccessoryView = button;
    }
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


- (IBAction)tapUserLocationBtn:(UIButton *)sender
{
    self.isChasing = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    self.userLocationBtn.hidden = YES;
}
@end
