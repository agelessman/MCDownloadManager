# MCDownloadManager
A simple and convenient multi task download manager

![](http://images2015.cnblogs.com/blog/637318/201609/637318-20160912112148570-1105374973.gif)

## Attention

这个版本默认只支持同时下载10个文件
This version only supports 10 file downloads at the same time.

若要支持更多，请修改下边的代码

`configuration.HTTPMaximumConnectionsPerHost = 10;`

**添加了速度提示（比如：400KB/s）**

## Usage
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
	