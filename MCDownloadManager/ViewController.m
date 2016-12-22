//
//  ViewController.m
//  MCDownloadManager
//
//  Created by 马超 on 16/9/5.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import "ViewController.h"
#import "MCDownloadManager.h"
#import "TableViewCell.h"
#import "MCWiFiManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController () <TableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label;



@property (strong, nonatomic) NSMutableArray *urls;
@end

@implementation ViewController

- (NSMutableArray *)urls
{
    if (!_urls) {
        self.urls = [NSMutableArray array];
        for (int i = 1; i<=10; i++) {
            [self.urls addObject:[NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4", i]];

//       [self.urls addObject:@"http://localhost/MJDownload-master.zip"];
        }
    }
    return _urls;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];

    MCWiFiManager *wifiManager = [[MCWiFiManager alloc] init];
    [wifiManager scanNetworksWithCompletionHandler:^(NSArray<MCWiFi *> * _Nullable networks, MCWiFi * _Nullable currentWiFi, NSError * _Nullable error) {
        NSLog(@"name:%@ -- mac:%@",currentWiFi.wifiName,currentWiFi.wifiBSSID);
    }];
    
    NSLog(@"网关：%@",[wifiManager getGatewayIpForCurrentWiFi]);
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urls.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.url = self.urls[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MCDownloadManager defaultInstance] removeWithURL:self.urls[indexPath.row]];
        [self.tableView reloadData];
    }
}

- (IBAction)nextAction:(id)sender {
    
    NSArray *urls = @[
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F1.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F2.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F3.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F4.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F5.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F6.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F7.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F8.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F9.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F10.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F11.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F12.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F13.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F14.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F15.jpg",
          @"http://mhpic.taomanhua.com/comic/M%2F%E8%8E%BD%E8%8D%92%E7%BA%AA%2F34%E8%AF%9D%E5%86%8D%E6%88%98%E7%BF%BC%E8%9B%87%E4%BA%8C%2F16.jpg"
          ];

    for (NSString *url in urls) {
           [[MCDownloadManager defaultInstance] downloadFileWithURL:url progress:^(NSProgress * _Nonnull downloadProgress, MCDownloadReceipt * _Nonnull receipt) {
               
           } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
              
               return nil;
           } success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSURL * _Nonnull filePath) {
               
               NSLog(@"----====");
               NSFileManager *filemgr = [NSFileManager defaultManager];
               NSString *cacheFolder;
               NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
               cacheFolder = [cacheDir stringByAppendingPathComponent:@"diyizhang"];
               NSError *error = nil;
               if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
                   NSLog(@"Failed to create cache directory at %@", cacheFolder);
                   cacheFolder = nil;
               }
               MCDownloadReceipt * receipt = [[MCDownloadManager defaultInstance] downloadReceiptForURL:url];
               [filemgr copyItemAtPath:receipt.filePath toPath:[cacheFolder stringByAppendingPathComponent:receipt.filename] error:nil];
               [filemgr removeItemAtPath:receipt.filePath error:nil];
           } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
               
           }];
    }
 
    
}

- (void)cell:(TableViewCell *)cell didClickedBtn:(UIButton *)btn {
    MCDownloadReceipt *receipt = [[MCDownloadManager defaultInstance] downloadReceiptForURL:cell.url];
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    MPMoviePlayerViewController *mpc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:receipt.filePath]];
    [vc presentViewController:mpc animated:YES completion:nil];
}


@end
