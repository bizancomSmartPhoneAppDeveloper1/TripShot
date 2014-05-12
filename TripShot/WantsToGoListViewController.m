//
//  WantsToGoListViewController.m
//  TripShot
//
//  Created by bizan.com.mac05 on 2014/05/11.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "WantsToGoListViewController.h"


@interface WantsToGoListViewController ()
@property NSMutableArray *idArray;
@property NSMutableArray *titleArray;
@property NSMutableArray *latArray;
@property NSMutableArray *lotArray;
@property NSMutableArray *addressArray;//緯度経度情報から住所を表示

@end

@implementation WantsToGoListViewController{
}

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    //使うデータをここで読み込む
    TSDataBase *db = [[TSDataBase alloc]init];
    [db makeDatabase];
    [db createDBData];
    
//    [db loadData];

    NSMutableArray *resultArray = [db loadDBData];
    //ここにはそれぞれの配列がぼこっと入ってう。（deleteflagが0のやつね）
    //必要な項目の配列をこの中から取り出すよ（中身もNSMutableArray）
    //必要な項目？…id0、場所1、住所（つまり緯度2経度3）
    
    _idArray = [[NSMutableArray alloc]init];
    _idArray = resultArray[0];

    _titleArray = [[NSMutableArray alloc]init];
    _titleArray = resultArray[1];

    _latArray = [[NSMutableArray alloc]init];
    _latArray = resultArray[2];
    
    _lotArray = [[NSMutableArray alloc]init];
    _lotArray = resultArray[3];

    NSLog(@"できるはずのセル個数%d",_idArray.count);

    /*　テスト */
    NSNumber *temp1 = _latArray[0];
    NSNumber *temp2 = _lotArray[0];
    
    NSString *tempstr = [db getAddressFromLat:[temp1 doubleValue] AndLot:[temp2 doubleValue]];
    NSLog(@"住所%@",tempstr);
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
    //リストのアイテム数が行になる
    //ここではidが入っているものを一覧にしようか
    return _idArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
//配列からアイテムを取得してLabelのテキストに入れる
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.detailTextLabel.text = _addressArray[indexPath.row];
    
    return cell;
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
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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

@end
