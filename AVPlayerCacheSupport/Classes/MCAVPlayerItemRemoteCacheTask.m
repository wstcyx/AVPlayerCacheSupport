//
//  MCAVPlayerItemRemoteCacheTask.m
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import "MCAVPlayerItemRemoteCacheTask.h"
#import "MCAVPlayerItemCacheFile.h"
#import "MCCacheSupportUtils.h"

@interface MCAVPlayerItemRemoteCacheTask ()<NSURLConnectionDataDelegate>
{
@private
    NSUInteger _offset;
    NSUInteger _requestLength;
    
    NSError *_error;
    
    NSURLConnection *_connection;
    BOOL _dataSaved;
    
    CFRunLoopRef _runloop;
}
@end

@implementation MCAVPlayerItemRemoteCacheTask

+ (NSOperationQueue *)downloadOperationQueue
{
    static dispatch_once_t onceToken;
    static NSOperationQueue *__downloadOperationQueue;
    dispatch_once(&onceToken, ^{
        __downloadOperationQueue = [[NSOperationQueue alloc] init];
        __downloadOperationQueue.name = @"com.avplayeritem.mccache.download";
    });
    return __downloadOperationQueue;
}

- (void)main
{
    @autoreleasepool
    {
        if ([self isCancelled])
        {
            [self handleFinished];
            return;
        }
        [self startURLRequestWithRequest:_loadingRequest range:_range];
        [self handleFinished];
    }
}

- (void)handleFinished
{
    if (self.finishBlock)
    {
        self.finishBlock(_error);
    }
}

- (void)cancel
{
    [super cancel];
    [_connection cancel];
    [self synchronizeCacheFileIfNeeded];
    [self stopRunLoop];
}

- (void)startURLRequestWithRequest:(AVAssetResourceLoadingRequest *)loadingRequest range:(NSRange)range
{
    NSMutableURLRequest *urlRequest = [loadingRequest.request mutableCopy];
    urlRequest.URL = [loadingRequest.request.URL mc_avplayerOriginalURL];
    _offset = 0;
    _requestLength = 0;
    if (!(_response && ![_response mc_supportRange]))
    {
        NSString *rangeValue = MCRangeToHTTPRangeHeader(range);
        if (rangeValue)
        {
            [urlRequest setValue:rangeValue forHTTPHeaderField:@"Range"];
            _offset = range.location;
            _requestLength = range.length;
        }
    }
    
    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [_connection setDelegateQueue:[[self class] downloadOperationQueue]];
    [_connection start];
    [self startRunLoop];
}

- (void)synchronizeCacheFileIfNeeded
{
    if (_dataSaved)
    {
        [_cacheFile synchronize];
    }
}

- (void)startRunLoop
{
    _runloop = CFRunLoopGetCurrent();
    CFRunLoopRun();
}

- (void)stopRunLoop
{
    if (_runloop)
    {
        CFRunLoopStop(_runloop);
    }
}

#pragma mark - handle connection
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
    if (response)
    {
        _loadingRequest.redirect = request;
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (_response || !response)
    {
        return;
    }
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        _response = (NSHTTPURLResponse *)response;
        [_cacheFile setResponse:_response];
        [_loadingRequest mc_fillContentInformation:_response];
    }
    if (![_response mc_supportRange])
    {
        _offset = 0;
    }
    if (_offset == NSUIntegerMax)
    {
        _offset = (NSUInteger)_response.mc_fileLength - _requestLength;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ([_cacheFile saveData:data atOffset:_offset synchronize:NO])
    {
        _dataSaved = YES;
        _offset += [data length];
        if (![self isCancelled])
        {
            [_loadingRequest.dataRequest respondWithData:data];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self synchronizeCacheFileIfNeeded];
    [self stopRunLoop];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self synchronizeCacheFileIfNeeded];
    _error = error;
    [self stopRunLoop];
}
@end
