# MCDownloadManager
A simple and convenient multi task download manager

![](http://images2015.cnblogs.com/blog/637318/201609/637318-20160912112148570-1105374973.gif)

## Attention

这个版本默认只支持同时下载10个文件
This version only supports 10 file downloads at the same time.

若要支持更多，请修改下边的代码

`configuration.HTTPMaximumConnectionsPerHost = 10;`

**添加了速度提示（比如：400KB/s）**

## Installation
### Cocoapods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build MCDownloadManager 1.0.0+.

To integrate MCDownloadManager into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'MCDownloadManager', '~> 1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```



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
	