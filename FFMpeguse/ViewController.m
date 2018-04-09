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
#import "RTSPPlayer.h"

@interface ViewController ()
{
    CADisplayLink *displayLink;
    UIImageView *imageView;
}
@property(nonatomic,strong)RTSPPlayer *myPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
    imageView.image=[UIImage imageNamed:@"main_demo_1"];
    [self.view addSubview:imageView];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"sintel" ofType:@"mov"];
    _myPlayer=[[RTSPPlayer alloc]initWithVideoUrl:path];
    displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(showMyMovie) ];
    [displayLink setFrameInterval:4];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
-(void)showMyMovie{
    if (![_myPlayer displayNextFrame]) {
        NSLog(@"失败了");
        return;
    }
    imageView.image=_myPlayer.currentImage;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
