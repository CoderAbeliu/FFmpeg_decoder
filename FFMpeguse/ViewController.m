//
//  ViewController.m
//  FFMpeguse
//
//  Created by Abe_liu on 2017/11/15.
//  Copyright © 2017年 Abe_liu. All rights reserved.
//

#import "ViewController.h"
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavutil/avutil.h>
#import <libswscale/swscale.h>
#import <libavutil/imgutils.h>
#import "OpenglView.h"
#import "MoviePlayer.h"

@interface ViewController ()
{
    AVFormatContext *pFormartContext;
    AVInputFormat *inputFormart;
    AVCodecContext *pCodecContext;
    AVCodecParameters  *pCodecPar;
    AVCodec *codeC;
    AVPacket pPackct;
    AVFrame *pFrame,*pYUVFrame;
    AVSubtitle subtitle;
    uint8_t data;
    int videoStream;
    CADisplayLink *displayLink;
    UIImageView *imageView;
}
@property(nonatomic,strong)MoviePlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
    imageView.image=[UIImage imageNamed:@"main_demo_1"];
    [self.view addSubview:imageView];
    [self test2];
    
}

//用cadisplaylink
-(void)test2{
    NSString *path=[[NSBundle mainBundle]pathForResource:@"sintel" ofType:@"mov"];
    _player=[[MoviePlayer alloc]initWithVideo:path];
    int tns, thh, tmm, tss;
    tns = _player.duration;
    thh = tns / 3600;
    tmm = (tns % 3600) / 60;
    tss = tns % 60;
    [_player seekTime:0];
    [NSTimer scheduledTimerWithTimeInterval: 1 / _player.fps
                                     target:self
                                   selector:@selector(displayNextFrame:)
                                   userInfo:nil
                                    repeats:YES];
}
-(void)displayNextFrame:(NSTimer *)timer {
//    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    //    self.TimerLabel.text = [NSString stringWithFormat:@"%f s",video.currentTime];
    
    if (![_player stepFrame]) {
        return;
    }
    imageView.image=_player.currentImage;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
