//
//  TSDataBase.m
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/11.
//  Copyright (c) 2014年 team -IKI-. All rights reserved.
//

#import "TSDataBase.h"
@interface TSDataBase()
@property NSInteger dataid;
@end

@implementation TSDataBase{

    FMDatabase *database;
//    int dataid;
    NSString *addressStr;

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
    NSString *sql = @"CREATE TABLE testTable(id INTEGER PRIMARY KEY ,place_name TEXT,latitude REAL, longitude REAL , date INTEGER , weather TEXT ,text TEXT ,pics TEXT ,went_flag INTEGER , delete_flag INTEGER , hour INTEGER , address TEXT);"; //testTableというテーブルを作成。""の中に、送りたいSQL文を記入するぉ
    [database executeUpdate:sql];
    
    [database close];

}

- (void)createDBData{ //データをいれこむ
    
    _dataid = [self loadData]; //連番の取得
    
    /*　データの追加　*/

    if(!_dataid){
        _dataid = 0;
    }
    
    NSString *insert_sql = @"INSERT INTO testTable(id, place_name, latitude, longitude, date, weather, text, pics, went_flag, delete_flag , hour , address) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";

    //入れるデータの準備
    NSInteger date = [self getIntegerDate];
    NSInteger hour = [self getIntegerHour];
    double lat = 34.070162;//仮データ
    double lot = 134.556246; //仮データ
    NSString *address = [self getAddressFromLat:lat AndLot:lot];
    
    
    //データをいれる

    [database open];
    
    [database executeUpdate:insert_sql ,
     [NSNumber numberWithInteger:_dataid],
     @"場所",
     [NSNumber numberWithDouble:lat], [NSNumber numberWithDouble:lot],
     [NSNumber numberWithInteger:date] ,//日にち6桁int
     @"天気",
     @"文章の全文",
     @"pic1.png",
     [NSNumber numberWithInteger:1],
     [NSNumber numberWithInteger:0],
     [NSNumber numberWithInteger:hour],//時刻4桁int
     address
     ];
    
    NSLog(@"記事No:%d DB書き込み完了",_dataid);
    
    [database close];
    
    _dataid++;
    
    [self saveData];
}

-(int)getIntegerDate{ //日付を取得してint型に変換
    
    //日付取得
    NSString* date_str;
    NSDate *now = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    date_str = [formatter stringFromDate:now]; //strに変換

    int result = [date_str integerValue];

    return result;

}

-(int)getIntegerHour{ //現在の時刻を取得してint型に変換

    //日付取得
    NSString* date_str;
    NSDate *now = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmm"];
    date_str = [formatter stringFromDate:now]; //strに変換
    int result = [date_str integerValue];
    return result;
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

    
    //sqlのさいごにORDER BY ID DESC　をいれるとIDの順番でソートできる
    //できてるかな？確認
    
    NSString *sql = @"SELECT * FROM testTable WHERE delete_flag = '0' ORDER BY date DESC;";
    FMResultSet *results = [database executeQuery:sql];//DBの中身はresultsにはいるよ

    //要素のいれものをつくる
    NSMutableArray *idarray = [[NSMutableArray alloc]init];
    NSMutableArray *titlearray = [[NSMutableArray alloc]init];
    NSMutableArray *latarray = [[NSMutableArray alloc]init];
    NSMutableArray *lonarray = [[NSMutableArray alloc]init];
    NSMutableArray *datearray = [[NSMutableArray alloc]init];
    NSMutableArray *textarray = [[NSMutableArray alloc]init];
    NSMutableArray *picsarray = [[NSMutableArray alloc]init];
    NSMutableArray *weatherarray = [[NSMutableArray alloc]init];
    NSMutableArray *wentflagarray = [[NSMutableArray alloc]init];
    NSMutableArray *hourarray = [[NSMutableArray alloc]init];
    NSMutableArray *addressarray = [[NSMutableArray alloc]init];
    
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
        
        int db_date = [results intForColumn:@"date"];
        [datearray addObject:@(db_date)];
        
        NSString *db_text = [results stringForColumn:@"text"];
        [textarray addObject:db_text];
        
        NSString *db_pics = [results stringForColumn:@"pics"];
        [picsarray addObject:db_pics];
        
        NSString *db_weather = [results stringForColumn:@"weather"];
        [weatherarray addObject:db_weather];
        
        int wentflag = [results intForColumn:@"went_flag"];
        [wentflagarray addObject:@(wentflag)];
        
        int db_hour = [results intForColumn:@"hour"];
        [hourarray addObject:@(db_date)];
        
        NSString *db_address = [results stringForColumn:@"address"];
        [addressarray addObject:db_address];
        
        //        int deleteflag = [results intForColumn:@"delete_flag"];
        
        NSLog(@"check1 %d,%@,%f,%f,%@,%d,%@,%@,%d,%d,%@"
              ,db_id,db_title,lat,lon,db_weather,db_date,db_text,db_pics,wentflag,db_hour,db_address
              );//確認表示
        
         //最終的にresltArrayに配列がそれぞれぼこっと入る感じで。
        i++;
    }
    
    NSLog(@"check2=====試しに配列の表示%@",weatherarray[0]);

    [database close];
    
    /* データ受け渡し用にぜんぶまとめてぶっこむ */

    [resultArray addObject:idarray];//0
    [resultArray addObject:titlearray];//1
    [resultArray addObject:latarray];//2
    [resultArray addObject:lonarray];//3
    [resultArray addObject:datearray];//4
    [resultArray addObject:textarray];//5
    [resultArray addObject:picsarray];//6
    [resultArray addObject:weatherarray];//7
    [resultArray addObject:wentflagarray];//8
    [resultArray addObject:hourarray]; //9
    [resultArray addObject:addressarray]; //10
    
//    NSLog(@"check3 ====%@",resultArray);
    return resultArray;
    

}
-(void)deleteData{ //削除フラグをたてるだけだけどね 未完了
    
}


-(NSString *)getAddressFromLat:(double)lat AndLot:(double)lot{ //引数が緯度、経度 ***********アラートなど最終的に要チェック*********
    
    NSDictionary *jsonObjectResults = nil;
    NSString *urlApi1 = @"http://maps.google.com/maps/api/geocode/json?latlng=";
    NSString *urlApi2 = @"&sensor=false";
    NSString *urlApi = [NSString stringWithFormat:@"%@%f,%f%@",urlApi1,lat,lot,urlApi2];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlApi]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    //sendSynchronousRequestメソッドでURLにアクセス
    NSHTTPURLResponse* resp;
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:nil];
    
    //通信エラーの際の処理
    if (resp.statusCode != 200){
  //      [self alertViewMethod];//アラートビュー出す
    }
    
    //返ってきたデータをJSONObjectWithDataメソッドで解析
    else{
        jsonObjectResults = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingAllowFragments error:nil];
        
        NSDictionary *status = [jsonObjectResults objectForKey:@"status"];
        NSString *statusString = [status description];
        
        if ([statusString isEqualToString:@"ZERO_RESULTS"]) {
//            [self alertViewMethod]; //アラートビュー出す
            NSLog(@"ZERO_RESULTS");
        }else{
            NSMutableArray *result = [jsonObjectResults objectForKey:@"results"];
//            NSString *str = [result description];
//            NSLog(@"%@",str);
            NSDictionary *dic = [result objectAtIndex:0];
            //NSString *str2 = [dic description];
            NSDictionary *dic2 = [dic objectForKey:@"formatted_address"];
            addressStr = [dic2 description];
//            NSLog(@"address=%@",addressStr);
            
        }
    }
    NSString *temp = addressStr;
    return temp;
}


-(void)saveData{ //通しナンバーを保存

    NSUserDefaults *savedata = [NSUserDefaults standardUserDefaults];
    [savedata setInteger:_dataid forKey:@"dataid"];//INTEGER型
    [savedata synchronize];

}

-(int)loadData{ //通しナンバーの読み込み
    
    NSUserDefaults *savedata = [NSUserDefaults standardUserDefaults];
    _dataid = [savedata integerForKey:@"dataid"];
    return  _dataid;
}



@end
