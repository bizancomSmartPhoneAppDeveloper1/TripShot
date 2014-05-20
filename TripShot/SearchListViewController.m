//
//  SearchListViewController.m
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/13.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import "SearchListViewController.h"
#import "TSDataBase.h"

@interface SearchListViewController (){
    
    UIImageView *imageViewBackB;

}

@property NSMutableArray *items;
@property NSMutableArray *nameArray;
@property NSMutableArray *locationArray;
@property NSMutableArray *addressArray;
@property NSString *savedLat;
@property NSString *savedLon;

@end

@implementation SearchListViewController{
    
}

NSString * const APIKEY = @"dj0zaiZpPXpXNGNjRWtiNG83ViZzPWNvbnN1bWVyc2VjcmV0Jng9MmM-";


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIBarButtonItem *backitem = [[UIBarButtonItem alloc]initWithTitle:@"もどる" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
//    self.navigationItem.leftBarButtonItem = backitem;
    

    //サーチバーの定義
    _searchField.delegate = self;
    _searchField.placeholder = @"行きたい場所を入力してね！";
    
    [self viewBackground];
    [self initNavigationBar];
    [self loadLocationData];
}

-(NSString *)barricadeString:(NSString *)word{
    NSString *barricadedString;
    
    //含まれてたらアレな文字って言ったら
    // % APIKEY # とか？ここでおきかえるよ
    
    
    return barricadedString;
}


-(void)getJsonFromWord:(NSString *)word{
    
    //ここで一旦wordを検査する必要がある
    //NSString *barricadedString = [self barricadeString:word];
    
    
    _nameArray = [[NSMutableArray alloc]init]; //店名一覧格納
    _locationArray = [[NSMutableArray alloc]init]; //緯度経度格納
    _addressArray = [[NSMutableArray alloc]init]; //表示住所格納
    
    // UTF-8でエンコード
    NSString *encodedString = [word stringByAddingPercentEscapesUsingEncoding:
                               NSUTF8StringEncoding];
    
    //現在地に近い順でソートする 現時点では遠いところは表示されないみたいなのでいったんコメントアウト
    //NSString *path = [NSString stringWithFormat:@"http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch?appid=%@&query=%@&output=json&lat=%@&lon=%@&sort=geo",APIKEY,encodedString,_savedLat,_savedLon];
    
    NSString *path = [NSString stringWithFormat:@"http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch?appid=%@&query=%@&output=json",APIKEY,encodedString];


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
        
        for(int i = 0 ; i < arrayResult.count ; i++){
            
            NSDictionary *resultDic = [arrayResult objectAtIndex:i];
            
            //表示させる地点名
            NSString *storeName = [resultDic objectForKey:@"Name"];
            [_nameArray addObject:storeName];
            
            //緯度経度情報
            NSMutableDictionary *tempgeomerty = [resultDic objectForKey:@"Geometry"];
            NSString *geometry = [tempgeomerty objectForKey:@"Coordinates"];
            [_locationArray addObject:geometry];
            
            //緯度経度を２つに分割する
            NSArray *locations = [geometry componentsSeparatedByString:@","];
            NSString *stringLon = locations[0];
            NSString *stringLat = locations[1];
            double doubleLon = stringLon.doubleValue;
            double doubleLat = stringLat.doubleValue;
            
            //住所に変換
            TSDataBase *db = [[TSDataBase alloc]init];
            NSString *address = [db getAddressFromLat:doubleLat AndLot:doubleLon];
            [_addressArray addObject:address];
        }
        
        NSLog(@"result NameArray : %@",_nameArray);//店名一覧。
        NSLog(@"result locationArray : %@",_locationArray);//NSStringで（lat,lot)となっている。
        NSLog(@"result addressArray : %@",_addressArray);
        
    }else{
        
        NSLog(@"the connection could not be created or if the download fails.");
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
}

//サーチボタンタップ時に呼ばれる
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString *word = _searchField.text;
    [_searchField resignFirstResponder];
    [self getJsonFromWord:word];

    //検索結果がからっぽだったとき(JSONDataのResultInfoのCountが0のとき）-------------------------
    //の処理をここにかく。
    
    [_TableView reloadData];
    
    
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
    CGRect rect = CGRectMake(0, 0, width, height);
    
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
    UIImageView *navigationTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subtitle2.png"]];
    
    [navigationTitle setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = navigationTitle;
    
}


@end
