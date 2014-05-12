//
//  CreateListViewController.h
//  TripShot
//
//  Created by bizan.com.mac05 on 2014/05/12.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CreateListViewControllerDelegate;

@interface CreateListViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) id <CreateListViewControllerDelegate>delegate;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;
@end

@protocol CreateListViewControllerDelegate <NSObject>

//Saveボタンが押された時に呼び出すメソッド
- (void)createLisViewControllerDidFinish:(CreateListViewController *)controller item:(NSString *)item;

//Cancelボタンが押されたときに呼び出すメソッド
- (void)createListViewControllerDidCancel:(CreateListViewController *)controller;

@end
