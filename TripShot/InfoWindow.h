//
//  InfoWindow.h
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceView.h"
#import "CustomAnnotation.h"

@interface InfoWindow : UIViewController

+(id)instanceWithAnnotation:(CustomAnnotation *)annotation;


@end
