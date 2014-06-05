//
//  SearchListViewController.m
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/13.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import "SearchListViewController.h"
#import "TSDataBase.h"
#import "Reachability.h"
#import "OHAttributedLabel.h"




@class Reachability;

@interface SearchListViewController (){
    
    UIImageView *imageViewBackB;
    
    Reachability *hostReach;        //ホスト接続
    Reachability *internetReach;    //3Gネットワーク
    Reachability *wifiReach;        //Wi-Fi

}

@property NSMutableArray *items;
@property NSMutableArray *nameArray;
@property NSMutableArray *locationArray;
@property NSMutableArray *addressArray;
@property NSString *savedLat;
@property NSString *savedLon;
@property OHAttributedLabel *yahooLabel;

@end

@implementation SearchListViewController{
    
}

NSString * const APIKEY = @"dj0zaiZpPXpXNGNjRWtiNG83ViZzPWNvbnN1bWVyc2VjcmV0Jng9MmM-";


- (void)viewDidLoad
{
    [super viewDidLoad];

    //サーチバーの定義
    _searchField.delegate = self;
    _searchField.placeholder = @"例：丸の内 スタバ";
    
    [self viewBackground];
    [self initNavigationBar];
    [self loadLocationData];
    [self reachabilityStart];
    
    
    /* YahooAPIのクレジット表記追記 */
    
    
    //Viewを画面下部に追加
    UIScreen *screenSize = [UIScreen mainScreen];
    CGRect rect = screenSize.bounds;
    
    //Labelを生成
    CGRect yahooRect = CGRectMake(15, rect.size.height-95, rect.size.width, rect.size.height);
    _yahooLabel = [[OHAttributedLabel alloc]initWithFrame:yahooRect];
    
    //表示する文字列を指定
    NSString *text = @"Web Services by Yahoo! JAPAN";
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:text];
    NSURL *linkUrl = [NSURL URLWithString:@"http://developer.yahoo.co.jp/about"];
    NSRange linkRange = [text rangeOfString:text];
    [attrStr setLink:linkUrl range:linkRange];
    [attrStr setTextColor:[UIColor blackColor]];
    _yahooLabel.attributedText = attrStr;
    [self.view addSubview:_yahooLabel];
    
}



-(void)getJsonFromWord:(NSString *)word{
    
    _nameArray = [[NSMutableArray alloc]init]; //店名一覧格納
    _locationArray = [[NSMutableArray alloc]init]; //緯度経度格納
    _addressArray = [[NSMutableArray alloc]init]; //表示住所格納
    
    // UTF-8でエンコード
    NSString *encodedString = [word stringByAddingPercentEscapesUsingEncoding:
                               NSUTF8StringEncoding];
    
    //初動として20件のみ取得
    NSString *path = [NSString stringWithFormat:@"http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch?appid=%@&device=mobile&query=%@&results=20&output=json",APIKEY,encodedString];


    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //WebAPIからNSData形式でJSONデータを取得
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(jsonData){
        
        NSError *jsonParsingError = nil;
        //JSONからNSDictionaryまたはNSArrayに変換
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonParsingError];
        NSLog(@"%@",dic);
        
        NSArray *arrayResult = [dic objectForKey:@"Feature"];
        NSLog(@"arrayResult.count=%d",arrayResult.count);
        
        if(arrayResult.count != 0){
        
        for(int i = 0 ; i < arrayResult.count ; i++){
            
            NSDictionary *resultDic = [arrayResult objectAtIndex:i];
            
            //表示させる地点名
            NSString *storeName = [resultDic objectForKey:@"Name"];
            if (![storeName isEqualToString:nil]) {
            [_nameArray addObject:storeName];
                NSLog(@"storeName=%@",storeName);
            }
            
            //緯度経度情報
            NSMutableDictionary *tempgeomerty = [resultDic objectForKey:@"Geometry"];
            NSString *geometry = [tempgeomerty objectForKey:@"Coordinates"];
            NSLog(@"geometry=%@",geometry);
            if (![geometry isEqualToString:nil]) {
            [_locationArray addObject:geometry];
            }
            
            //緯度経度を２つに分割する
            NSArray *locations = [geometry componentsSeparatedByString:@","];
            NSString *stringLon = locations[0];
            NSString *stringLat = locations[1];
            double doubleLon = stringLon.doubleValue;
            double doubleLat = stringLat.doubleValue;
            
            //住所に変換
            TSDataBase *db = [[TSDataBase alloc]init];
            NSString *address = [db getAddressFromLat:doubleLat AndLot:doubleLon];
            if (![address isEqualToString:nil]) {
            [_addressArray addObject:address];
            }
            NSLog(@"_addressArray=%@",[_addressArray description]);
            NSLog(@"count=%d",i);
        }
        
            NSLog(@"result NameArray : %@",_nameArray);//店名一覧。
            NSLog(@"result locationArray : %@",_locationArray);//NSStringで（lat,lot)となっている。
            NSLog(@"result addressArray : %@",_addressArray);
            
        }else if(arrayResult.count == 0){
        
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ごめんね！"
                                                           message:@"検索結果が見つかりませんでした"
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"他のキーワードで探す", nil];
            [alert show];
        }

    }else{
        
        NSLog(@"the connection could not be created or if the download fails.");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ごめんね！"
                                                       message:@"ネットワーク接続が切れました"
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"戻る", nil];
        [alert show];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return  _nameArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.textLabel.text = _nameArray[indexPath.row];
    cell.detailTextLabel.text = _addressArray[indexPath.row];

    return cell;
}


//セルタップ時に呼び出される
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    //必要な情報取得
    NSString *name = [_nameArray objectAtIndex:indexPath.row];
    NSString *location = [_locationArray objectAtIndex:indexPath.row];
    
    //緯度経度を２つに分割する
    NSArray *locations = [location componentsSeparatedByString:@","];
    NSString *lon1 = locations[0];
    NSString *lat1 = locations[1];
    double lon2 = lon1.doubleValue;
    NSLog(@"lon=%f",lon2);
    double lat2 = lat1.doubleValue;
    NSLog(@"lat=%f",lat2);
    
    //DBにデータを追加
    TSDataBase *db = [[TSDataBase alloc]init];
    [db createDBDataFromLat:lat2 andLot:lon2 andTitle:name];
    
    //アラート表示
    NSString *message = [NSString stringWithFormat:@"行きたいところに\n%@\nを追加しました",name];
    UIAlertView *alert =
    [[UIAlertView alloc]initWithTitle:@"おしらせ"
                              message:message
                             delegate:nil
                    cancelButtonTitle:nil
                    otherButtonTitles:@"OK", nil];
    [alert show];

//画面を一旦クリアする
    _nameArray = nil;
    _addressArray = nil;
    _locationArray = nil;
    
    [_TableView reloadData];
}


//入力開始時
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{

    _searchField.text = nil;
    
    //20件になったら警告
    TSDataBase *db = [[TSDataBase alloc]init];
    int count = [db CountNowData];
    
    if(count >= 20){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"確認"
                                                       message:@"これ以上登録できません"
                                                      delegate:nil
                                             cancelButtonTitle:@"戻る"
                                             otherButtonTitles:nil, nil];
        [alert show];
    }
    _yahooLabel.hidden = NO;
    
}

//サーチボタンタップ時に呼ばれる
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString *word = _searchField.text;
    [_searchField resignFirstResponder];
    [self getJsonFromWord:word];
    
    [_TableView reloadData];
    _yahooLabel.hidden = YES;
    
}


-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    //
    //  NSLog(@"%dのセルが表示完了したときの動作　追加するときに書く",indexPath.row);

}

-(void)loadLocationData{
    NSUserDefaults *savedata = [NSUserDefaults standardUserDefaults];
    _savedLat = [savedata stringForKey:@"latFromMainPage"];
    _savedLon = [savedata stringForKey:@"lonFromMainPage"];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    UIColor *backcolor = [UIColor whiteColor];
    UIColor *alpha = [backcolor colorWithAlphaComponent:0.0];
    cell.backgroundColor = alpha;

}

- (IBAction)cancelButtonTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - ナビゲーションバー設定

-(void)viewBackground{
    
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;
    CGRect rect = CGRectMake(0, 0, width, height*2.2);
    
    UIImage *imageData = [UIImage imageNamed:@"kinari_img140514103609.jpg"];
    
    /* 背景画像の準備*/
    imageViewBackB = [[UIImageView alloc]initWithFrame:rect];
    imageViewBackB.image = imageData;
    imageViewBackB.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageViewBackB];
    [self.view sendSubviewToBack:imageViewBackB];
    
}

-(void)initNavigationBar{
    //ナビゲーションバー
    UIImageView *navigationTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screentitle3.png"]];
    
    [navigationTitle setContentMode:UIViewContentModeScaleAspectFit];
    
    self.navigationItem.titleView = navigationTitle;

}

//ネットワーク接続状況確認
- (void) updateInterfaceWithReachability:(Reachability*)curReach
{
	// 接続状態を取得
	NetworkStatus status = [curReach currentReachabilityStatus];
/*
    // ホスト接続 1において
	if(curReach == hostReach)
	{
		if( status == NotReachable )//届いてないとき
		{
			NSLog(@"Host connection is failed.");
            //ホストにつながらないアラート出す
            UIAlertView *hostConnectionFailedAlert = [[UIAlertView alloc]initWithTitle:@"ごめんね！" message:@"現在検索が利用できません" delegate:nil cancelButtonTitle:@"戻る" otherButtonTitles:nil, nil];
            [hostConnectionFailedAlert show];
		}
    }
 */
    
	// Wi-Fi接続 2
	if(curReach == wifiReach)
	{
		if( status == NotReachable )
		{
			NSLog(@"Wi-Fi is failed.");//3Gかどうか確認する
           /* UIAlertView *connectionAlert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"ネットワークに接続されていません" delegate:nil cancelButtonTitle:@"戻る" otherButtonTitles:nil, nil];
            [connectionAlert show];
            */
            // 3Gネットワーク接続 3
            if(curReach == internetReach)
            {
                if( status == NotReachable )
                {
                    NSLog(@"3G network is failed.");//wifiも3Gもだめなのでアラート出す
                    
                    UIAlertView *connectionAlert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"ネットワークに接続されていません" delegate:nil cancelButtonTitle:@"戻る" otherButtonTitles:nil, nil];
                    [connectionAlert show];
                }
            }
		}
	}
    

    
}

// ネットワーク接続状況確認
- (void)reachabilityStart
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
/*
    // ホスト接続を確認
    hostReach = [Reachability reachabilityWithHostName: @"search.olp.yahooapis.jp"];
    [hostReach startNotifier];
    [self updateInterfaceWithReachability: hostReach];
*/
    
    // 3G接続を確認
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateInterfaceWithReachability: internetReach];
    
    // Wi-Fi接続を確認
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    [self updateInterfaceWithReachability: wifiReach];
}

// ネットワーク接続の状態が変化したときに呼ばれる
- (void)reachabilityChanged:(NSNotification*)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}



@end
