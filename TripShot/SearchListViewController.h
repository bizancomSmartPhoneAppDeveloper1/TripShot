//
//  SearchListViewController.h
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/13.
//  Copyright (c) 2014年 bizan.com.mac02. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchListViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchField;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)addButtonTapped:(id)sender;

@end
