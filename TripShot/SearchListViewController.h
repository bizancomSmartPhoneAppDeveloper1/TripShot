//
//  SearchListViewController.h
//  TripShot
//
//  Created by EmikoFujiwara on 2014/05/13.
//  Copyright (c) 2014年 team -IKI- All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchListViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *TableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchField;
- (IBAction)cancelButtonTapped:(id)sender;


@end
