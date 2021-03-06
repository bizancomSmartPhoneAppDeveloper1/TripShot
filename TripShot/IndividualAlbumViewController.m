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
    UITextView *titleField;
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
    UIScrollView *scrollAllView;
    UIScrollView *scrollView;
    
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

    //オリジナルBarButton生成　selectorでメソッドを指定
    UIImage *image = [UIImage imageNamed:@"return30.png"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(didTapReturnButton)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

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
    NSString *databaseFilePath = [[tsdatabase dataFolderPath] stringByAppendingPathComponent:@"TSDatabase.db"];
    FMDatabase *database = [FMDatabase databaseWithPath:databaseFilePath];
    [database close];

    //全体にUIScrollviewを作成
    scrollAllView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview:scrollAllView];
    
    //写真をスクロール表示
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
    NSArray *arrayPicNotMutable = [pics componentsSeparatedByString:@","];
    NSLog(@"arrayPicNotMutable=%@",[arrayPicNotMutable description]);
    NSLog(@"picsCount=%d",picsCount);
    scrollView.delegate = self;
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
    
    scrollView.showsHorizontalScrollIndicator = NO;
    for (UIView *v in [scrollView subviews]) {
        [v removeFromSuperview];
    }
    CGRect workingFrame = scrollView.frame;
    facebookImages = [[NSMutableArray alloc]init];
    if (!picsCount==0) {
        for (int i=0; i<picsCount; i++) {
            NSData *dataPics = [[NSData alloc] initWithContentsOfFile:[arrayPicNotMutable objectAtIndex:i]];
            UIImage* image = [[UIImage alloc] initWithData:dataPics];
            UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
            [imageview setContentMode:UIViewContentModeScaleAspectFit];
            imageview.frame = workingFrame;
            
            [scrollView addSubview:imageview];
            workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            
            [facebookImages addObject:image];
        }
        [scrollView setPagingEnabled:YES];
        [scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
        [scrollAllView addSubview:scrollView];
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
    
    //文字色の指定（藍色！)
    UIColor *textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.42 alpha:1.0];
    
    //行きたい場所リストタイトル表示
    CGRect titleRect = CGRectMake(15, 340, width-40, 45);  //横始まり・縦始まり・ラベルの横幅・縦幅
    titleField = [[UITextView alloc]initWithFrame:titleRect];
    titleField.text = title;
    titleField.returnKeyType = UIReturnKeyDone;
    titleField.delegate = self;
    titleField.textColor = textColor;
    titleField.font = [UIFont fontWithName:@"STHeitiJ-Light" size:18];
    titleField.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0];
    [scrollAllView addSubview:titleField];
    [self registerForKeyboardNotifications];
    
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
    [scrollAllView addSubview:dateLabel];
    
    //住所情報入力
    CGRect addressRect = CGRectMake(18, 445, width-84, 20);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:addressRect];
    addressLabel.text = address;
    addressLabel.textColor = textColor;
    addressLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:12];
    [scrollAllView addSubview:addressLabel];
    
    //コメント欄
    CGRect textRect = CGRectMake(20, 380, width-40, 30);
    textfield = [[UITextField alloc]initWithFrame:textRect];
    if ([text isEqualToString:@" "]) {
    textfield.placeholder = @"コメントを入れてね♪";
    }else{
    textfield.text = text;
    }
    textfield.textColor = textColor;
    textfield.font = [UIFont fontWithName:@"STHeitiJ-Light" size:12];
    textfield.returnKeyType = UIReturnKeyDefault;
    textfield.delegate = self;
    [scrollAllView addSubview:textfield];
    [self registerForKeyboardNotifications];
    
    //Facebookボタン作成
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-60, 420, 44, 44);
    [button setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(button_Tapped) forControlEvents:UIControlEventTouchUpInside];
    [scrollAllView addSubview:button];
}


//titlefieldでリターンキーが押されるとキーボードを隠す
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)textTitle{
	
    if ([textTitle isEqualToString:@"\n"]) {
        [tsdatabase updateTitle:self.idFromMainPage TITLE:titleField.text];
        [textView resignFirstResponder];
        return NO;
    }
	return YES;
}


//UIscrollViewを自動で動かす
- (void)timerDidFire:(NSTimer*)timer
{
	if (autoScrollStopped) {
		return;
	}
	CGPoint p = scrollView.contentOffset;
	p.x = p.x + 1;
    CGRect aFrame = scrollView.frame;
    //Imageの数だけ来ると自動スクロール停止
	if (p.x < ((aFrame.size.width * picsCount)- aFrame.size.width)) {
		scrollView.contentOffset = p;
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
    [scrollAllView setContentOffset:scrollPoint animated:YES];
}


//キーボードを隠す関数
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [scrollAllView setContentOffset:CGPointZero animated:YES];
}


//textfieldでリターンキーが押されるとキーボードを隠す
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [tsdatabase updateText:self.idFromMainPage TEXT:textfield.text];
    [textField resignFirstResponder];
    return YES;
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


-(void)didTapReturnButton{
    //BarBUttonもどるで元の画面に
    [self.navigationController popViewControllerAnimated:YES];
    //NSTimerをstop
    [self.timer invalidate];
}


@end
