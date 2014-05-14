//
//  CameraViewController.m
//  TripShot
//
//  Created by bizan.com.mac09 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController (){
    TSDataBase *tsdatabase;
    UIImageView *imageViewBack;
    UITextField *textfield;
    NSString *address;
    NSMutableArray *array;
    NSDate *date;
    NSString *comment;
    NSMutableArray *picsArray;
    NSString *pics;
    int picsCount;
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

    array = [[NSMutableArray alloc]init];
    picsArray = [[NSMutableArray alloc]init];
    
    //TSDataBaseのインスタンス化
    tsdatabase = [[TSDataBase alloc]init];
    
    
    //仮にDBを作成　問題無し
    //[tsdatabase makeDatabase];
    
    //仮にtableをinsert　問題無し
    //[tsdatabase createDBData];
    
    //各表示
    [self viewMethod];
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
    //UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil);  //編集済みの画像をカメラロールに保存する
    
    [array addObject:editedImage];
    self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.myImageView.animationImages = array;
    self.myImageView.animationDuration = 3.0;
    self.myImageView.animationRepeatCount = 0;
    [self.myImageView startAnimating];
    //UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);  //撮影したそのままの画像をカメラロールに保存
    
    //pathを取得
    //NSURL *url = (NSURL *)[info objectForKey:UIImagePickerControllerEditedImage];
    
    //PNG形式で0.5に圧縮してシリアライズ化
    NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.5);
    
    //一旦配列に保存
    //カメラロールに保存したパスを配列として渡す場合
    //[picsArray addObject:url];
    //シリアライズ化した情報を配列として渡す場合
    [picsArray addObject:imageData];
    
    //カメラ機能終了
    [self dismissViewControllerAnimated:YES completion:nil];

}



- (void)viewMethod{
    
    //メイン画面から受け渡されるID 仮に0とする。
    self.idFromMainPage = 0;
    NSMutableArray *resultArray = [tsdatabase loadDBDataOnCamera:self.idFromMainPage];
    
    
    /*
     //シリアライズ化した情報を取り出して画像表示
    pics = [resultArray objectAtIndex:6];
    NSArray *arrayPicNotMutable = [pics componentsSeparatedByString:@","];
    NSLog(@"%@",[arrayPicNotMutable objectAtIndex:1]);
    NSLog(@"%d",[[resultArray objectAtIndex:7] intValue]);
    NSData *data= [[NSData alloc]initWithData:[arrayPicNotMutable objectAtIndex:0]];
    UIImage* image = [[UIImage alloc] initWithData:data];
    
     //ここから出来ない
    for (int i=0; i<[[resultArray objectAtIndex:7] intValue]; i++) {
         UIImage* image = [[UIImage alloc] initWithData:[arrayPicNotMutable objectAtIndex:i]];
        [array addObject:image];
     }
    self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.myImageView.animationImages = array;
    self.myImageView.animationDuration = 3.0;
    self.myImageView.animationRepeatCount = 0;
    [self.myImageView startAnimating];
    */
    
    //行きたい場所リストタイトル表示
    CGRect titleRect = CGRectMake(90, 320, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleRect];
    //仮に入力
    titleLabel.text = [resultArray objectAtIndex:1];
    titleLabel.textColor = [UIColor blueColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [self.view addSubview:titleLabel];
    
    
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
    
    CGRect daterect = CGRectMake(90, 370, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:daterect];
    dateLabel.text = [NSString stringWithFormat:@"%d月　%d日",(int)dateComps.month,(int)dateComps.day];
    dateLabel.textColor = [UIColor blueColor];
    dateLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:dateLabel];
    
    
    //住所情報入力
    CGRect addressRect = CGRectMake(90, 400, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:addressRect];
    //仮に入力
    addressLabel.text = [resultArray objectAtIndex:11];
    addressLabel.textColor = [UIColor blueColor];
    addressLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.view addSubview:addressLabel];
    
    //コメント欄
    //コメントを入れる時にコメント欄を上にスクロールすることが必要
    CGRect textRect = CGRectMake(90, 430, 220, 50);
    textfield = [[UITextField alloc]initWithFrame:textRect];
    textfield.text = @"コメントを入れてね♪";
    textfield.textColor = [UIColor blueColor];
    textfield.font = [UIFont boldSystemFontOfSize:10];
    textfield.returnKeyType = UIReturnKeyDefault;
    textfield.delegate = self;
    [self.view addSubview:textfield];
    
    
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



/* 使わない
//住所webAPI
- (NSString *)webAPI:(double)lat LONG:(double)lon{
    NSDictionary *jsonObjectResults =nil;
    NSString *urlApi1 = @"http://maps.google.com/maps/api/geocode/json?latlng=";
    //double lat= 34.070162;
    //double lon= 134.556246;
    NSString *urlApi2 = @"&sensor=false";
    NSString *urlApi = [NSString stringWithFormat:@"%@%f,%f%@",urlApi1,lat,lon,urlApi2];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlApi]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    //sendSynchronousRequestメソッドでURLにアクセス
    NSHTTPURLResponse* resp;
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:nil];
    
    //通信エラーの際の処理を考える必要がある
    if (resp.statusCode != 200){
        [self alertViewMethod];
    }
    
    //返ってきたデータをJSONObjectWithDataメソッドで解析
    else{
        jsonObjectResults = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingAllowFragments error:nil];
        
        NSDictionary *status = [jsonObjectResults objectForKey:@"status"];
        NSString *statusString = [status description];
        
        if ([statusString isEqualToString:@"ZERO_RESULTS"]) {
            [self alertViewMethod];
            NSLog(@"ZERO_RESULTS");
        }else{
            NSMutableArray *result = [jsonObjectResults objectForKey:@"results"];
            //NSString *str = [result description];
            //NSLog(@"%@",str);
            NSDictionary *dic = [result objectAtIndex:0];
            //NSString *str2 = [dic description];
            NSDictionary *dic2 = [dic objectForKey:@"formatted_address"];
            NSString *fullAddress = [dic2 description];
            address = [fullAddress substringFromIndex:3];
        }
    }
    return address;
}

//読み込み失敗時に呼ばれる関数
- (void)alertViewMethod{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"読み込みに失敗しました"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}

*/






//main画面に戻る際の関数。
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cameraViewToMainView"]) {
        
        //ここでDBに保存する処理を書く
        //日付情報 変数date
        //本文情報 変数comment
        //写真情報　変数picsと写真数picsCount
        pics = [picsArray componentsJoinedByString:@","];
        //NSLog(@"pics=%@",pics);
        //pics = @"testtest";//仮
        picsCount =[picsArray count];
        //picsCount = 2;//仮
        NSLog(@"count=%d",picsCount);
        comment = textfield.text;

        //DBへ上書き保存　仮にidは0に設定
        [tsdatabase updateDBDataOnCamera:self.idFromMainPage TEXT:comment PICS:pics PICCOUNT:picsCount];
    }
}


@end
