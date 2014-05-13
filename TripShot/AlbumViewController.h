//
//  AlbumViewController.h
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *AlbumCollection;

@end
