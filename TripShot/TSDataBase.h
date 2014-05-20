//
//  TSDataBase.h
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/11.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
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

//-(void)wentFlagFromDataId:(int)dataId;//到達フラグをたてる
-(int)CountNowData;//現在のデータ総数を確認する

//緯度経度からDBにデータ追加するメソッド
-(void)createDBDataFromLat:(double)lat andLot:(double)lot andTitle:(NSString *)title; //SeachListViewControllerで使用
- (void)DeleteFlag:(int)number;
- (FMResultSet *)loadDBDataFromDBId:(int)number;




//カメラVewでDB読み込むための関数　引数numberはdataid
- (FMResultSet *)loadDBDataOnCamera:(int)number;

//cameraViewでデータを上書き保存するために使う関数
- (void)updateDBDataOnCamera:(int)ID TEXT:(NSString *)comment PICS:(NSString *)pics PICCOUNT:(int)picCount WENTFLAG:(int)went_flag;

//完全削除メソッド 必要な時以外、絶対に使用しないこと！！
//- (void)dbDelete;

//IDをplace_nameから取得する関数
- (FMResultSet *)loadIDFromPlaceName:(NSString *)place_name;

//individualAlbumViewControllerでコメントを編集した時に使う関数
- (void)updateText:(int)ID TEXT:(NSString *)comment;

@end
