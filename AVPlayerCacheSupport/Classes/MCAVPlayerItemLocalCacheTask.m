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
        
        NSUInteger offset = _range.location;
        NSUInteger lengthPerRead = 10000;
        while (offset < NSMaxRange(_range))
        {
            @autoreleasepool
            {
                NSRange range = NSMakeRange(offset, MIN(NSMaxRange(_range) - offset,lengthPerRead));
                NSData *data = [_cacheFile dataWithRange:_range];
                [_loadingRequest.dataRequest respondWithData:data];
                offset = NSMaxRange(range);
            }
        }
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
