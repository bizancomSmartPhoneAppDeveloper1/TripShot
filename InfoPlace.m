//
//  InfoPlace.m
//  TripShot
//
//  Created by bizan.com.mac03 on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import "InfoPlace.h"
#import "NSObject+Extension.h"
#import "PlaceView.h"

@interface InfoPlace ()

@end

@implementation InfoPlace

+ (id)instanceWithAnnotation:(CustomAnnotation *)annotation
{
    id obj = [[[self class] alloc] initWithNibName:@"InfoPlace" bundle:[NSBundle mainBundle]];
    [obj setAnnotation:annotation];
    return obj;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.infoView.tag = 1;
    self.infoView.backgroundColor = [UIColor clearColor];
    self.infoView.userInteractionEnabled = NO;
    self.infoView.multipleTouchEnabled = NO;
    self.infoView.baseColor = [UIColor whiteColor];
    self.infoView.strokeColor = self.annotation.mainColor;
    self.infoView.ballonRadius = 5.0f;
    self.infoView.ballonStroke = 2.0f;
    self.infoView.tailHeight = 10.0f;
    self.infoView.tailWidth = 20.0f;
    self.infoView.direction = SFBallonDirectionBottom;
    self.cameraImage.image = [UIImage imageNamed:self.annotation.cameraName];
    self.infoLabel.text = self.annotation.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
