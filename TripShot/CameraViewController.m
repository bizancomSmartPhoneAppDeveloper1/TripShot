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
    
    NSString *path;
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
    
    editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    
    
    NSData *data = UIImageJPEGRepresentation(editedImage, 0.5);
    
    // 保存するディレクトリを指定します
    // ここではデータを保存する為に一般的に使われるDocumentsディレクトリ
    
    
    //50枚まで写真を撮れるようにした
    int counter = 50;
    while (counter >= 0) {
        path = [NSString stringWithFormat:@"%@/TSpicture%d-%d.jpg",
            [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],self.idFromMainPage,counter];
    
    if ([[NSURL fileURLWithPath:path] checkResourceIsReachableAndReturnError:nil] == YES) {
        path = [NSString stringWithFormat:@"%@/TSpicture%d-%d.jpg",
                [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],self.idFromMainPage,counter+1];
        break;
    }else{
        path = [NSString stringWithFormat:@"%@/TSpicture%d-0.jpg",
                [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],self.idFromMainPage];
    }
        counter --;
        NSLog(@"counter=%d",counter);
    }
    
    // NSDataのwriteToFileメソッドを使ってファイルに書き込みます
    // atomically=YESの場合、同名のファイルがあったら、まずは別名で作成して、その後、ファイルの上書きを行います
    if ([data writeToFile:path atomically:YES]) {
        NSLog(@"save OK");
    } else {
        NSLog(@"save NG");
    }
    NSLog(@"path=%@",path);
    
    [picsArray addObject:path];


    //カメラロールに保存されたものを使用する
    //UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil);  //編集済みの画像をカメラロールに保存する
    
    [array addObject:editedImage];
    self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.myImageView.animationImages = array;
    NSLog(@"array=%@",[array description]);
    self.myImageView.animationDuration = 3.0;
    self.myImageView.animationRepeatCount = 0;
    [self.myImageView startAnimating];
    //UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);  //撮影したそのままの画像をカメラロールに保存
    

    //カメラ機能終了
    [self dismissViewControllerAnimated:YES completion:nil];

     
}



- (void)viewMethod{
    
    //渡されるplace_name,lat,longをビザンコムに仮にする。実際はplace_nameのみで引っ張っている
    NSMutableArray *resultarray = [tsdatabase loadLatLonPlaceName:@"ビザンコム株式会社" LAT:34.061901111111 LON:1134.566681111111];
    int dataid = [[resultarray objectAtIndex:0] intValue];
    NSLog(@"dataid=%d",dataid);
    
    self.idFromMainPage = dataid;
    NSMutableArray *resultArray = [tsdatabase loadDBDataOnCamera:self.idFromMainPage];
    
    
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
