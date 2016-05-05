AVPlayerCacheSupport
=============

An easy way to add cache for AVPlayer.

## Features

- [x] Cache http streaming data For AVPlayer
- [x] Support both audio & video http streaming (except [m3u](https://en.wikipedia.org/wiki/M3U) or other playlist format, e.g. [HTTP Live Streaming](https://en.wikipedia.org/wiki/HTTP_Live_Streaming), take a look at [this](http://stackoverflow.com/a/30239876) post)
- [x] Byte range access & cache
- [x] Simple API
- [ ] Cache management

## Install

Drag the folder named **AVPlayerCacheSupport** into your project.

## Usage

Before

```objc
AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
```

Now, with cache support

```objc
#import "AVPlayerItem+MCCacheSupport.h"

AVPlayerItem *item = [AVPlayerItem mc_playerItemWithRemoteURL:url];
self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];

```

## Requries

* iOS 7.0+ or MacOSX 10.9+

## License

MIT

## Demo

Sitting on WWDC 2015 sample code [AVFoundationQueuePlayer-iOS](https://developer.apple.com/library/ios/samplecode/AVFoundationQueuePlayer-iOS/Introduction/Intro.html).