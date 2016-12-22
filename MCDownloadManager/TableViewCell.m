//
//  TableViewCell.m
//  MCDownloadManager
//
//  Created by 马超 on 16/9/6.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import "TableViewCell.h"
#import "MCDownloadManager.h"



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
    
    MCDownloadReceipt *receipt = [[MCDownloadManager defaultInstance] downloadReceiptForURL:url];

    self.nameLabel.text = receipt.truename;
    self.speedLable.text = nil;
    self.bytesLable.text = nil;
    self.progressView.progress = 0;
    
    self.progressView.progress = receipt.progress.fractionCompleted;
    
    if (receipt.state == MCDownloadStateDownloading) {
        [self.button setTitle:@"停止" forState:UIControlStateNormal];
    }else if (receipt.state == MCDownloadStateCompleted) {
         [self.button setTitle:@"播放" forState:UIControlStateNormal];
    }else {
         [self.button setTitle:@"下载" forState:UIControlStateNormal];
    }
    
    receipt.progressBlock = ^(NSProgress * _Nonnull downloadProgress,MCDownloadReceipt *receipt) {
        if ([receipt.url isEqualToString:self.url]) {
            self.progressView.progress = downloadProgress.fractionCompleted ;
            self.bytesLable.text = [NSString stringWithFormat:@"%0.2fm/%0.2fm", downloadProgress.completedUnitCount/1024.0/1024, downloadProgress.totalUnitCount/1024.0/1024];
            self.speedLable.text = [NSString stringWithFormat:@"%@/s", receipt.speed];
        }
    };
    
    receipt.successBlock = ^(NSURLRequest * _Nullablerequest, NSHTTPURLResponse * _Nullableresponse, NSURL * _NonnullfilePath) {
         [self.button setTitle:@"播放" forState:UIControlStateNormal];
    };

    receipt.failureBlock = ^(NSURLRequest * _Nullable request, NSHTTPURLResponse * _Nullable response,  NSError * _Nonnull error) {
        [self.button setTitle:@"下载" forState:UIControlStateNormal];
    };
  
}
- (IBAction)buttonAction:(UIButton *)sender {
    
    MCDownloadReceipt *receipt = [[MCDownloadManager defaultInstance] downloadReceiptForURL:self.url];
 
    if (receipt.state == MCDownloadStateDownloading) {
        [self.button setTitle:@"下载" forState:UIControlStateNormal];
        [[MCDownloadManager defaultInstance] suspendWithDownloadReceipt:receipt];
    }else if (receipt.state == MCDownloadStateCompleted) {

        if ([self.delegate respondsToSelector:@selector(cell:didClickedBtn:)]) {
            [self.delegate cell:self didClickedBtn:sender];
        }
    }else {
        [self.button setTitle:@"停止" forState:UIControlStateNormal];
        [self download];
    }

}

- (void)download {
    [[MCDownloadManager defaultInstance] downloadFileWithURL:self.url
                                                    progress:^(NSProgress * _Nonnull downloadProgress, MCDownloadReceipt *receipt) {
                                                        
                                                        if ([receipt.url isEqualToString:self.url]) {
                                                            self.progressView.progress = downloadProgress.fractionCompleted ;
                                                            self.bytesLable.text = [NSString stringWithFormat:@"%0.2fm/%0.2fm", downloadProgress.completedUnitCount/1024.0/1024, downloadProgress.totalUnitCount/1024.0/1024];
                                                            self.speedLable.text = [NSString stringWithFormat:@"%@/s", receipt.speed];
                                                        }
                                    
                                                    }
                                                 destination:nil
                                                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSURL * _Nonnull filePath) {
                                                         [self.button setTitle:@"播放" forState:UIControlStateNormal];
                                                     }
                                                     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                         [self.button setTitle:@"下载" forState:UIControlStateNormal];
                                                     }];

}
@end
