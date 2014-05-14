//
//  IndividualAlbumViewController.h
//  TripShot
//
//  Created by bizan.com.mac02 on 2014/05/14.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSDataBase.h"

@interface IndividualAlbumViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>{
    
    UIImage *editedImage;
}
@property int idFromMainPage;//メイン画面でピンを選択した時にcameraViewに対して渡されるDBのID
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;


@end
