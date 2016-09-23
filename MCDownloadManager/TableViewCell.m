//
//  TableViewCell.m
//  MCDownloadManager
//
//  Created by 马超 on 16/9/6.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import "TableViewCell.h"
#import "MCDownloadManager.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.button.clipsToBounds = YES;
    self.button.layer.cornerRadius = 10;
    self.button.layer.borderWidth = 1;
    self.button.layer.borderColor = [UIColor orangeColor].CGColor;
    [self.button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    self.button.clickDurationTime = 1.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUrl:(NSString *)url {
    _url = url;
    
    self.nameLabel.text = url.lastPathComponent;
    self.progressView.progress = 0;
    
    MCDownloadReceipt *receipt = [[MCDownloadManager defaultInstance] downloadReceiptForURL:url];

    self.progressView.progress = receipt.progress.fractionCompleted;
    
    if (receipt.state == MCDownloadStateDownloading) {
        [self.button setTitle:@"停止" forState:UIControlStateNormal];
    }else if (receipt.state == MCDownloadStateCompleted) {
        [self.button setTitle:@"播放" forState:UIControlStateNormal];
    }else if (receipt.state == MCDownloadStateFailed) {
        [self.button setTitle:@"重新下载" forState:UIControlStateNormal];
    }else if (receipt.state == MCDownloadStateSuspened) {
        [self.button setTitle:@"继续下载" forState:UIControlStateNormal];
    }else if (receipt.state == MCDownloadStateWillResume) {
        [self.button setTitle:@"等待下载" forState:UIControlStateNormal];
    }else {
        [self.button setTitle:@"下载" forState:UIControlStateNormal];
    }
    
  
}
- (IBAction)buttonAction:(UIButton *)sender {
    
    MCDownloadReceipt *receipt = [[MCDownloadManager defaultInstance] downloadReceiptForURL:self.url];
    if (receipt.state == MCDownloadStateCompleted) {
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        MPMoviePlayerViewController *mpc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:receipt.filePath]];
        [vc presentViewController:mpc animated:YES completion:nil];
    }else if (receipt.state == MCDownloadStateFailed) {
        [self.button setTitle:@"停止" forState:UIControlStateNormal];
        [self download];
    }else if (receipt.state == MCDownloadStateDownloading) {
        [self.button setTitle:@"继续下载" forState:UIControlStateNormal];
        [[MCDownloadManager defaultInstance] suspendWithDownloadReceipt:receipt];
    }else if (receipt.state == MCDownloadStateSuspened) {
        [self.button setTitle:@"停止" forState:UIControlStateNormal];
    
        [self download];
    }else if (receipt.state == MCDownloadStateWillResume) {
        [self.button setTitle:@"下载" forState:UIControlStateNormal];
         [[MCDownloadManager defaultInstance] removeWithDownloadReceipt:receipt];
    }else if (receipt.state == MCDownloadStateNone) {
        [self.button setTitle:@"停止" forState:UIControlStateNormal];
        [self download];
    }
  
}

- (void)download {
    [[MCDownloadManager defaultInstance] downloadFileWithURL:self.url
                                                    progress:^(NSProgress * _Nonnull downloadProgress, MCDownloadReceipt *receipt) {
                                                        
                                                        if ([receipt.url isEqualToString:self.url]) {
                                                            self.progressView.progress = downloadProgress.fractionCompleted ;
                                                        }
                                    
                                                    }
                                                 destination:nil
                                                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSURL * _Nonnull filePath) {
                                                         [self.button setTitle:@"播放" forState:UIControlStateNormal];
                                                     }
                                                     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                         [self.button setTitle:@"重新下载" forState:UIControlStateNormal];
                                                     }];

}
@end
