//
//  AlbumViewController.m
//  TripShot
//
//  Created by Komaya & Fujiwara on 2014/05/12.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import "AlbumViewController.h"
#import "CollectionCell.h"
#import "IndividualAlbumViewController.h"
#import "TSDataBase.h"

@interface AlbumViewController ()
{
    UIImageView *imageViewBackA;
    NSMutableArray *picture;
    NSMutableArray *picsCount;
    NSMutableArray *idarray;
    NSMutableArray *placeName;
    int deleteIdNumb;
    int idnumb;
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

//
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
    
    [self viewBackground];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(rowButtonAction:)];
//    longPressGestureRecognizer.minimumPressDuration = 0.3;
//    longPressGestureRecognizer.delegate = self;
    [_AlbumCollection addGestureRecognizer:longPressGestureRecognizer];
    
    //データ保存用のディレクトリを作成する
    [self makeDirForAppContents];

}



-(void)viewDidAppear:(BOOL)animated{

    [self.navigationController setNavigationBarHidden:YES];
    self.tabBarController.tabBar.hidden = NO;
    
    TSDataBase *db = [[TSDataBase alloc]init];
    NSMutableArray *DBData = [db loadDBData];
    
    picsCount = [[NSMutableArray alloc]init];
    
    placeName = DBData[1];
    picture = DBData[6];
    picsCount = DBData[7];
    idarray = DBData[0];
    
    //配列のいっこめをボタンにする
    [placeName insertObject:@"追加" atIndex:0];
    [picture insertObject:@"icon_1r_192.png" atIndex:0];
    
    [_AlbumCollection reloadData];

}



-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

{

    return placeName.count;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//セルをクリックされたら呼ばれるメソッド
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //追加ボタンをおした時
    if(indexPath.row == 0){
        
        TSDataBase *db = [[TSDataBase alloc]init];
        int count = [db CountNowData];
        
        if(count >= 20){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"確認"
                                                           message:@"これ以上登録できません"
                                                          delegate:nil
                                                 cancelButtonTitle:@"戻る"
                                                 otherButtonTitles:nil, nil];
            [alert show];
        }else{
        
        UINavigationController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchVC"];
        [self presentViewController:searchVC animated:YES completion:nil];
        }
        
    }else{
        
        NSLog(@"idarray=%@",[idarray description]);
        NSString *pathNumber = [idarray objectAtIndex:indexPath.row-1];
        idnumb = [pathNumber intValue];
        
        //        [self performSegueWithIdentifier:@"albumToIndividualAlbum" sender:self];//これを使う（石井）
        
        IndividualAlbumViewController *indiAVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IndividualAVC"];
        indiAVC.idFromMainPage = idnumb;
        [self.navigationController pushViewController:indiAVC animated:YES];
        
    }
}


//collectionView:cellForItemAtIndexPath:メソッドでセルの編集をする
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // スタイルを指定したセル生成
    static NSString *CellIdentifier =@"Cell";
    
    CollectionCell *cell = [collectionView
                            dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if([picture[indexPath.item] isEqualToString:@"icon_1r_192.png"]){//追加ボタン
        
      [[cell pictureView] setImage:[UIImage imageNamed:[picture objectAtIndex:indexPath.item]]];
    
    }else if ([picture[indexPath.item] isEqualToString:@"NODATA"]){//データが空のとき
        
        [[cell pictureView] setImage:[UIImage imageNamed:@"image1.jpg"]];

    }else{ //通常時。要注意。配列画像の画像の一枚目を表示する。（石井さんにきくこと）
        
        NSArray *arrayPicNotMutable = [picture[indexPath.item] componentsSeparatedByString:@","];
        NSLog(@"arrayPicNotMutable=%@",[arrayPicNotMutable description]);
        NSData *dataPics = [[NSData alloc] initWithContentsOfFile:[arrayPicNotMutable objectAtIndex:0]];
        UIImage* image = [[UIImage alloc] initWithData:dataPics];
        
        [[cell pictureView]setImage:image];
    }
    
    [[cell pictureDate] setText:[placeName objectAtIndex:indexPath.item]];

    return cell;
}


#pragma mark - EditCells

//長押しタイミングの取得および選択されたコンポーネントの取得
-(void)rowButtonAction:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:_AlbumCollection];
    NSIndexPath *indexPath = [_AlbumCollection indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"long press on table view");
    }else if (((UILongPressGestureRecognizer *)gestureRecognizer).state == UIGestureRecognizerStateBegan){
        //セルが長押しされた場合の処理
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"確認"
                                                       message:@"削除しますか\n（だいじょうぶいまは削除されない）"
                                                      delegate:self
                                             cancelButtonTitle:@"キャンセル"
                                             otherButtonTitles:@"はい", nil];
        [alert show];
        
        NSLog(@"取得したバスの数字%d",indexPath.row);
//ここでこの数字からレコードのidを取得する必要がある
        //        deleteIdNumb = indexPath.row;

    }
}



//-  (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
//    if (sender.state == UIGestureRecognizerStateEnded) {
//
//    }
//    else if (sender.state == UIGestureRecognizerStateBegan){
//
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"確認"
//                                                       message:@"削除しますか"
//                                                      delegate:self
//                                             cancelButtonTitle:@"キャンセル"
//                                             otherButtonTitles:@"はい", nil];
//        [alert show];
//    }
//}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    TSDataBase *db = [[TSDataBase alloc]init];

    switch(buttonIndex){
        case 0:

            break;
            
        case 1://「はい」のとき。
        
            [db DeleteFlag:deleteIdNumb];
            
            
            
            break;
            
    }
}


#pragma mark - Navigation (Arita)

-(void)initNavigationBar{ //念のため用意した
    //ナビゲーションバー
    UIImageView *navigationTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subtitle1.png"]];
    [navigationTitle setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = navigationTitle;
    [UINavigationBar appearance].tintColor = [UIColor colorWithRed:0.91 green:0.42 blue:0.41 alpha:1.0];
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.92 alpha:1.0];
    
}

-(void)viewBackground{
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    
    UIImage *imageData = [UIImage imageNamed:@"bright_img140514103609.jpg"];
    
    /* 背景画像の準備*/
    imageViewBackA = [[UIImageView alloc]initWithFrame:rect];
    imageViewBackA.image = imageData;
    imageViewBackA.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageViewBackA];
    [self.view sendSubviewToBack:imageViewBackA];

}


//Documentsフォルダにデータ保存用のフォルダを作成する関数
- (BOOL)makeDirForAppContents
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *baseDir = [self myDocumentsPath];
    
    BOOL exists = [fileManager fileExistsAtPath:baseDir];
    if (!exists) {
        NSError *error;
        BOOL created = [fileManager createDirectoryAtPath:baseDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!created) {
            NSLog(@"ディレクトリ作成失敗");
            return NO;
        }
    } else {
        //作成済みの場合はNO
        return NO;
    }
    return YES;
}


//データ保存用のフォルダのパスを返す関数
- (NSString *)myDocumentsPath
{
    //アプリのドキュメントフォルダのパスを検索
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //追加するディレクトリ名を指定
    NSString *picsFolderPath = [documentsPath stringByAppendingPathComponent:@"PicsFolder"];
    NSLog(@"PicsFolderPass=%@",picsFolderPath);
    return picsFolderPath;
}


@end