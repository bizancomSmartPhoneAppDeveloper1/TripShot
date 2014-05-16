//
//  CameraViewController.h
//  TripShot
//
//  Created by bizan.com.mac09 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSDataBase.h"

@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>{
    
    UIImage *editedImage;
}
@property int idFromMainPage;//メイン画面でピンを選択した時にcameraViewに対して渡されるDBのID
@property NSString *place_nameFromMainPage;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

-(void)startCamera;
- (IBAction)takePhoto:(UIButton *)sender;




@end
