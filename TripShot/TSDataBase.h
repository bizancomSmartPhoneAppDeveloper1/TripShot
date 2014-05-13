//
//  TSDataBase.h
//  TripShot
//
//  Created by bizan.com.mac05 on 2014/05/11.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface TSDataBase : NSObject


-(void)makeDatabase;//データベースがなかったらつくる
-(void)createDBData;//データの新規作成
-(NSMutableArray *)loadDBData;//データの読み込み(配列に入れ込んでいる）

-(void)saveData;//通し番号セーブ（記事作成後に必ず）
-(void)loadData;//通し番号読み込み（記事作成前に必ず）

-(void)deleteData;//削除フラグをたてるだけだけどね 未完了
-(void)editData;//編集する 未完了

- (void)updateDBDataOnCamera:(int)ID TEXT:(NSString *)text PICS:(NSString *)pics PICCOUNT:(int)picCount;//cameraViewでupdate

- (NSMutableArray *)loadDBDataOnCamera:(int)number;//cemaraviewで読み込むために使う

//緯度経度から住所・地名に変換必要

//あと必要なメソッドって何がある？
//とりあえず自分の作業範囲で考えてみる

/*
 
　保存するときに画像を入れ込む？未完了
 
　地図の表示 あとでする　このクラスじゃなくていい
 
 */


@end
