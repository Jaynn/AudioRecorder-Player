//
//  FileRecorder.h
//  AudioTest
//
//  Created by 林之杰 on 15/11/25.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

#define kNumberBuffer 3
#define kBufferDurationSeconds .5

typedef struct AQRecorderFileState{
    CFStringRef					mFileName;
    AudioQueueRef				mQueue;
    AudioQueueBufferRef			mBuffers[kNumberBuffer];
    AudioFileID					mRecordFile;
    SInt64						mRecordPacket;
    AudioStreamBasicDescription	mRecordFormat;
    Boolean						mIsRunning;
}AQRFS;


@interface FileRecorder : NSObject {
    AQRFS aqrfs;
    
}
- (void) dealloc;
//- (void) CopyEncoderCookieToFile;
- (int) ComputeRecordBufferSize:(const AudioStreamBasicDescription *)format WithTime:(float)seconds;
- (void) SetUpAudioFormat:(UInt32) inFormatID;
- (void) start:(CFStringRef) inRecordFile;
- (void) stop;
@property (nonatomic, assign)AQRFS aqrfs;

@end
