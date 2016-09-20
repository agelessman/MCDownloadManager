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

@interface ViewController ()
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
@end
