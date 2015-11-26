//
//  FilePlayer.m
//  AudioTest
//
//  Created by 林之杰 on 15/11/26.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import "FilePlayer.h"

@implementation FilePlayer
@synthesize aqps;

static void AQBufferCallback(void *                     inUserData,
                             AudioQueueRef              inAQ,
                             AudioQueueBufferRef        inCompleteBuffer){
    FilePlayer * THIS = (__bridge FilePlayer *)inUserData;
    
    if (THIS->aqps.mIsDone) {
        return;
    }
    UInt32  numBytes;
    UInt32  nPacket = THIS->aqps.mNumPacketsToRead;
    OSStatus result = AudioFileReadPackets(THIS->aqps.mAudioFile, false, &numBytes, inCompleteBuffer->mPacketDescriptions, THIS->aqps.mCurrentPakacket, &nPacket, inCompleteBuffer->mAudioData);
    
    if (result) {
        NSLog(@"AudioFileReadPackets failed: %d",(int)result);
    }

    if (nPacket > 0) {
        inCompleteBuffer->mAudioDataByteSize = numBytes;
        inCompleteBuffer->mPacketDescriptionCount = nPacket;
        AudioQueueEnqueueBuffer(inAQ, inCompleteBuffer, 0, NULL);
        THIS->aqps.mCurrentPakacket += nPacket;
    }
    else {
        if (THIS->aqps.mIsLooping) {
            THIS->aqps.mCurrentPakacket = 0;
            AQBufferCallback(inUserData, inAQ, inCompleteBuffer);
        }
        else {
            THIS->aqps.mIsDone = true;
            AudioQueueStop(inAQ, false);
        }
    }
}

- (void) CalculateBytesForTime:(AudioStreamBasicDescription)inDesc _:(UInt32)inMaxPacketSize _:(Float64)inSeconds _:(UInt32 *)outBufferSize _:(UInt32 *)outNumPackets{

    static const int maxBuuferSize = 0x10000;//64k
    static const int minBuuferSIze = 0x4000;//16k
    
    if (inDesc.mFramesPerPacket) {
        Float64 numPacketsFotTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
        *outBufferSize = numPacketsFotTime * inMaxPacketSize;
    }
    else {
    
        *outBufferSize = maxBuuferSize > inMaxPacketSize ? maxBuuferSize : inMaxPacketSize;
    }
    
    if (*outBufferSize > maxBuuferSize && *outBufferSize > inMaxPacketSize) {
        *outBufferSize = maxBuuferSize;
    }
    else {
    
        if (*outBufferSize < minBuuferSIze) {
            *outBufferSize = minBuuferSIze;
        }
    }
    *outNumPackets = *outBufferSize / inMaxPacketSize;
}


-(void) start:(BOOL)inResume {

    if ((aqps.mQueue == NULL) && (aqps.mFilePath != NULL)) {
        //CreateQueue
    }
    aqps.mIsDone = false;
    
    if (!inResume) {
        aqps.mCurrentPakacket = 0;
        
        for (int i=0; i<kNumberBuffer; ++i) {
            AQBufferCallback((__bridge void *)(self), aqps.mQueue, aqps.mBuffer[i]);
        }
    }
    AudioQueueStart(aqps.mQueue, NULL);

}

-(void) stop {
    
    aqps.mIsDone = true;
    AudioQueueStop(aqps.mQueue, true);
}

-(void) pause {

    AudioQueuePause(aqps.mQueue);
}

- (void) CreateQueueForFile:(CFStringRef)inFilePath {
    
    CFURLRef File = NULL;
    
    if (aqps.mFilePath == NULL) {
        aqps.mIsLooping = false;
        
        File = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, inFilePath, kCFURLPOSIXPathStyle, false);
        if (!File) {
            NSLog(@"Can not parse file path");
        }
        
        AudioFileOpenURL(File, kAudioFileReadPermission, 0, &aqps.mAudioFile);
        CFRelease(File);
        
        UInt32 size = sizeof(aqps.mDataFormat);
        AudioFileGetProperty(aqps.mAudioFile, kAudioFilePropertyDataFormat, &size, &aqps.mDataFormat);
        aqps.mFilePath = CFStringCreateCopy(kCFAllocatorDefault, inFilePath);
        
    }
    //set up new queue
    AudioQueueNewOutput(&aqps.mDataFormat, AQBufferCallback, (__bridge void * _Nullable)(self), NULL, NULL, 0, &aqps.mQueue);
    
    UInt32 bufferByteSize;
    UInt32 maxPacketSize;
    UInt32 size = sizeof(maxPacketSize);
    AudioFileGetProperty(aqps.mAudioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
    
    [self CalculateBytesForTime:aqps.mDataFormat _:maxPacketSize _:kBufferDurationSeconds _:&bufferByteSize _:&aqps.mNumPacketsToRead];
    
    //TO DO : handle cookie data
    
    //
    
    for (int i=0; i<kNumberBuffer; ++i) {
        AudioQueueAllocateBuffer(aqps.mQueue, bufferByteSize, &aqps.mBuffer[i]);
    }
    
    aqps.mIsInitialized = true;
}

- (void) DisposeQueue:(Boolean)inDisposeFile {

    if (aqps.mQueue) {
        AudioQueueDispose(aqps.mQueue, true);
        aqps.mQueue = NULL;
    }
    if (inDisposeFile) {
        if (aqps.mAudioFile) {
            AudioFileClose(aqps.mAudioFile);
            aqps.mAudioFile = 0;
        }
        if (aqps.mFilePath) {
            CFRelease(aqps.mFilePath);
            aqps.mFilePath = NULL;
        }
    }
    aqps.mIsInitialized = false;
}
@end
