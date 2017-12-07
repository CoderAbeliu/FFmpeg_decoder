//
//  RTSPPlayer.h
//  FFMpeg_learn1
//
//  Created by Abe_liu on 2017/11/14.
//  Copyright © 2017年 Abe_liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface RTSPPlayer : NSObject

@property(nonatomic,assign)int outputWidth;
@property(nonatomic,assign)int outputHeight;
@property(nonatomic,readonly,assign) CGFloat fps;
@property(nonatomic,readonly,assign) double  duration;
@property(nonatomic,strong)UIImage *currentImage;

-(instancetype)initWithVideoUrl:(NSString *)url;
-(BOOL)displayNextFrame;






@end
