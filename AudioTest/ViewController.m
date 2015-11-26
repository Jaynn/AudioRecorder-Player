//
//  ViewController.m
//  AudioTest
//
//  Created by 林之杰 on 15/11/24.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (IBAction)recordOnClick:(id)sender;
- (IBAction)stopOnClick:(id)sender;
- (IBAction)playbackOnClick:(id)sender;
- (IBAction)FileRecord:(id)sender;
- (IBAction)FIleRecordStop:(id)sender;
- (IBAction)FilePlay:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    recorder = [[Recorder alloc]init ];
    flag = NO;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordOnClick:(id)sender {
    if (flag) {
        [recorder stop];
        flag = NO;
    }else{
        [recorder start];
        flag = YES;
    }
}

- (IBAction)stopOnClick:(id)sender {
     [recorder stop];
}

- (IBAction)playbackOnClick:(id)sender {
    player = [[Player alloc]init];
    [player play:[recorder getBytes] Length:recorder.audioDataLength];
}

- (IBAction)FileRecord:(id)sender {
}

- (IBAction)FIleRecordStop:(id)sender {
}

- (IBAction)FilePlay:(id)sender {
}
@end
