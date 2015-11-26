//
//  ViewController.h
//  AudioTest
//
//  Created by 林之杰 on 15/11/24.
//  Copyright © 2015年 林之杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recorder.h"
#import "Player.h"
@interface ViewController : UIViewController{
    Recorder *recorder;
    Player *player;
    BOOL flag;
}


@end

