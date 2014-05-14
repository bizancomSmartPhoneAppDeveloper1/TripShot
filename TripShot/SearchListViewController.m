//
//  SearchListViewController.m
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "SearchListViewController.h"
#import "TSDataBase.h"

@interface SearchListViewController (){

}

@property NSMutableArray *items;
@property NSMutableArray *nameArray;
@property NSMutableArray *locationArray;

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

    //サーチバーの定義
    _searchField.delegate = self;
    _searchField.placeholder = @"検索したい場所を入力";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
-(void)getJsonFromWord:(NSString *)word{
    
    _nameArray = [[NSMutableArray alloc]init]; //店名一覧格納
    _locationArray = [[NSMutableArray alloc]init]; //緯度経度格納

    // UTF-8でエンコード
    NSString *encodedString = [word stringByAddingPercentEscapesUsingEncoding:
                               NSUTF8StringEncoding];
    
    NSString *path = [NSString stringWithFormat:@"http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch?appid=%@&query=%@&output=json",APIKEY,encodedString];
    
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //WebAPIからNSData形式でJSONデータを取得
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(jsonData){
        
        NSError *jsonParsingError = nil;
        //JSONからNSDictionaryまたはNSArrayに変換
        //JSONによって、配列ならばNSArrayになりそうでなければNSDictionaryとなる
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonParsingError];
        NSLog(@"%@",dic);
        
        //NSDictionaryを利用して、必要なデータを取得する
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

        }
        
        NSLog(@"result NameArray : %@",_nameArray);//店名一覧。
        NSLog(@"result locationArray : %@",_locationArray);//NSStringで（lat,lot)となっている。
        
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = _nameArray[indexPath.row];
    return cell;
}

//セルタップ時に呼び出される
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    //必要な情報取得
    NSString *name = [_nameArray objectAtIndex:indexPath.row];
    NSString *location = [_locationArray objectAtIndex:indexPath.row];

    NSLog(@"ちゃんと緯度経度表示されるかな：%@",location);
    
    //緯度経度を２つに分割する
    NSArray *locations = [location componentsSeparatedByString:@","];
    NSString *lon1 = locations[0];
    NSString *lat1 = locations[1];
    double lon2 = lon1.doubleValue;
    double lat2 = lat1.doubleValue;
    
    //DBにデータを追加
    TSDataBase *db = [[TSDataBase alloc]init];
    [db createDBDataFromLat:lat2 andLot:lon2 andTitle:name];
    
    //アラート表示
    NSString *message = [NSString stringWithFormat:@"行きたいところに%@を追加しました",name];
    UIAlertView *alert =
    [[UIAlertView alloc]initWithTitle:@"おしらせ"
                              message:message
                             delegate:nil
                    cancelButtonTitle:nil
                    otherButtonTitles:@"OK", nil];
    [alert show];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)cancelButtonTapped:(id)sender {
    
        [self dismissViewControllerAnimated:YES completion:NULL];
}

//これいるんかな？いらん気がする。内容要検討

- (IBAction)addButtonTapped:(id)sender {
    TSDataBase *db = [[TSDataBase alloc]init];
//    [db makeDatabase];
    [db createDBData];
    
    [self.tableView reloadData];
}

//サーチボタンタップ時に呼ばれる
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    NSString *word = _searchField.text;
    [_searchField resignFirstResponder];
    [self getJsonFromWord:word];
    [_TableView reloadData];

}


@end
