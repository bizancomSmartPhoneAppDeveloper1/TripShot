//
//  AlbumViewController.m
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "AlbumViewController.h"
#import "CollectionCell.h"

@interface AlbumViewController ()

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
    // Do any additional setup after loading the view.
    
    [[self AlbumCollection]setDataSource:self];
    [[self AlbumCollection]setDelegate:self];
}

//-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;//セクションの数を設定
//{
//    return 1;
//}
//
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
//
////セクションに応じたセルの数を返す。
//{
//    return [picture count];
//}
//
////collectionView:cellForItemAtIndexPath:メソッドでセルの編集をする
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
//                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    // スタイルを指定したセル生成
//    static NSString *CellIdentifier =@"Cell";
//    CollectionCell *cell = [collectionView
//                            dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    [[cell seapicture] setImage:[UIImage imageNamed:[picture objectAtIndex:indexPath.item]]];
//    [[cell pictureLabel] setText:[namelabel objectAtIndex:indexPath.item]];
//    
//    return cell;
//}

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
