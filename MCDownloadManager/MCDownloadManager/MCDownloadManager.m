//
//  MCDownloadManager.m
//  MCDownloadManager
//
//  Created by 马超 on 16/9/5.
//  Copyright © 2016年 qikeyun. All rights reserved.
//

#import "MCDownloadManager.h"
#import <CommonCrypto/CommonDigest.h>


NSString * const MCDownloadCacheFolderName = @"MCDownloadCache";

static NSString * cacheFolder() {
    NSFileManager *filemgr = [NSFileManager defaultManager];
    static NSString *cacheFolder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cacheFolder) {
            NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
            cacheFolder = [cacheDir stringByAppendingPathComponent:MCDownloadCacheFolderName];
        }
        NSError *error = nil;
        if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create cache directory at %@", cacheFolder);
            cacheFolder = nil;
        }
    });
    return cacheFolder;
}

static NSString * LocalReceiptsPath() {
    return [cacheFolder() stringByAppendingPathComponent:@"receipts.data"];
}

static unsigned long long fileSizeForPath(NSString *path) {
    
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

static NSString * getMD5String(NSString *str) {
    
    if (str == nil) return nil;
    
    const char *cstring = str.UTF8String;
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstring, (CC_LONG)strlen(cstring), bytes);
    
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", bytes[i]];
    }
    return md5String;
}



@interface MCDownloadReceipt()

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *truename;
@property (nonatomic, copy) NSString *speed;  // KB/s
@property (nonatomic, assign) MCDownloadState state;

@property (assign, nonatomic) long long totalBytesWritten;
@property (assign, nonatomic) long long totalBytesExpectedToWrite;
@property (nonatomic, copy) NSProgress *progress;

@property (strong, nonatomic) NSOutputStream *stream;

@property (nonatomic, assign) NSUInteger totalRead;
@property (nonatomic, strong) NSDate *date;


@end
@implementation MCDownloadReceipt

- (NSOutputStream *)stream
{
    if (_stream == nil) {
        _stream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:YES];
    }
    return _stream;
}

- (NSString *)filePath {

    NSString *path = [cacheFolder() stringByAppendingPathComponent:self.filename];
    if (![path isEqualToString:_filePath] ) {
        if (_filePath && ![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            NSString *dir = [_filePath stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _filePath = path;
    }
    
    return _filePath;
}


- (NSString *)filename {
    if (_filename == nil) {
        NSString *pathExtension = self.url.pathExtension;
        if (pathExtension.length) {
            _filename = [NSString stringWithFormat:@"%@.%@", getMD5String(self.url), pathExtension];
        } else {
            _filename = getMD5String(self.url);
        }
    }
    return _filename;
}

- (NSString *)truename {
    if (_truename == nil) {
        _truename = self.url.lastPathComponent;
    }
    return _truename;
}

- (NSProgress *)progress {
    if (_progress == nil) {
        _progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    @try {
        _progress.totalUnitCount = self.totalBytesExpectedToWrite;
        _progress.completedUnitCount = self.totalBytesWritten;
    } @catch (NSException *exception) {
        
    }
    return _progress;
}

- (long long)totalBytesWritten {
    
    return fileSizeForPath(self.filePath);
}


- (instancetype)initWithURL:(NSString *)url {
    if (self = [self init]) {
   
        self.url = url;
        self.totalBytesExpectedToWrite = 1;
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    [aCoder encodeObject:self.filePath forKey:NSStringFromSelector(@selector(filePath))];
    [aCoder encodeObject:@(self.state) forKey:NSStringFromSelector(@selector(state))];
    [aCoder encodeObject:self.filename forKey:NSStringFromSelector(@selector(filename))];
    [aCoder encodeObject:@(self.totalBytesWritten) forKey:NSStringFromSelector(@selector(totalBytesWritten))];
    [aCoder encodeObject:@(self.totalBytesExpectedToWrite) forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(url))];
        self.filePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filePath))];
        self.state = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(state))] unsignedIntegerValue];
        self.filename = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filename))];
        self.totalBytesWritten = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesWritten))] unsignedIntegerValue];
        self.totalBytesExpectedToWrite = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))] unsignedIntegerValue];

    }
    return self;
}


@end


#pragma mark -

@interface MCDownloadManager () <NSURLSessionDataDelegate>
@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;
@property (strong, nonatomic) NSURLSession *session;

@property (nonatomic, assign) NSInteger maximumActiveDownloads;
@property (nonatomic, assign) NSInteger activeRequestCount;

@property (nonatomic, strong) NSMutableArray *queuedTasks;
@property (nonatomic, strong) NSMutableDictionary *tasks;

@property (nonatomic, strong) NSMutableDictionary *allDownloadReceipts;

@end

@implementation MCDownloadManager

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    configuration.HTTPMaximumConnectionsPerHost = 10;
    return configuration;
}


- (instancetype)init {
    

    NSURLSessionConfiguration *defaultConfiguration = [self.class defaultURLSessionConfiguration];
  
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:self delegateQueue:queue];
    
    return [self initWithSession:session
                 downloadPrioritization:MCDownloadPrioritizationFIFO
                 maximumActiveDownloads:4 ];
}


- (instancetype)initWithSession:(NSURLSession *)session downloadPrioritization:(MCDownloadPrioritization)downloadPrioritization maximumActiveDownloads:(NSInteger)maximumActiveDownloads {
    if (self = [super init]) {
        
        self.session = session;
        self.downloadPrioritizaton = downloadPrioritization;
        self.maximumActiveDownloads = maximumActiveDownloads;
        
        self.queuedTasks = [[NSMutableArray alloc] init];
        self.tasks = [[NSMutableDictionary alloc] init];
        self.activeRequestCount = 0;
        
        NSString *name = [NSString stringWithFormat:@"com.mc.downloadManager.synchronizationqueue-%@", [[NSUUID UUID] UUIDString]];
        self.synchronizationQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
    }
    
    return self;
}

+ (instancetype)defaultInstance {
    static MCDownloadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (NSMutableDictionary *)allDownloadReceipts {
    if (_allDownloadReceipts == nil) {
         NSDictionary *receipts = [NSKeyedUnarchiver unarchiveObjectWithFile:LocalReceiptsPath()];
        _allDownloadReceipts = receipts != nil ? receipts.mutableCopy : [NSMutableDictionary dictionary];
    }
    return _allDownloadReceipts;
}

- (void)saveReceipts:(NSDictionary *)receipts {
    [NSKeyedArchiver archiveRootObject:receipts toFile:LocalReceiptsPath()];
}

- (MCDownloadReceipt *)updateReceiptWithURL:(NSString *)url state:(MCDownloadState)state {
    MCDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    receipt.state = state;

    [self saveReceipts:self.allDownloadReceipts];

    return receipt;
}


- (MCDownloadReceipt *)downloadFileWithURL:(NSString *)url
                                         progress:(void (^)(NSProgress * _Nonnull,MCDownloadReceipt *receipt))downloadProgressBlock
                                         destination:(NSURL *  (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination
                                          success:(nullable void (^)(NSURLRequest * _Nullable, NSHTTPURLResponse * _Nullable, NSURL * _Nonnull))success
                                          failure:(nullable void (^)(NSURLRequest * _Nullable, NSHTTPURLResponse * _Nullable, NSError * _Nonnull))failure {
 
   __block MCDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    
    dispatch_sync(self.synchronizationQueue, ^{
        NSString *URLIdentifier = url;
        if (URLIdentifier == nil) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(nil, nil, error);
                });
            }
            return;
        }

        receipt.successBlock = success;
        receipt.failureBlock = failure;
        receipt.progressBlock = downloadProgressBlock;
        
        if (receipt.state == MCDownloadStateCompleted && receipt.totalBytesWritten == receipt.totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (receipt.successBlock) {
                    receipt.successBlock(nil,nil,[NSURL URLWithString:receipt.url]);
                }
            });
            return ;
        }
        
        if (receipt.state == MCDownloadStateDownloading && receipt.totalBytesWritten != receipt.totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (receipt.progressBlock) {
                    receipt.progressBlock(receipt.progress,receipt);
                }
            });
            return ;
        }

        NSURLSessionDataTask *task = self.tasks[receipt.url];
        // 当请求暂停一段时间后。转态会变化。所有要判断下状态
        if (!task || ((task.state != NSURLSessionTaskStateRunning) && (task.state != NSURLSessionTaskStateSuspended))) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:receipt.url]];
            
            NSString *range = [NSString stringWithFormat:@"bytes=%zd-", receipt.totalBytesWritten];
            [request setValue:range forHTTPHeaderField:@"Range"];
            NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
            task.taskDescription = receipt.url;
            self.tasks[receipt.url] = task;
            [self.queuedTasks addObject:task];
        }

        [self resumeWithDownloadReceipt:receipt];

        
        });
    return receipt;
}



#pragma mark - -----------------------

- (NSURLSessionDataTask*)safelyRemoveTaskWithURLIdentifier:(NSString *)URLIdentifier {
    __block NSURLSessionDataTask *task = nil;
    dispatch_sync(self.synchronizationQueue, ^{
        task = [self removeTaskWithURLIdentifier:URLIdentifier];
    });
    return task;
}

//This method should only be called from safely within the synchronizationQueue
- (NSURLSessionDataTask *)removeTaskWithURLIdentifier:(NSString *)URLIdentifier {
    NSURLSessionDataTask *task = self.tasks[URLIdentifier];
    [self.tasks removeObjectForKey:URLIdentifier];
    return task;
}

- (void)safelyDecrementActiveTaskCount {
    dispatch_sync(self.synchronizationQueue, ^{
        if (self.activeRequestCount > 0) {
            self.activeRequestCount -= 1;
        }
    });
}

- (void)safelyStartNextTaskIfNecessary {
    dispatch_sync(self.synchronizationQueue, ^{
        if ([self isActiveRequestCountBelowMaximumLimit]) {
            while (self.queuedTasks.count > 0) {
                NSURLSessionDataTask *task = [self dequeueTask];
                MCDownloadReceipt *receipt = [self downloadReceiptForURL:task.taskDescription];
                if (task.state == NSURLSessionTaskStateSuspended && receipt.state == MCDownloadStateWillResume) {
                    [self startTask:task];
                    break;
                }
            }
        }
    });
}


- (void)startTask:(NSURLSessionDataTask *)task {
    [task resume];
    ++self.activeRequestCount;
    [self updateReceiptWithURL:task.taskDescription state:MCDownloadStateDownloading];
}

- (void)enqueueTask:(NSURLSessionDataTask *)task {
    switch (self.downloadPrioritizaton) {
        case MCDownloadPrioritizationFIFO:  //
            [self.queuedTasks addObject:task];
            break;
        case MCDownloadPrioritizationLIFO:  //
            [self.queuedTasks insertObject:task atIndex:0];
            break;
    }
}

- (NSURLSessionDataTask *)dequeueTask {
    NSURLSessionDataTask *task = nil;
    task = [self.queuedTasks firstObject];
    [self.queuedTasks removeObject:task];
    return task;
}

- (BOOL)isActiveRequestCountBelowMaximumLimit {
    return self.activeRequestCount < self.maximumActiveDownloads;
}


#pragma mark - 
- (MCDownloadReceipt *)downloadReceiptForURL:(NSString *)url {
    
    if (url == nil) return nil;
    MCDownloadReceipt *receipt = self.allDownloadReceipts[url];
    if (receipt) return receipt;
    receipt = [[MCDownloadReceipt alloc] initWithURL:url];
    receipt.state = MCDownloadStateNone;
    receipt.totalBytesExpectedToWrite = 1;

    dispatch_sync(self.synchronizationQueue, ^{
        [self.allDownloadReceipts setObject:receipt forKey:url];
        [self saveReceipts:self.allDownloadReceipts];
    });

    return receipt;
}

#pragma mark -  NSNotification
- (void)applicationWillTerminate:(NSNotification *)not {
    
    [self suspendAll];
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)not {
    
    [self suspendAll];
}

#pragma mark - MCDownloadControlDelegate

- (void)resumeWithURL:(NSString *)url {
    
    if (url == nil) return;
    
    MCDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    [self resumeWithDownloadReceipt:receipt];
    
}
- (void)resumeWithDownloadReceipt:(MCDownloadReceipt *)receipt {
    
    if ([self isActiveRequestCountBelowMaximumLimit]) {
        NSURLSessionDataTask *task = self.tasks[receipt.url];
        // 当请求暂停一段时间后。转态会变化。所有要判断下状态
        if (!task || ((task.state != NSURLSessionTaskStateRunning) && (task.state != NSURLSessionTaskStateSuspended))) {
            [self downloadFileWithURL:receipt.url progress:receipt.progressBlock destination:nil success:receipt.successBlock failure:receipt.failureBlock];
        }else {
            [self startTask:self.tasks[receipt.url]];
            receipt.date = [NSDate date];
        }
        
    }else {
        receipt.state = MCDownloadStateWillResume;
        [self saveReceipts:self.allDownloadReceipts];
        [self enqueueTask:self.tasks[receipt.url]];
    }
}

- (void)suspendAll {
    
    for (NSURLSessionDataTask *task in self.queuedTasks) {
        
        MCDownloadReceipt *receipt = [self downloadReceiptForURL:task.taskDescription];
        receipt.state = MCDownloadStateFailed;
        [task suspend];
        [self safelyDecrementActiveTaskCount];
    }
    [self saveReceipts:self.allDownloadReceipts];

}
-(void)suspendWithURL:(NSString *)url {
    
     if (url == nil) return;
    
    MCDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    [self suspendWithDownloadReceipt:receipt];
    
}
- (void)suspendWithDownloadReceipt:(MCDownloadReceipt *)receipt {
    
    [self updateReceiptWithURL:receipt.url state:MCDownloadStateSuspened];
    NSURLSessionDataTask *task = self.tasks[receipt.url];
    if (task) {
        [task suspend];
        [self safelyDecrementActiveTaskCount];
        [self safelyStartNextTaskIfNecessary];
    }

}


- (void)removeWithURL:(NSString *)url {
    
    if (url == nil) return;
    
    MCDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    [self removeWithDownloadReceipt:receipt];
    
}
- (void)removeWithDownloadReceipt:(MCDownloadReceipt *)receipt {
    
    NSURLSessionDataTask *task = self.tasks[receipt.url];
    if (task) {
        [task cancel];
    }
    
    [self.queuedTasks removeObject:task];
    [self safelyRemoveTaskWithURLIdentifier:receipt.url];

    dispatch_sync(self.synchronizationQueue, ^{
        [self.allDownloadReceipts removeObjectForKey:receipt.url];
        [self saveReceipts:self.allDownloadReceipts];
    });
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:receipt.filePath error:nil];

}
#pragma mark - <NSURLSessionDataDelegate>
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    MCDownloadReceipt *receipt = [self downloadReceiptForURL:dataTask.taskDescription];
    receipt.totalBytesExpectedToWrite = receipt.totalBytesWritten + dataTask.countOfBytesExpectedToReceive;
    receipt.state = MCDownloadStateDownloading;

    [self saveReceipts:self.allDownloadReceipts];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{

    dispatch_sync(self.synchronizationQueue, ^{

        __block NSError *error = nil;
        MCDownloadReceipt *receipt = [self downloadReceiptForURL:dataTask.taskDescription];

        // Speed
        receipt.totalRead += data.length;
        NSDate *currentDate = [NSDate date];
        if ([currentDate timeIntervalSinceDate:receipt.date] >= 1) {
            double time = [currentDate timeIntervalSinceDate:receipt.date];
            long long speed = receipt.totalRead/time;
            receipt.speed = [self formatByteCount:speed];
            receipt.totalRead = 0.0;
            receipt.date = currentDate;
        }
        
        // Write Data
        NSInputStream *inputStream =  [[NSInputStream alloc] initWithData:data];
        NSOutputStream *outputStream = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:receipt.filePath] append:YES];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [inputStream open];
        [outputStream open];
        
        while ([inputStream hasBytesAvailable] && [outputStream hasSpaceAvailable]) {
            uint8_t buffer[1024];
            
            NSInteger bytesRead = [inputStream read:buffer maxLength:1024];
            if (inputStream.streamError || bytesRead < 0) {
                error = inputStream.streamError;
                break;
            }
            
            NSInteger bytesWritten = [outputStream write:buffer maxLength:(NSUInteger)bytesRead];
            if (outputStream.streamError || bytesWritten < 0) {
                error = outputStream.streamError;
                break;
            }
            
            if (bytesRead == 0 && bytesWritten == 0) {
                break;
            }
        }
        [outputStream close];
        [inputStream close];
        
        receipt.progress.totalUnitCount = receipt.totalBytesExpectedToWrite;
        receipt.progress.completedUnitCount = receipt.totalBytesWritten;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.progressBlock) {
                receipt.progressBlock(receipt.progress,receipt);
            }
        });
    });

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    MCDownloadReceipt *receipt = [self downloadReceiptForURL:task.taskDescription];
    
    if (error) {
        receipt.state = MCDownloadStateFailed;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.failureBlock) {
                receipt.failureBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,error);
            }
        });
    }else {
        [receipt.stream close];
        receipt.stream = nil;
        receipt.state = MCDownloadStateCompleted;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.successBlock) {
                receipt.successBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,task.originalRequest.URL);
            }
        });
    }

    [self saveReceipts:self.allDownloadReceipts];
    [self safelyDecrementActiveTaskCount];
    [self safelyStartNextTaskIfNecessary];
    
}

- (NSString*)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}
@end
