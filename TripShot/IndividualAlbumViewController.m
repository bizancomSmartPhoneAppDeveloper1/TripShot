//
//  IndividualAlbumViewController.m
//  TripShot
//
//  Created by bizan.com.mac02 on 2014/05/14.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "IndividualAlbumViewController.h"

@interface IndividualAlbumViewController (){
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

@implementation IndividualAlbumViewController

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
    
    //各表示
    [self viewMethod];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewMethod{
    
    //メイン画面から受け渡されるID 仮に0とする。
//    self.idFromMainPage = 0;
    NSMutableArray *resultArray = [tsdatabase loadDBDataOnCamera:self.idFromMainPage];
    NSLog(@"idFromMainPage=%d",self.idFromMainPage);
    
    
    
    //ここから
    pics = [resultArray objectAtIndex:7];
    NSArray *arrayPicNotMutable = [pics componentsSeparatedByString:@","];
    NSLog(@"arrayPicNotMutable=%@",[arrayPicNotMutable description]);
    NSLog(@"picsCount=%d",[[resultArray objectAtIndex:5] intValue]);
    
    
    if (![[resultArray objectAtIndex:5] intValue]==0) {
    NSMutableArray *arrayPics = [[NSMutableArray alloc]init];
    for (int i=0; i<2; i++) {
        NSData *dataPics = [[NSData alloc] initWithContentsOfFile:[arrayPicNotMutable objectAtIndex:i]];
        UIImage* image = [[UIImage alloc] initWithData:dataPics];
        //self.myImageView.image = image;
        [arrayPics addObject:image];
    }
    NSLog(@"arrayPics=%@",[arrayPics description]);
    self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.myImageView.animationImages = arrayPics;
    self.myImageView.animationDuration = 3.0;
    self.myImageView.animationRepeatCount = 0;
    [self.myImageView startAnimating];
    }
    
    
      
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



@end
