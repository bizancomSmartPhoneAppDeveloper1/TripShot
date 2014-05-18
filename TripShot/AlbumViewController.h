//
//  AlbumViewController.h
//  TripShot
//
//  Created by KomayaIkuma on 2014/05/12.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *AlbumCollection;

@end
