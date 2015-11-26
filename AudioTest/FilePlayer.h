//
//  FilePlayer.h
//  AudioTest
//
//  Created by 林之杰 on 15/11/26.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#define kNumberBuffer 3
#define kBufferDurationSeconds .5

typedef struct AQPlayState{
    AudioQueueRef                   mQueue;
    AudioQueueBufferRef             mBuffer[kNumberBuffer];
    AudioFileID                     mAudioFile;
    CFStringRef						mFilePath;
    AudioStreamBasicDescription     mDataFormat;
    Boolean							mIsInitialized;
    UInt32							mNumPacketsToRead;
    SInt64                          mCurrentPakacket;
    UInt32                          mIsruning;
    Boolean                         mIsDone;
    Boolean                         mIsLooping;
}AQPS;

@interface FilePlayer : NSObject {
    AQPS                aqps;
    
}
- (void) start:(BOOL)inResume;
- (void) stop;
- (void) pause;
static void isRunningProc(void *,AudioQueueRef,AudioQueuePropertyID);
- (void) CalculateBytesForTime:(AudioStreamBasicDescription)inDesc _:(UInt32)inMaxPacketSize _:(Float64)inSeconds _:(UInt32 *)outBufferSize _:(UInt32 *)outNumPackets;
- (void) CreateQueueForFile:(CFStringRef)inFilePath;
- (void) DisposeQueue:(Boolean) inDisposeFile;
@property (nonatomic,assign) AQPS aqps;

@end
