//
//  MCAVPlayerItemCacheTask.m
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import "MCAVPlayerItemCacheTask.h"

@implementation MCAVPlayerItemCacheTask
- (instancetype)initWithCacheFile:(MCAVPlayerItemCacheFile *)cacheFile loadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest range:(NSRange)range
{
    self = [super init];
    if (self)
    {
        _loadingRequest = loadingRequest;
        _range = range;
        _cacheFile = cacheFile;
    }
    return self;
}

- (void)cancel
{

}

- (void)main
{
    @autoreleasepool
    {
        if (_finishBlock)
        {
            _finishBlock(nil);
        }
    }
}
@end
