//
//  AlbumViewController.m
//  TripShot
//
//  Created by Komaya & Fujiwara on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "AlbumViewController.h"
#import "CollectionCell.h"
#import "TSDataBase.h"

@interface AlbumViewController ()
{
    NSMutableArray *picture;
//    NSMutableArray *date;
    NSMutableArray *placeName;
}
@end

@implementation AlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self AlbumCollection]setDataSource:self];
    [[self AlbumCollection]setDelegate:self];
    
//    picture = [[NSArray alloc]initWithObjects:@"image1.jpg",@"image2.jpg",@"image3.jpg",@"image4.jpg", nil];
//    date = [[NSArray alloc]initWithObjects:@"5/3",@"5/4",@"5/5",@"5/6", nil];
    
    TSDataBase *db = [[TSDataBase alloc]init];
    NSMutableArray *DBData = [db loadDBData];


/*  dateに、BDData[]の文字列をintからstringに変換して入れる。
    date = [[NSMutableArray alloc]init];
    NSMutableArray *temp = DBData[4];
    for(int i = 0 ; i<=DBData.count ; i++){
        
        date[i] = [NSString stringWithFormat:@"%@",temp[i]];//数字をそのまま変換してstringにした
        //最終的にyyyy年mm月dd日、という表記にしたい
    }
 
 */
    placeName = DBData[1];
    picture = DBData[6];
    
}






-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;//セクションの数を設定
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

//セクションに応じたセルの数を返す。
{

    return placeName.count;

}

//collectionView:cellForItemAtIndexPath:メソッドでセルの編集をする
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // スタイルを指定したセル生成
    static NSString *CellIdentifier =@"Cell";
    CollectionCell *cell = [collectionView
                            dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [[cell pictureView] setImage:[UIImage imageNamed:[picture objectAtIndex:indexPath.item]]];

    [[cell pictureDate] setText:[placeName objectAtIndex:indexPath.item]];

    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
