//
//  TSDataBase.h
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/11.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface TSDataBase : NSObject


-(void)makeDatabase;//データベースがなかったらつくる(あったら無視されるから安心）
-(void)createDBData;//データの新規作成

-(NSMutableArray *)loadDBData; //データの読み込み(配列にまとめて入れ込んでいる）
/*
 
 [0] idarray int
 [1] titlearray NSString
 [2] latarray double
 [3] lonarray double
 [4] datearray int
 [5] textarray NSString
 [6] picsarray NSString
 [7] weatherarray NSString
 [8] wentflagarray int
 [9] hourarray int
 [10] addressarray NSString
 
 */

-(NSString *)getAddressFromLat:(double)lat AndLot:(double)lot;//緯度経度情報から住所を取得する
-(int)getIntegerDate; //日付を取得してint型に変換
-(int)getIntegerHour; //現在の時刻を取得してint型に変換


-(void)saveData;//通し番号セーブ（記事作成後に必ず）
-(int)loadData;//通し番号読み込み（記事作成前に必ず）通し番号がかえってくる

-(void)deleteData;//削除フラグをたてるだけだけどね 未完了

//緯度経度からDBにデータ追加するメソッド
-(void)createDBDataFromLat:(double)lat andLot:(double)lot andTitle:(NSString *)title; //SeachListViewControllerで使用
    



//あと必要なメソッドって何がある？

- (NSMutableArray *)loadDBDataOnCamera:(int)number;//cameraViewで使用するメソッド
- (void)updateDBDataOnCamera:(int)ID TEXT:(NSString *)comment PICS:(NSString *)pics PICCOUNT:(int)picCount;//cameraViewで使用するメソッド
- (void)dbDelete;//完全削除メソッド 必要な時以外、絶対に使用しないこと！！

- (NSMutableArray *)loadLatLonPlaceName:(NSString *)place_name LAT:(double)latitude LON:(double)longitude;//緯度経度行きたい場所でidを検索するメソッド


@end
