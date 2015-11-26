//
//  Player.m
//  AudioTest
//
//  Created by 林之杰 on 15/11/25.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize aqps;
@synthesize audioDataLength;
@synthesize audioDataIndex;

void AQBufferCallback(
                             void *                             inUserData,
                             AudioQueueRef                      inAQ,
                             AudioQueueBufferRef                inCompleteAQBuffer) {
    
    Player *THIS = (__bridge Player *)inUserData;
    NSLog(@"DataInPlayBuffer :%u", (unsigned int)inCompleteAQBuffer->mAudioDataByteSize);
            if (THIS->audioDataIndex + EVERY_READ_LENGTH < THIS->audioDataLength) {
                memcpy(inCompleteAQBuffer->mAudioData, THIS->audioByte+THIS->audioDataIndex, EVERY_READ_LENGTH);
                THIS->audioDataIndex += EVERY_READ_LENGTH;
                inCompleteAQBuffer->mAudioDataByteSize = EVERY_READ_LENGTH;
                AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
            }
}

- (void) stop {
    NSLog(@"Play Stop");
    AudioQueueReset(aqps.mQueue);
    AudioQueueStop(aqps.mQueue, true);
}

-(void)FillBuffer:(AudioQueueRef)queue queueBuffer:(AudioQueueBufferRef)buffer
{
    if(audioDataIndex + EVERY_READ_LENGTH < audioDataLength)
    {
        memcpy(buffer->mAudioData, audioByte+audioDataIndex, EVERY_READ_LENGTH);
        audioDataIndex += EVERY_READ_LENGTH;
        buffer->mAudioDataByteSize =EVERY_READ_LENGTH;
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    }
    
}

- (void) play:(Byte *)byte Length:(SInt32)len {
    
    AudioQueueStop(aqps.mQueue, true);
    
    audioByte = byte;
    audioDataLength = len;
    
    NSLog(@"Play Start");
    
    aqps.mDataFormat.mFormatID = kAudioFormatLinearPCM;
    aqps.mDataFormat.mSampleRate = 20000;
    aqps.mDataFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    aqps.mDataFormat.mChannelsPerFrame = 1;
    aqps.mDataFormat.mBitsPerChannel = 8 * sizeof(SInt16);;
    aqps.mDataFormat.mBytesPerPacket =
        aqps.mDataFormat.mBytesPerFrame =
            aqps.mDataFormat.mChannelsPerFrame * sizeof(SInt16);
    aqps.mDataFormat.mFramesPerPacket = 1;
    
    
    AudioQueueNewOutput(&aqps.mDataFormat, AQBufferCallback, (__bridge void * _Nullable)(self), NULL, NULL, 0, &aqps.mQueue);
    if(aqps.mQueue){
//        AudioQueueFlush(aqps.mQueue);

    for (int i = 0; i < kNumberBuffers-1; i++) {
        int result = AudioQueueAllocateBuffer(aqps.mQueue, EVERY_READ_LENGTH, &aqps.mBuffer[i]);
        NSLog(@"PlayBuffer i = %d,result = %d",i,result);
        }
    }

    audioDataIndex = 0;
    
    for (int i = 0; i < kNumberBuffers -1; i++) {
        
        if (audioDataIndex + EVERY_READ_LENGTH < audioDataLength) {
            NSLog(@"%d",(int)audioDataLength);
            memcpy(aqps.mBuffer[i]->mAudioData, audioByte+audioDataIndex, EVERY_READ_LENGTH);
            audioDataIndex += EVERY_READ_LENGTH;
            aqps.mBuffer[i]->mAudioDataByteSize = EVERY_READ_LENGTH;
            AudioQueueEnqueueBuffer(aqps.mQueue, aqps.mBuffer[i], 0, NULL);
      
        }
//        [self FillBuffer:aqps.mQueue queueBuffer:aqps.mBuffer[i]];

    }
    
    
    AudioQueueStart(aqps.mQueue, NULL);
}

@end


