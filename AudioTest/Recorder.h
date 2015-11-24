//
//  Recorder.h
//  AudioTest
//
//  Created by 林之杰 on 15/11/24.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
static const int kNumberBuffers = 3;
typedef struct AQRecorderState{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               mQueue;
    AudioQueueBufferRef         mBuffers[kNumberBuffers];
    AudioFileID                 mAudioFile;
    UInt32                      bufferByteSize;
    SInt64                      mCurrentPacket;
    BOOL                        mIsRunning;
}AQRS;

@interface Recorder : NSObject
{
    AQRS                audioQueueRecorederState;
    AudioFileTypeID     fileFormat;
    SInt32              audioDataLength;
    Byte                audioByte[999999];
    SInt32              audioDataIndex;
}
@property (nonatomic, assign) AQRS aqrs;
@property (nonatomic, assign) SInt32 audioDataLength;
- (id) init;
- (void) start;
- (void) stop;
- (void) pause;
@end
