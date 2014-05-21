//
//  IndividualAlbumViewController.m
//  TripShot
//
//  Created by YuzuruIshii on 2014/05/14.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import "IndividualAlbumViewController.h"

@interface IndividualAlbumViewController (){
    TSDataBase *tsdatabase;
    UIImageView *imageViewBack;
    UITextField *textfield;
    NSString *address;
    NSMutableArray *array;
    NSString *comment;
    NSMutableArray *picsArray;
    NSString *title;
    int date;
    NSString *text;
    NSString *pics;
    int picsCount;
    BOOL autoScrollStopped;
    NSMutableArray *facebookImages;
    
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
    [self viewSet];
    
    [self.navigationController setNavigationBarHidden:NO];
    self.tabBarController.tabBar.hidden = YES;

    //navigationBar設定
//    //ナビゲーションバー
//    [UINavigationBar appearance].tintColor = [UIColor colorWithRed:0.91 green:0.42 blue:0.41 alpha:1.0];
//    
//    
//    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.92 alpha:1.0];
//
    //オリジナルBarButton生成　selectorでメソッドを指定
    UIImage *image = [UIImage imageNamed:@"return30.png"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(didTapReturnButton)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//行きたい所リスト等情報をViewに設定させる関数
- (void)viewSet{
    
    //DBからFMResultSetを取り出す
    FMResultSet *results = [tsdatabase loadDBDataOnCamera:self.idFromMainPage];
    while([results next]){
        title = [results stringForColumn:@"place_name"];
        date = [results intForColumn:@"date"];
        text = [results stringForColumn:@"text"];
        pics = [results stringForColumn:@"pics"];
        picsCount = [results intForColumn:@"picCount"];
        address = [results stringForColumn:@"address"];
    }
    
    //DBを閉じる
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectry = paths[0];
    NSString *databaseFilePath = [documentDirectry stringByAppendingPathComponent:@"TSDatabase.db"];
    FMDatabase *database = [FMDatabase databaseWithPath:databaseFilePath];
    [database close];

     
    //写真をスクロール表示
    NSArray *arrayPicNotMutable = [pics componentsSeparatedByString:@","];
    NSLog(@"arrayPicNotMutable=%@",[arrayPicNotMutable description]);
    NSLog(@"picsCount=%d",picsCount);
    _scrollView.delegate = self;
    autoScrollStopped = NO;
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    if (!picsCount==0) {
        NSLog(@"picsCount=%d",picsCount);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                  target:self
                                                selector:@selector(timerDidFire:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    
    _scrollView.showsHorizontalScrollIndicator = NO;
    for (UIView *v in [_scrollView subviews]) {
        [v removeFromSuperview];
    }
    CGRect workingFrame = _scrollView.frame;
    facebookImages = [[NSMutableArray alloc]init];
    if (!picsCount==0) {
        for (int i=0; i<picsCount; i++) {
            NSData *dataPics = [[NSData alloc] initWithContentsOfFile:[arrayPicNotMutable objectAtIndex:i]];
            UIImage* image = [[UIImage alloc] initWithData:dataPics];
            UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
            [imageview setContentMode:UIViewContentModeScaleAspectFit];
            imageview.frame = workingFrame;
            
            [_scrollView addSubview:imageview];
            workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            
            [facebookImages addObject:image];
        }
        [_scrollView setPagingEnabled:YES];
        [_scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
        [self.scrollAllView addSubview:_scrollView];
    }

    
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    UIImage *imageData = [UIImage imageNamed:@"free-textures-japanese-style-06.jpg"];
    
    //背景画像の準備
    imageViewBack = [[UIImageView alloc]initWithFrame:rect];
    imageViewBack.image = imageData;
    imageViewBack.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageViewBack];
    [self.view sendSubviewToBack:imageViewBack];

    
    //文字色の指定（藍色にする！)
    UIColor *textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.42 alpha:1.0];
    
    
    //行きたい場所リストタイトル表示
    CGRect titleRect = CGRectMake(20, 340, width-40, 40);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleRect];
    titleLabel.text = title;
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textColor = textColor;
    titleLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:18];
//    titleLabel.backgroundColor = [[UIColor greenColor]colorWithAlphaComponent:0.5]; //確認用
    [self.scrollAllView addSubview:titleLabel];
    
    //日付入力
    NSString *dateString = [NSString stringWithFormat:@"%d",date];
    NSString *monthString = [dateString substringWithRange:NSMakeRange(4,2)];
    int month = [monthString intValue];
    NSLog(@"month=%d",month);
    NSString *dayString = [dateString substringWithRange:NSMakeRange(6,2)];
    int day = [dayString intValue];
    CGRect daterect = CGRectMake(20, 430, width-40, 14);
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:daterect];
    dateLabel.text = [NSString stringWithFormat:@"%d月%d日",month,day];
    dateLabel.textColor = textColor;
    dateLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:12];
//    dateLabel.backgroundColor = [[UIColor yellowColor]colorWithAlphaComponent:0.5];//確認用
    [self.scrollAllView addSubview:dateLabel];
    
    //住所情報入力
    CGRect addressRect = CGRectMake(18, 445, width-40, 20);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:addressRect];
    addressLabel.text = address;
    addressLabel.textColor = textColor;
    addressLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:12];
//    addressLabel.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.5]; //確認用
    [self.scrollAllView addSubview:addressLabel];
    
    //コメント欄
    CGRect textRect = CGRectMake(20, 380, width-40, 30);
    textfield = [[UITextField alloc]initWithFrame:textRect];
    textfield.text = text;
    textfield.textColor = textColor;
//    textfield.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.5];//確認用
    textfield.font = [UIFont fontWithName:@"STHeitiJ-Light" size:12];
    textfield.returnKeyType = UIReturnKeyDefault;
    textfield.delegate = self;
    [self.scrollAllView addSubview:textfield];
    [self registerForKeyboardNotifications];
    
}


//textfieldでリターンキーが押されるとキーボードを隠す
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //DBにコメントを保存する
    [tsdatabase updateText:self.idFromMainPage TEXT:textfield.text];
    return YES;
}


//UIscrollViewを自動で動かす
- (void)timerDidFire:(NSTimer*)timer
{
	if (autoScrollStopped) {
		return;
	}
	CGPoint p = self.scrollView.contentOffset;
	p.x = p.x + 1;
    CGRect aFrame = self.scrollView.frame;
    //Imageの数だけ来ると自動スクロール停止
	if (p.x < ((aFrame.size.width * picsCount)- aFrame.size.width)) {
		self.scrollView.contentOffset = p;
	}
}


//Viewがロードされるタイミングで呼ばれる関数
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}


//キーボード表示関数
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGPoint scrollPoint = CGPointMake(0.0,200.0);
    [self.scrollAllView setContentOffset:scrollPoint animated:YES];
}


//キーボードを隠す関数
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollAllView setContentOffset:CGPointZero animated:YES];
}

- (void)button_Tapped

{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:[NSString stringWithFormat:@"%@ from撮りっぷ",textfield.text]];
    if (picsCount > 3 ) {
        for (int i=0; i<4; i++) {
            [controller addImage:[facebookImages objectAtIndex:i]];
        }
    }else{
        for (int i=0; i<picsCount; i++) {
            [controller addImage:[facebookImages objectAtIndex:i]];
        }
    }
    [self presentViewController:controller animated:YES completion:NULL];
}


//FaceBook投稿
- (IBAction)buttonFacebook:(UIButton *)sender {
    [self button_Tapped];
}

-(void)didTapReturnButton{
    //BarBUttonもどるで元の画面に
    [self.navigationController popViewControllerAnimated:YES];
    //NSTimerをstop
    [self.timer invalidate];
}


@end
