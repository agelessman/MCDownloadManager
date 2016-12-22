//
//  TableViewCell.h
//  MCDownloadManager
//
//  Created by 马超 on 16/9/6.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKYDelayButton.h"

@class TableViewCell;
@protocol TableViewCellDelegate <NSObject>

- (void)cell:(TableViewCell *)cell didClickedBtn:(UIButton *)btn;

@end

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet QKYDelayButton *button;
@property (weak, nonatomic) IBOutlet UILabel *bytesLable;
@property (weak, nonatomic) IBOutlet UILabel *speedLable;


@property (nonatomic, weak) id <TableViewCellDelegate> delegate;
@property (nonatomic,copy)NSString *url;
@end
