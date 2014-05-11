//
//  TSDataBase.m
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/11.
//  Copyright (c) 2014年 team -IKI-. All rights reserved.
//

#import "TSDataBase.h"

@implementation TSDataBase{

    FMDatabase *database;
    int dataid;

}


- (void)makeDatabase{
    
    //ディレクトリのリストを取得する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectry = paths[0];
    NSString *databaseFilePath = [documentDirectry stringByAppendingPathComponent:@"TSDatabase.db"];
    //インスタンスの作成
    database = [FMDatabase databaseWithPath:databaseFilePath];
    //データベースを開く
    [database open];
    
    
    /* テーブルの作成 */
    NSString *sql = @"CREATE TABLE testTable(id INTEGER PRIMARY KEY ,place_name TEXT,latitude REAL, longitude REAL , date NONE , weather TEXT ,text TEXT ,pics TEXT ,went_flag INTEGER , delete_flag INTEGER);"; //testTableというテーブルを作成。""の中に、送りたいSQL文を記入するぉ
    [database executeUpdate:sql];
    
    [database close];

}

- (void)createNewData{
    
    /*　データの追加　*/

    if(!dataid){
        dataid = 0;
    }
    
    
    NSString *insert_sql = @"INSERT INTO testTable(id, place_name, latitude, longitude, date, weather, text, pics, went_flag, delete_flag) VALUES (?,?,?,?,?,?,?,?,?,?)";
    
    [database open];
    
    [database executeUpdate:insert_sql ,
     [NSNumber numberWithInteger:4],
     @"場所",
     [NSNumber numberWithDouble:34.070162], [NSNumber numberWithDouble:134.556246],
     [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]],
     @"天気",
     @"文章の全文",
     @"pic1.png",
     [NSNumber numberWithInteger:1],
     [NSNumber numberWithInteger:0]];
    
    NSLog(@"記事No:%d DB書き込み完了",dataid);
    
    [database close];
    
    dataid++;
}


-(void)saveData{ //通しナンバーを保存

    NSUserDefaults *savedata = [NSUserDefaults standardUserDefaults];
    [savedata setInteger:dataid forKey:@"dataid"];

}

-(void)loadData{ //通しナンバーの読み込み
    NSUserDefaults *savedata = [NSUserDefaults standardUserDefaults];
    dataid = [savedata integerForKey:@"dataid"];

}

@end
