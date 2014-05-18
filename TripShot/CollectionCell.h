//
//  CollectionCell.h
//  TripShot
//
//  Created by KomayaIkuma on 2014/05/12.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *pictureDate;
@property (weak, nonatomic) IBOutlet UIImageView *cellFrameView;

@end
