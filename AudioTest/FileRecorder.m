//
//  FileRecorder.m
//  AudioTest
//
//  Created by 林之杰 on 15/11/25.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import "FileRecorder.h"

@implementation FileRecorder
@synthesize aqrfs;

static void MyInputHandler(
                           void *                   inDataInfo,
                           AudioQueueRef            inAQ,
                           AudioQueueBufferRef      inBuffer,
                           const AudioTimeStamp *   inStartTime,
                           UInt32                   inNumberPacket,
                           const AudioStreamPacketDescription * inPacketDesc) {
    
   
    FileRecorder * THIS = (__bridge FileRecorder *)inDataInfo;
    
    if (inNumberPacket > 0) {
        AudioFileWritePackets(THIS->aqrfs.mRecordFile , FALSE, inBuffer->mAudioDataByteSize, inPacketDesc, THIS->aqrfs.mRecordPacket, &inNumberPacket, inBuffer->mAudioData);
        
        THIS->aqrfs.mRecordPacket += inNumberPacket;
    }
    
    if (THIS->aqrfs.mIsRunning) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    
    }
    
}

- (void) dealloc {
    
    AudioQueueDispose(aqrfs.mQueue, true);
    AudioFileClose(aqrfs.mRecordFile);
    if (aqrfs.mFileName) {
        CFRelease(aqrfs.mFileName);
    }
}

- (void) SetUpAudioFormat:(UInt32)inFormatID {
    
    aqrfs.mRecordFormat.mSampleRate = 20000;
    aqrfs.mRecordFormat.mChannelsPerFrame = 1;
    aqrfs.mRecordFormat.mFormatID = inFormatID;
    
    if (inFormatID == kAudioFormatLinearPCM) {
        
        aqrfs.mRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        aqrfs.mRecordFormat.mBitsPerChannel = 16;
        aqrfs.mRecordFormat.mBytesPerPacket =
            aqrfs.mRecordFormat.mBytesPerFrame =
                (aqrfs.mRecordFormat.mBitsPerChannel / 8) * aqrfs.mRecordFormat.mChannelsPerFrame;
        aqrfs.mRecordFormat.mFramesPerPacket = 1;
    }
    
}

- (int) ComputeRecordBufferSize:(const AudioStreamBasicDescription *)format WithTime:(float)seconds {
    int packets, frames, bytes = 0;
    frames = (int)ceil(seconds * format->mSampleRate);
    
    if (format->mBytesPerFrame > 0) {
        bytes = frames * format->mBytesPerFrame;
    }else{
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket) {
            maxPacketSize = format->mBytesPerPacket;
        }else{
            UInt32 propertySize = sizeof(maxPacketSize);
            AudioQueueGetProperty(aqrfs.mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &propertySize);
        }
        
        if (format->mFramesPerPacket > 0) {
            packets = frames/format->mFramesPerPacket;
        }else{
            packets = frames;
        }
        if (packets == 0) {
            packets = 1;
        }
        bytes = packets * maxPacketSize;
    }
    NSLog(@"The Size of Record Buffer : %d",bytes);
    return bytes;
}

- (void) start:(CFStringRef)inRecordFile {

    int bufferByteSize;
    UInt32 size;
    CFURLRef url = nil;
    
    aqrfs.mFileName = CFStringCreateCopy(kCFAllocatorDefault, inRecordFile);
    [self SetUpAudioFormat:kAudioFormatLinearPCM];
    
    AudioQueueNewInput(&aqrfs.mRecordFormat, MyInputHandler, (__bridge void * _Nullable)(self), NULL, NULL, 0, &aqrfs.mQueue);
    aqrfs.mRecordPacket  = 0;
    
    size = sizeof(aqrfs.mRecordFormat);
    AudioQueueGetProperty(aqrfs.mQueue, kAudioQueueProperty_StreamDescription, &aqrfs.mRecordFormat,&size);
    NSString *recordFile = [NSTemporaryDirectory() stringByAppendingString:(__bridge NSString *)inRecordFile];
    url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)recordFile, NULL);
    
    OSStatus status = AudioFileCreateWithURL(url, kAudioFileCAFType, &aqrfs.mRecordFormat, kAudioFileFlags_EraseFile, &aqrfs.mRecordFile);
    NSLog(@"%d",(int)status);
    
    //TO DO: Cookie Copy
    
    bufferByteSize = [self ComputeRecordBufferSize:&aqrfs.mRecordFormat WithTime:kBufferDurationSeconds];
    for (int i = 0; i< kNumberBuffer; ++i) {
        AudioQueueAllocateBuffer(aqrfs.mQueue, bufferByteSize, &aqrfs.mBuffers[i]);
        AudioQueueEnqueueBuffer(aqrfs.mQueue, aqrfs.mBuffers[i], 0, NULL);
        
    }
    
    aqrfs.mIsRunning = true;
    AudioQueueStart(aqrfs.mQueue, NULL);
    
}

- (void) stop {
    aqrfs.mIsRunning = false;
    
    if (aqrfs.mFileName) {
        CFRelease(aqrfs.mFileName);
        aqrfs.mFileName = NULL;
    }
    AudioQueueDispose(aqrfs.mQueue, true);
    AudioFileClose(aqrfs.mRecordFile);
}


@end
