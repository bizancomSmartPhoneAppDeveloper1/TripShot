//
//  CameraViewController.h
//  TripShot
//
//  Created by YuzuruIshii on 2014/05/12.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "TSDataBase.h"

@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate>{
    
    UIImage *editedImage;
}
@property int idFromMainPage;//メイン画面でピンを選択した時にcameraViewに対して渡されるDBのID
@property NSString *place_nameFromMainPage;
@property (nonatomic, retain) NSTimer* timer;
//@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollAllView;

-(void)startCamera;
//- (IBAction)takePhoto:(UIButton *)sender;
//- (IBAction)buttonFacebook:(UIButton *)sender;




@end
