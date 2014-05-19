//
//  CameraViewController.m
//  TripShot
//
//  Created by YuzuruIshii on 2014/05/12.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
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
    NSString *title;
    BOOL autoScrollStopped;
    NSString *path;
    NSMutableArray *facebookImages;

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
    
    //各表示
    [self viewSet];
    
    //データ保存用のディレクトリを作成する
    if ([self makeDirForAppContents]) {
        //ディレクトリに対して「do not backup」属性をセット
        NSURL *dirUrl = [NSURL fileURLWithPath: [self myDocumentsPath]];
        [self addSkipBackupAttributeToItemAtURL:dirUrl];
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated{

    [self.navigationController setNavigationBarHidden:NO];
    self.tabBarController.tabBar.hidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//スタートカメラ
-(void)startCamera{
    
    //カメラを使用できるかチェック
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        //UIImagePickerを作りViewControllerがUIImagePickerControllerのデリゲートとする
        imagePicker.delegate = self;
        //画像の入力ソースをカメラからの画像入力に
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //allowsEditingがYESで撮影後自動的に画像編集シーンに移行する
        imagePicker.allowsEditing = YES;
        //カメラ機能開始
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}


//カメラボタンを押した時に呼ばれる関数
- (IBAction)takePhoto:(UIButton *)sender {
    [self startCamera];
}


//Facebookボタンを押した時に呼ばれる関数
- (IBAction)buttonFacebook:(UIButton *)sender {
    [self button_Tapped];
}


//Facebookへの投稿関数
- (void)button_Tapped

{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:[NSString stringWithFormat:@"%@ from撮りっぷ",textfield.text]];
    //写真の枚数を確認
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


//カメラが呼び出され、cancelボタンが押されると呼び出されるメソッド
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //撮影モード終了
    [self dismissViewControllerAnimated:YES completion:nil];
}


//カメラが呼び出される関数
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    NSData *data = UIImageJPEGRepresentation(editedImage, 0.5);
    
    //50枚まで写真撮影可能
    int counter = 50;
    while (counter >= 0) {
        path = [NSString stringWithFormat:@"%@/TSpicture%d-%d.jpg",
                 [self myDocumentsPath],self.idFromMainPage,counter];
    if ([[NSURL fileURLWithPath:path] checkResourceIsReachableAndReturnError:nil] == YES) {
        path = [NSString stringWithFormat:@"%@/TSpicture%d-%d.jpg",
                [self myDocumentsPath],self.idFromMainPage,counter+1];
        break;
    }else{
        path = [NSString stringWithFormat:@"%@/TSpicture%d-0.jpg",
                [self myDocumentsPath],self.idFromMainPage];
    }
        counter --;
        NSLog(@"counter=%d",counter);
    }
    //写真をDocumentsディレクトリへ保存
    if ([data writeToFile:path atomically:YES]) {
        NSLog(@"save OK");
    } else {
        NSLog(@"save NG");
    }
    [picsArray addObject:path];
    [array addObject:editedImage];
    picsCount = [array count];
    
    //以下からScrollView機能
    _scrollView.delegate = self;
    autoScrollStopped = NO;
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                  target:self
                                                selector:@selector(timerDidFire:)
                                                userInfo:nil
                                                 repeats:YES];
    _scrollView.showsHorizontalScrollIndicator = NO;
    for (UIView *v in [_scrollView subviews]) {
        [v removeFromSuperview];
    }
    CGRect workingFrame = _scrollView.frame;
    if (!picsCount==0) {
        for (int i=0; i<picsCount; i++) {
            UIImage* image = [array objectAtIndex:i];
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
    
    //カメラ機能終了
    [self dismissViewControllerAnimated:YES completion:nil];
}


//行きたい所リスト等情報をViewに設定させる関数
- (void)viewSet{
    
    facebookImages = [[NSMutableArray alloc]init];
    
    //行きたい場所情報をメイン画面から引き継ぐ
    FMResultSet *resultsID = [tsdatabase loadIDFromPlaceName:_place_nameFromMainPage];
    while([resultsID next]){
        self.idFromMainPage = [resultsID intForColumn:@"id"];
    }
    
    //DBを閉じる
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectry = paths[0];
    NSString *databaseFilePath = [documentDirectry stringByAppendingPathComponent:@"TSDatabase.db"];
    FMDatabase *database = [FMDatabase databaseWithPath:databaseFilePath];
    [database close];
    
    //DBからFMResultSetを取り出す
    FMResultSet *results = [tsdatabase loadDBDataOnCamera:self.idFromMainPage];
    while([results next]){
        title = [results stringForColumn:@"place_name"];
        address = [results stringForColumn:@"address"];
    }
    
    //DBを閉じる
    [database close];

    //行きたい場所リストタイトル表示
    CGRect titleRect = CGRectMake(90, 320, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleRect];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor blueColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [self.scrollAllView addSubview:titleLabel];
    
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
    [self.scrollAllView addSubview:dateLabel];
    
    //住所情報入力
    CGRect addressRect = CGRectMake(90, 400, 220, 50);  //横始まり・縦始まり・ラベルの横幅・縦幅
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:addressRect];
    addressLabel.text = address;
    addressLabel.textColor = [UIColor blueColor];
    addressLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.scrollAllView addSubview:addressLabel];
    
    //コメント欄
    CGRect textRect = CGRectMake(90, 430, 220, 50);
    textfield = [[UITextField alloc]initWithFrame:textRect];
    textfield.text = @"コメントを入れてね♪";
    textfield.textColor = [UIColor blueColor];
    textfield.font = [UIFont boldSystemFontOfSize:10];
    textfield.returnKeyType = UIReturnKeyDefault;
    textfield.delegate = self;
    [self.scrollAllView addSubview:textfield];
    // キーボードが表示されたときのNotificationを受け取る
    [self registerForKeyboardNotifications];
    
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
}


//textfieldでリターンキーが押されるとキーボードを隠す
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
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


//iCloudへのバックアップを行なわないようにする関数
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


//main画面に戻る際の関数。
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"cameraViewToMainView"]) {
        NSLog(@"確認");
        //DBに保存する
        pics = [picsArray componentsJoinedByString:@","];
        NSLog(@"pics=%@",[pics description]);
        picsCount =[picsArray count];
        NSLog(@"count=%d",picsCount);
        comment = textfield.text;
        //went_flagを行ったことにする。これによりジオフェンスを外す。
        int went_frag = 0;
        [tsdatabase updateDBDataOnCamera:self.idFromMainPage TEXT:comment PICS:pics PICCOUNT:picsCount WENTFLAG:went_frag];
    }
}


@end
