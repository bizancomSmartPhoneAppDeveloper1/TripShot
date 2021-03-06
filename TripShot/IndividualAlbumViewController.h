//
//  IndividualAlbumViewController.h
//  TripShot
//
//  Created by YuzuruIshii on 2014/05/14.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "TSDataBase.h"

@interface IndividualAlbumViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate,UITextViewDelegate>{
    UIImage *editedImage;
}
@property int idFromMainPage;//メイン画面でピンを選択した時にcameraViewに対して渡されるDBのID
@property (nonatomic, retain) NSTimer* timer;


@end
