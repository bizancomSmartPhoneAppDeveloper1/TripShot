//
//  CameraViewController.h
//  TripShot
//
//  Created by bizan.com.mac09 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>{
    
    UIImage *editedImage;
}
@property NSString *temp;
@property NSString *icon;
@property NSDictionary *jsonObject;
@property NSString* tomorrow;



@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

-(void)startCamera;
- (IBAction)takePhoto:(UIButton *)sender;




@end
