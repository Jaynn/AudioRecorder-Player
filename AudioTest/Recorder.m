//
//  Recorder.m
//  AudioTest
//
//  Created by 林之杰 on 15/11/24.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import "Recorder.h"


@implementation Recorder

@synthesize aqrs;
@synthesize audioDataLength;
void  HandleInputBuffer (
                                void *                              aqData,
                                AudioQueueRef                       inAQ,
                                AudioQueueBufferRef                 inBuffer,
                                const AudioTimeStamp *              inStartTime,
                                UInt32                              inNumberPackets,
                                const AudioStreamBasicDescription * PacketDesc) {
    
    Recorder * recorder = (__bridge Recorder*) aqData;
    if (inNumberPackets > 0){

        NSLog(@"DataInRecorederBuffer :%u", (unsigned int)inBuffer->mAudioDataByteSize);
//        [recorder processAudioBuffer:inBuffer withQueue:inAQ];
        memcpy(recorder->audioByte + recorder->audioDataIndex,
               inBuffer->mAudioData, inBuffer->mAudioDataByteSize);
        recorder->audioDataIndex += inBuffer->mAudioDataByteSize;
        recorder->audioDataLength = recorder->audioDataIndex;
        NSLog(@"%d",(int)recorder->audioDataLength);
        NSLog(@"  %d",(int)recorder->audioDataIndex);
    }
    if(recorder.aqrs.mIsRunning){
        AudioQueueEnqueueBuffer(recorder.aqrs.mQueue, inBuffer, 0, NULL);
    }
}
- (id) init{
    self = [super init];
    if (self) {
        //setup format        int sampleSize = aqrs.mIsRunning ? sizeof(float) : sizeof(SInt16);
        aqrs.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        aqrs.mDataFormat.mSampleRate = 20000;
        aqrs.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |kLinearPCMFormatFlagIsPacked;
        aqrs.mDataFormat.mChannelsPerFrame = 1;
        aqrs.mDataFormat.mBitsPerChannel = 8 * sizeof(SInt16);
        aqrs.mDataFormat.mBytesPerPacket =
            aqrs.mDataFormat.mBytesPerFrame =
                aqrs.mDataFormat.mChannelsPerFrame * sizeof(SInt16);
        aqrs.mDataFormat.mFramesPerPacket = 1;
//        aqrs.mDataFormat.mReserved = 0;
        aqrs.bufferByteSize = 1000;
        //setup a queue
        NSLog(@"initial");
        AudioQueueNewInput(
                           &aqrs.mDataFormat,
                           HandleInputBuffer,
                           (__bridge void * _Nullable)(self),
                           NULL, NULL, 0, &aqrs.mQueue);
//            AudioQueueNewOutput(&aqrs.mDataFormat,
//                                HandleInputBuffer,
//                                (__bridge void*)(self), NULL, NULL, 0, &aqrs.mQueue);
        for (int i = 0; i<kNumberBuffers; i++) {
            //setup buffer
            AudioQueueAllocateBuffer(aqrs.mQueue, aqrs.bufferByteSize, &aqrs.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqrs.mQueue, aqrs.mBuffers[i], 0, NULL);
        }
        aqrs.mCurrentPacket = 0;
        aqrs.mIsRunning = 1;
    }
    audioDataIndex = 0;
    return self;
}
- (void) dealloc {
    AudioQueueStop(aqrs.mQueue, true);
    aqrs.mIsRunning = 0;
    AudioQueueDispose(aqrs.mQueue, true);
}

- (void) start {
    NSLog(@"Record Start");
    AudioQueueStart(aqrs.mQueue, NULL);
}

- (void) stop {
        NSLog(@"Record Stop");
    AudioQueueStop(aqrs.mQueue, true);
    aqrs.mIsRunning = 0;
    AudioQueueDispose(aqrs.mQueue, true);
}

- (void) pause {
        NSLog(@"Record Pause");
    AudioQueuePause(aqrs.mQueue);
}

- (Byte *) getBytes
{
    return audioByte;
}
//- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
//{
//    NSLog(@"processAudioData :%u", (unsigned int)buffer->mAudioDataByteSize);
//    memcpy(audioByte+audioDataIndex, buffer->mAudioData, buffer->mAudioDataByteSize);
//    audioDataIndex +=buffer->mAudioDataByteSize;
//    audioDataLength = audioDataIndex;
//    NSLog(@"%d",(int)audioDataLength);
//}

@end
