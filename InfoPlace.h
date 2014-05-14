//
//  InfoPlace.h
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceView.h"
#import "CustomAnnotation.h"

@interface InfoPlace : UIViewController

+(id)instanceWithAnnotation:(CustomAnnotation *)annotation;
@property (strong, nonatomic) IBOutlet PlaceView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *cameraImage;
@property (strong, nonatomic) CustomAnnotation *annotation;
@end
