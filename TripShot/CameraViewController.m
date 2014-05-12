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
    NSMutableArray *array;
    NSDate *date;
    NSString *comment;
    NSMutableArray *picsArray;
    NSString *pics;
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
    array = [[NSMutableArray alloc]init];
    picsArray = [[NSMutableArray alloc]init];
    
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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

- (IBAction)takePhoto:(UIButton *)sender {
    [self startCamera];
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
    
    //self.myImageView.image = editedImage;
    
    //self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    
    //とりあえずカメラロールに保存されたものを使用するが、アプリ専用のフォルダに保存することを検討が必要
    UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil);  //編集済みの画像をカメラロールに保存する
    
    [array addObject:editedImage];
    self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.myImageView.animationImages = array;
    self.myImageView.animationDuration = 3.0;
    self.myImageView.animationRepeatCount = 0;
    [self.myImageView startAnimating];
    //UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);  //撮影したそのままの画像をカメラロールに保存
    
    //pathを取得
    NSURL *url = (NSURL *)[info objectForKey:UIImagePickerControllerEditedImage];
    //一旦配列に保存
    [picsArray addObject:url];
    
    //カメラ機能終了
    [self dismissViewControllerAnimated:YES completion:nil];

}



- (void)viewMethod{
    
    
    //行きたい場所リストタイトル表示
    CGRect titleRect = CGRectMake(90, 320, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleRect];
    //仮に入力
    titleLabel.text = @"眉山";
    titleLabel.textColor = [UIColor blueColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [self.view addSubview:titleLabel];
    
    //住所情報入力
    CGRect addressRect = CGRectMake(90, 380, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:addressRect];
    //仮に入力
    addressLabel.text = @"徳島県徳島市";
    addressLabel.textColor = [UIColor blueColor];
    addressLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:addressLabel];
    
    
    //日付入力
    date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit |
                 NSMonthCalendarUnit  |
                 NSDayCalendarUnit    |
                 NSHourCalendarUnit   |
                 NSMinuteCalendarUnit |
                 NSSecondCalendarUnit
                            fromDate:date];
    
    CGRect daterect = CGRectMake(90, 400, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:daterect];
    dateLabel.text = [NSString stringWithFormat:@"%d月　%d日",(int)dateComps.month,(int)dateComps.day];
    dateLabel.textColor = [UIColor blueColor];
    dateLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:dateLabel];
    
    
    //コメント欄
    //コメントを入れる時にコメント欄を上にスクロールすることが必要
    CGRect textRect = CGRectMake(90, 430, 220, 50);
    UITextField *textField = [[UITextField alloc]initWithFrame:textRect];
    textField.text = @"コメントを入れてね♪";
    comment = textField.text;
    textField.textColor = [UIColor blueColor];
    textField.font = [UIFont boldSystemFontOfSize:10];
    textField.returnKeyType = UIReturnKeyDefault;
    textField.delegate = self;
    [self.view addSubview:textField];
    
    
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



//textfieldでリターンキーが押されるとキーボードを隠す
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


//main画面に戻る際の関数。
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cameraViewToMainView"]) {
       
        //ここでDBに保存する処理を書く
        //日付情報 変数date
        
        //本文情報 変数comment
        
        //写真情報　変数pics
        pics = [picsArray description];
        NSLog(@"pics=%@",pics);
        
        
    }
}


@end
