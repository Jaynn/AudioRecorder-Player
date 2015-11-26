//
//  Player.h
//  AudioTest
//
//  Created by 林之杰 on 15/11/25.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

#define kNumberBuffers 3
#define EVERY_READ_LENGTH 10240
typedef struct AQPlayState{
    AudioQueueRef                   mQueue;
    AudioQueueBufferRef             mBuffer[kNumberBuffers - 1];
    AudioFileID                     mAudioFile;
    AudioStreamBasicDescription     mDataFormat;
    SInt64                          mCurrentPakacket;
    UInt32                          mIsruning;
    Boolean                         mIsDone;
    Boolean                         mIsLooping;
}AQPS;
@interface Player : NSObject{
    AQPS                            aqps;
    Byte                            *audioByte;
    long                            audioDataIndex;
    long                            audioDataLength;
}

//- (id) init;
- (void) stop;
- (void) play:(Byte *)byte Length:(SInt32)len;

@property (nonatomic, assign) AQPS aqps;
@property (nonatomic, assign) long audioDataLength;
@property (nonatomic, assign) long audioDataIndex;
//- (void) play;
@end
