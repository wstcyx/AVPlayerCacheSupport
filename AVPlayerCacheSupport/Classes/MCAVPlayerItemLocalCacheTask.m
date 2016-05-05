//
//  MCAVPlayerItemLocalCacheTask.m
//  AVPlayerCacheSupport
//
//  Created by Chengyin on 16/3/21.
//  Copyright © 2016年 Chengyin. All rights reserved.
//

#import "MCAVPlayerItemLocalCacheTask.h"
#import "MCAVPlayerItemCacheFile.h"
#import "MCCacheSupportUtils.h"

@implementation MCAVPlayerItemLocalCacheTask
- (void)main
{
    @autoreleasepool
    {
        if ([self isCancelled])
        {
            [self handleFinished];
            return;
        }
        NSData *data = [_cacheFile dataWithRange:_range];
        [_loadingRequest.dataRequest respondWithData:data];
        [self handleFinished];
    }
}

- (void)handleFinished
{
    if (self.finishBlock)
    {
        self.finishBlock(nil);
    }
}
@end
