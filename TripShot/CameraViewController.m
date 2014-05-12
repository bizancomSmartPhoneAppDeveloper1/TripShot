//
//  CameraViewController.m
//  TripShot
//
//  Created by bizan.com.mac09 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController (){
    UIImageView *imageViewBack;
    BOOL boolDidAppear;
}


@end

@implementation CameraViewController

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
    [self viewMethod];
    boolDidAppear = NO;
    
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    if (boolDidAppear == NO) {
        [self startCamera];
    }
    //[self startCamera];
    
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
-(void)startCamera{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  //カメラを使用できるかチェック
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;  //UIImagePickerを作りViewControllerがUIImagePickerControllerのデリゲートとする
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;  //画像の入力ソースをカメラからの画像入力に
        imagePicker.allowsEditing = YES;  //allowsEditingがYESで撮影後自動的に画像編集シーンに移行する
        
        [self presentViewController:imagePicker animated:YES completion:nil];  //カメラ機能開始
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //カメラが呼び出され、cancelボタンが押されると呼び出されるメソッド
    [self dismissViewControllerAnimated:YES completion:nil];  //撮影モード終了
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //カメラのusePhotoボタンがタップされた時のメソッド 引数infoはNSDictionaryクラスの辞書オブジェクト
    //UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];  //撮影したそのままの画像データを取り出す
    //    UIImage *editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];  //編集済み画像データを取り出す
    
    editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    
    self.myImageView.image = editedImage;
    
    self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil);  //編集済みの画像をカメラロールに保存する
    //UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);  //撮影したそのままの画像をカメラロールに保存
    
    [self dismissViewControllerAnimated:YES completion:nil];  //カメラ機能終了
    boolDidAppear = YES;

    
}

- (void)viewMethod{
    
    CGRect daterect = CGRectMake(90, 400, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:daterect];
    dateLabel.text = @" ５月　１２日（火）";
    dateLabel.textColor = [UIColor blueColor];
    dateLabel.font = [UIFont boldSystemFontOfSize:20];
    
    [self.view addSubview:dateLabel];
    
    CGRect placerect = CGRectMake(90, 430, 220, 50);
    UILabel *placeLabel = [[UILabel alloc]initWithFrame:placerect];
    placeLabel.text = @"   ○○○　Cafe ♪";
    placeLabel.textColor = [UIColor blueColor];
    placeLabel.font = [UIFont boldSystemFontOfSize:25];
    
    [self.view addSubview:placeLabel];
    
    
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    
    UIImage *imageData = [UIImage imageNamed:@"free-textures-japanese-style-06.jpg"];
    
    /* 背景画像の準備*/
    imageViewBack = [[UIImageView alloc]initWithFrame:rect];
    imageViewBack.image = imageData;
    imageViewBack.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageViewBack];
    [self.view sendSubviewToBack:imageViewBack];
}


@end
