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
-(void)createNewData;//データの新規作成
-(void)saveData;//通し番号セーブ（記事作成後に必ず）
-(void)loadData;//通し番号読み込み（記事作成前に必ず）

-(void)deleteData;//削除フラグをたてるだけだけどね 未完了
-(void)editData;//編集する 未完了


//あと必要なメソッドって何がある？
//とりあえず自分の作業範囲で考えてみる

/*
 
　保存するときに画像を入れ込む
 
　現在地の緯度経度の取得
 
　地図の表示

  データを読みこんで配列に入れる（TableView表示などのために。）
 
 
 */


@end