//
//  CameraViewController.m
//  TripShot
//
//  Created by YuzuruIshii on 2014/05/12.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import "CameraViewController.h"
#import "AlbumViewController.h"

@interface CameraViewController (){
    TSDataBase *tsdatabase;
    UIImageView *imageViewBack;
    UITextField *textfield;
    UITextView *titleField;
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
    UIScrollView *scrollAllView;
    UIScrollView *scrollView;
    int deleteFlag;
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
    //barbutton生成　画像入れ込み　メソッド指定
    UIImage *image = [UIImage imageNamed:@"return30.png"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(didTapReturnButton)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

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
        //カメラロールにも保存
        UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil);
    } else {
        NSLog(@"save NG");
    }
    [picsArray addObject:path];
    [array addObject:editedImage];
    picsCount = [array count];
    
    //以下からScrollView機能
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
    scrollView.delegate = self;
    autoScrollStopped = NO;
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                  target:self
                                                selector:@selector(timerDidFire:)
                                                userInfo:nil
                                                 repeats:YES];
    scrollView.showsHorizontalScrollIndicator = NO;
    for (UIView *v in [scrollView subviews]) {
        [v removeFromSuperview];
    }
    CGRect workingFrame = scrollView.frame;
    if (!picsCount==0) {
        for (int i=0; i<picsCount; i++) {
            UIImage* image = [array objectAtIndex:i];
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
    
    //カメラ機能終了
    [self dismissViewControllerAnimated:YES completion:nil];
}


//行きたい所リスト等情報をViewに設定させる関数
- (void)viewSet{
    
    facebookImages = [[NSMutableArray alloc]init];
    
    //行きたい場所情報をメイン画面から引き継ぐ
    FMResultSet *resultsID = [tsdatabase loadIDFromPlaceName:_place_nameFromMainPage];
    while([resultsID next]){
        //削除フラグが立っていない情報のみ取得
        if (deleteFlag==0) {
        self.idFromMainPage = [resultsID intForColumn:@"id"];
        }
    }
    
    //DBを閉じる
    NSString *databaseFilePath = [[tsdatabase dataFolderPath] stringByAppendingPathComponent:@"TSDatabase.db"];
    FMDatabase *database = [FMDatabase databaseWithPath:databaseFilePath];
    [database close];
    
    //DBからFMResultSetを取り出す
    FMResultSet *results = [tsdatabase loadDBDataOnCamera:self.idFromMainPage];
    while([results next]){
        title = [results stringForColumn:@"place_name"];
        address = [results stringForColumn:@"address"];
        deleteFlag = [results intForColumn:@"delete_flag"];
    }
    
    //DBを閉じる
    [database close];
    
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
    

    //全体にUIScrollviewを作成
    scrollAllView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview:scrollAllView];
    
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
    date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit |
                                   NSMonthCalendarUnit  |
                                   NSDayCalendarUnit    |
                                   NSHourCalendarUnit   |
                                   NSMinuteCalendarUnit |
                                   NSSecondCalendarUnit
                                              fromDate:date];
    CGRect daterect = CGRectMake(20, 430, width-40, 14);
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:daterect];
    dateLabel.text = [NSString stringWithFormat:@"%d月%d日",(int)dateComps.month,(int)dateComps.day];
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
    textfield.placeholder = @"コメントを入れてね♪";
    textfield.textColor = textColor;
    textfield.font = [UIFont fontWithName:@"STHeitiJ-Light" size:12];
    textfield.returnKeyType = UIReturnKeyDefault;
    textfield.delegate = self;
    [scrollAllView addSubview:textfield];
    // キーボードが表示されたときのNotificationを受け取る
    [self registerForKeyboardNotifications];

    //Facebookボタン作成
    UIButton *buttonFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonFacebook.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-60, 420, 44, 44);
    [buttonFacebook setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [buttonFacebook sizeToFit];
    [buttonFacebook addTarget:self action:@selector(button_Tapped) forControlEvents:UIControlEventTouchUpInside];
    [scrollAllView addSubview:buttonFacebook];
    
    //cameraボタン作成
    UIButton *buttonCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCamera.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-65, 360, 44, 44);
    [buttonCamera setBackgroundImage:[UIImage imageNamed:@"camera60.png"] forState:UIControlStateNormal];
    [buttonCamera sizeToFit];
    [buttonCamera addTarget:self action:@selector(startCamera) forControlEvents:UIControlEventTouchUpInside];
    [scrollAllView addSubview:buttonCamera];
    
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


#pragma mark - Fujiwara

-(void)viewWillDisappear:(BOOL)animated{
    if([self.navigationController.viewControllers indexOfObject:self] == NSNotFound){
    
        
        //DBに保存する
        title = titleField.text;
        pics = [picsArray componentsJoinedByString:@","];
        NSLog(@"pics=%@",[pics description]);
        picsCount =[picsArray count];
        NSLog(@"count=%d",picsCount);
        comment = textfield.text;
        //went_flagを行ったことにする。これによりジオフェンスを外す。
        int went_frag = 0;
        
        if (!(picsCount==0)) {
            [tsdatabase updateDBDataOnCamera:self.idFromMainPage TITLE:title TEXT:comment PICS:pics PICCOUNT:picsCount WENTFLAG:went_frag];
        }
    }
    
    [super viewWillDisappear:animated];
}

-(void)didTapReturnButton{
    //BarButtonもどるで元の画面に
    [self.navigationController popViewControllerAnimated:YES];
    
    //NSTimerをstop
    [self.timer invalidate];
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

@end
