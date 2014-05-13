//
//  TSDataBase.m
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/11.
//  Copyright (c) 2014年 team -IKI-. All rights reserved.
//

#import "TSDataBase.h"
@interface TSDataBase()
@end

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
    NSString *sql = @"CREATE TABLE testTable(id INTEGER PRIMARY KEY ,place_name TEXT,latitude REAL, longitude REAL , date NONE , text TEXT ,pics TEXT ,picCount INTEGER, went_flag INTEGER , delete_flag INTEGER);"; //testTableというテーブルを作成。""の中に、送りたいSQL文を記入するぉ。天気カラムを削除し、写真の枚数カラムを追加した（石井）
    [database executeUpdate:sql];
    
    [database close];

}



- (void)createDBData{
    
    //ディレクトリのリストを取得する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectry = paths[0];
    NSString *databaseFilePath = [documentDirectry stringByAppendingPathComponent:@"TSDatabase.db"];//念のためこの関数にもDBへの接続を記載しておく（石井）
    
    
    //インスタンスの作成
    database = [FMDatabase databaseWithPath:databaseFilePath];
    
    //データの追加

    if(!dataid){
        dataid = 0;
    }
    
    NSString *insert_sql = @"INSERT INTO testTable(id, place_name, latitude, longitude, date, text, pics, picCount, went_flag, delete_flag) VALUES (?,?,?,?,?,?,?,?,?,?)";//天気カラムを削除し、写真の枚数カラムを追加した（石井）
    
    [database open];
    
    [database executeUpdate:insert_sql ,
     [NSNumber numberWithInteger:0],
     @"場所",
     [NSNumber numberWithDouble:34.070162], [NSNumber numberWithDouble:134.556246],
     [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]],
     @"文章の全文",
     @"pic1.png",
     [NSNumber numberWithInteger:1],//天気カラムを削除し、写真の枚数カラムを追加した（石井）
     [NSNumber numberWithInteger:1],
     [NSNumber numberWithInteger:0]];
    
    NSLog(@"記事No:%d DB書き込み完了",dataid);
    
    [database close];
 
    dataid++;
}



//cameraViewでデータを上書き保存するために使う関数
- (void)updateDBDataOnCamera:(int)ID TEXT:(NSString *)comment PICS:(NSString *)pics PICCOUNT:(int)picCount{
    
    //ディレクトリのリストを取得する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectry = paths[0];
    NSString *databaseFilePath = [documentDirectry stringByAppendingPathComponent:@"TSDatabase.db"];
    //インスタンスの作成
    database = [FMDatabase databaseWithPath:databaseFilePath];
    
    
    //データのupdate
    NSString *update_sqlDate = [NSString stringWithFormat:@"update testTable set date = '%@' where id = %d", [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]],ID];
    NSString *update_sqlText = [NSString stringWithFormat:@"update testTable set text = '%@' where id = %d",comment, ID];
    NSString *update_sqlPics = [NSString stringWithFormat:@"update testTable set pics = '%@' where id = %d",pics, ID];
    NSString *update_sqlPicCount = [NSString stringWithFormat:@"update testTable set picCount = %d where id = %d",picCount, ID];
                                
                            
    [database open];
    
    [database executeUpdate:update_sqlDate];
    [database executeUpdate:update_sqlText];
    [database executeUpdate:update_sqlPics];
    [database executeUpdate:update_sqlPicCount];
       
    NSLog(@"記事No:%d DB上書き完了",dataid);
    
    [database close];
    
}

- (NSMutableArray *)loadDBDataOnCamera:(int)number{
    //ディレクトリのリストを取得する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectry = paths[0];
    NSString *databaseFilePath = [documentDirectry stringByAppendingPathComponent:@"TSDatabase.db"];
    
    //データベース接続
    database = [FMDatabase databaseWithPath:databaseFilePath];
    
    //容れ物の準備
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    //データベースを開く
    [database open];

    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM testTable WHERE id = %d;",number];
    FMResultSet *results = [database executeQuery:sql];//
    
    
    //データ取得を行うループ
    while([results next]){ //結果が一行ずつ返されて、最後までいくとnextメソッドがnoを返す
        
        int i = 0;
        
        //カラム名を指定して、カラム値を取得する。
        int db_id = [results intForColumn:@"id"];
        [resultArray addObject:@(db_id)];
        
        NSString *db_title = [results stringForColumn:@"place_name"];
        [resultArray addObject:db_title];
        
        double lat = [results doubleForColumn:@"latitude"];
        [resultArray addObject:@(lat)];
        double lon = [results doubleForColumn:@"longitude"];
        [resultArray addObject:@(lon)];
        
        NSString *db_date = [results stringForColumn:@"date"];//＊＊＊＊＊要確認＊＊＊＊＊＊
        [resultArray addObject:db_date];
        
        NSString *db_text = [results stringForColumn:@"text"];
        [resultArray addObject:db_text];
        
        NSString *db_pics = [results stringForColumn:@"pics"];
        [resultArray addObject:db_pics];
        
        int db_piccount = [results intForColumn:@"picCount"];//天気カラムを削除し、写真の枚数カラムを追加した（石井）
        [resultArray addObject:@(db_piccount)];
        
        int wentflag = [results intForColumn:@"went_flag"];
        [resultArray addObject:@(wentflag)];
        
        //        int deleteflag = [results intForColumn:@"delete_flag"];
        


        i++;
    }
    
    NSLog(@"resultArray=%@",[resultArray description]);//確認表示

    [database close];
    
    return resultArray;
    
}



-(NSMutableArray *)loadDBData{ //DBデータの読み込み
    //ディレクトリのリストを取得する
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectry = paths[0];
    NSString *databaseFilePath = [documentDirectry stringByAppendingPathComponent:@"TSDatabase.db"];

    //データベース接続
    database = [FMDatabase databaseWithPath:databaseFilePath];

    //容れ物の準備
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    //データベースを開く
    [database open];
    
    //必要なデータを取り出す（ここでは、delete_flagが0のものすべて）
    NSString *sql = @"SELECT * FROM testTable WHERE delete_flag = '0';";
    FMResultSet *results = [database executeQuery:sql];//DBの中身はresultsにはいるよ

    //要素のいれものをつくる
    NSMutableArray *idarray = [[NSMutableArray alloc]init];
    NSMutableArray *titlearray = [[NSMutableArray alloc]init];
    NSMutableArray *latarray = [[NSMutableArray alloc]init];
    NSMutableArray *lonarray = [[NSMutableArray alloc]init];
    NSMutableArray *datearray = [[NSMutableArray alloc]init];
    NSMutableArray *textarray = [[NSMutableArray alloc]init];
    NSMutableArray *picsarray = [[NSMutableArray alloc]init];//天気カラムを削除し、写真の枚数カラムを追加した（石井）
    NSMutableArray *piccountarray = [[NSMutableArray alloc]init];
    NSMutableArray *wentflagarray = [[NSMutableArray alloc]init];
    
    //データ取得を行うループ
    while([results next]){ //結果が一行ずつ返されて、最後までいくとnextメソッドがnoを返す

        int i = 0;
        
        //カラム名を指定して、カラム値を取得する。
        int db_id = [results intForColumn:@"id"];
        [idarray addObject:@(db_id)];
        
        NSString *db_title = [results stringForColumn:@"place_name"];
        [titlearray addObject:db_title];
        
        double lat = [results doubleForColumn:@"latitude"];
        [latarray addObject:@(lat)];
        double lon = [results doubleForColumn:@"longitude"];
        [lonarray addObject:@(lon)];
        
        NSString *db_date = [results stringForColumn:@"date"];//＊＊＊＊＊要確認＊＊＊＊＊＊
        [datearray addObject:db_date];
        
        NSString *db_text = [results stringForColumn:@"text"];
        [textarray addObject:db_text];
        
        NSString *db_pics = [results stringForColumn:@"pics"];
        [picsarray addObject:db_pics];
        
        int db_piccount = [results intForColumn:@"picCount"];//天気カラムを削除し、写真の枚数カラムを追加した（石井）
        [piccountarray addObject:@(db_piccount)];
        
        int wentflag = [results intForColumn:@"went_flag"];
        [wentflagarray addObject:@(wentflag)];
        
        //        int deleteflag = [results intForColumn:@"delete_flag"];
        
        NSLog(@"check1 %d,%@,%f,%f,%@,%@,%@,%d,%d"
              ,db_id,db_title,lat,lon,db_date,db_text,db_pics,db_piccount,wentflag
              );//確認表示
        
         //最終的にresltArrayに配列がそれぞれぼこっと入る感じで。

        //        NSString *insert_sql = @"INSERT INTO testTable(id, place_name, latitude, longitude, date, weather, text, pics, went_flag, delete_flag) VALUES (?,?,?,?,?,?,?,?,?,?)";
        i++;
    }
    
    NSLog(@"check2=====試しに配列の表示%@",titlearray[2]);

    [database close];
    
    /* データ受け渡し用にぜんぶまとめてぶっこむ */

    [resultArray addObject:idarray];//0
    [resultArray addObject:titlearray];//1
    [resultArray addObject:latarray];//2
    [resultArray addObject:lonarray];//3
    [resultArray addObject:datearray];//4
    [resultArray addObject:textarray];//5
    [resultArray addObject:picsarray];//6
    [resultArray addObject:piccountarray];//7　天気カラムを削除し、写真の枚数カラムを追加した（石井）
    [resultArray addObject:wentflagarray];//8
    
    NSLog(@"check3 ====%@",resultArray);
    return resultArray;
    

}
-(void)deleteData{ //削除フラグをたてるだけだけどね 未完了
    
}

-(void)editData{//編集する 未完了

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
