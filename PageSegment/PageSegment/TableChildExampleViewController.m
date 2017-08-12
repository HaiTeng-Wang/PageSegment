//
//  TableChildExampleViewController.m
//  CcfaxPagerTab
//
//  Created by Hunter on 12/08/2017.
//  Copyright © 2017 Hunter. All rights reserved.
//

#import "TableChildExampleViewController.h"
#import "PostCellTableViewCell.h"
#import "DataProvider.h"

@interface TableChildExampleViewController ()

@end


static NSString *cellIdent = @"cellIdent";

@implementation TableChildExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self.tableView registerNib:[UINib nibWithNibName:@"PostCellTableViewCell"
                                               bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdent];
    self.tableView.estimatedRowHeight = 60.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = NO;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return DataProvider.sharedInstance.postsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent forIndexPath:indexPath];

    if (DataProvider.sharedInstance.postsData.count) {
        [cell configureWithData:DataProvider.sharedInstance.postsData[indexPath.row]];
    }

    return cell;
}

@end
