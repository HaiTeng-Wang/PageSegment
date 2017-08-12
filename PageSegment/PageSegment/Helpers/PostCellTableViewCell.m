//
//  PostCellTableViewCell.m
//  CcfaxPagerTab
//
//  Created by Hunter on 12/08/2017.
//  Copyright © 2017 Hunter. All rights reserved.
//

#import "PostCellTableViewCell.h"

@interface PostCellTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *textLab;

@end


@implementation PostCellTableViewCell

- (void)configureWithData:(NSDictionary *)data{
    NSDictionary *post = data[@"post"];
    NSDictionary *user = post[@"user"];

    _nameLab.text = user[@"name"];
    _textLab.text = post[@"text"];
    _userImg.image = [UIImage imageNamed:[_nameLab.text stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
}

@end
