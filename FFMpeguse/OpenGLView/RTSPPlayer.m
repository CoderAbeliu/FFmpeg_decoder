//
//  RTSPPlayer.m
//  FFMpeg_learn1
//
//  Created by Abe_liu on 2017/11/14.
//  Copyright © 2017年 Abe_liu. All rights reserved.
//

#import "RTSPPlayer.h"
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavutil/avutil.h>
#import <libswscale/swscale.h>
#import <libavutil/imgutils.h>




static RTSPPlayer *rtspPlayer;

@interface RTSPPlayer()
{
    AVFormatContext *pFormartContext;
    AVInputFormat *inputFormart;
    AVCodecContext *pCodecContext;
    AVCodecParameters  *pCodecPar;
    AVCodec *codeC;
    AVPacket pPackct;
    AVFrame *pFrame,*pYUVFrame;
    AVPicture pPicture;
    uint8_t *data;
    uint8_t *out_buffer;
    int videoStream;
    CADisplayLink *displayLink;
    BOOL    isReleaseResources;
    CGFloat  currentFps;
}
@end

@implementation RTSPPlayer

-(instancetype)initWithVideoUrl:(NSString *)url{
    if (!(self=[super init]) )return nil;
    isReleaseResources=false;
    //注册所有编解码库
    av_register_all();
    avformat_network_init();
    AVDictionary *opts = NULL;
    av_dict_set(&opts, "rtsp_transport", "udp", 0);
    av_dict_set(&opts, "max_delay", "0.3", 0);
    if (avformat_open_input(&pFormartContext, [url UTF8String], inputFormart, &opts)!=0) {
        NSLog(@"打开文件路径失败");
        return nil;
    }
    if (avformat_find_stream_info(pFormartContext, &opts)<0) {
        NSLog(@"解码失败,其中不含有解码信息");
        return nil;
    }
    
    videoStream=-1;
    for (int i=0; i<pFormartContext->nb_streams; i++) {
        if (pFormartContext->streams[i]->codecpar->codec_type==AVMEDIA_TYPE_VIDEO) {
            videoStream=i;
        }
    }
    if (videoStream==-1) {
        NSLog(@"没有视频流");
        return nil;
    }
//    //拿到视频流的上下文  以前的方法
//    pCodecContext=pFormartContext->streams[videoStream]->codec;
//    //7.通过avcodec_find——decoder 去找寻当前id 下的AVcodeC 解码器
//    codeC=avcodec_find_decoder(pCodecContext->codec_id) ;
//    if (codeC==NULL) {
//        NSLog(@"找不到AVCodeC");
//        return nil;
//    }
    pCodecPar=pFormartContext->streams[videoStream]->codecpar;
    AVStream *stream=pFormartContext->streams[videoStream];
    
    if (stream->avg_frame_rate.den&&stream->avg_frame_rate.num) {
        currentFps=av_q2d(stream->avg_frame_rate) ;
    }else currentFps=30;
    
    codeC=avcodec_find_decoder(pCodecPar->codec_id);
    pCodecContext=avcodec_alloc_context3(codeC);
    
    if (codeC==NULL) {
        NSLog(@"没有合适的解码器");
        return nil;
    }
    //对pCodecContext上下文进行数据的填充
    if(avcodec_parameters_to_context(pCodecContext, pCodecPar)<0)return nil;
    //开始正式的解码操作
    if (avcodec_open2(pCodecContext, codeC, &opts)<0) {
        NSLog(@"打开codeCcontext 失败");
        return nil;

    }
    pFrame=av_frame_alloc();
    pYUVFrame=av_frame_alloc();
    if (!pFrame) {
        avcodec_close(pCodecContext);
        return nil;
    }
    _outputWidth=pCodecContext->width;
    _outputHeight=pCodecContext->height;
#ifdef DEBUG
    NSLog(@"%d----%d",_outputWidth,_outputHeight);
#endif
    return self;
}

-(BOOL)displayNextFrame{
    int frameFinshed=0;
    if (pFormartContext==NULL) {
        NSLog(@"源数据为空");
        return false;
    }
    while (!frameFinshed&&av_read_frame(pFormartContext, &pPackct)>=0) {
        if (pPackct.stream_index==videoStream) {
            //现在换成了av_send
//            avcodec_send_packet(<#AVCodecContext *avctx#>, <#const AVPacket *avpkt#>)
//            avcodec_receive_frame(<#AVCodecContext *avctx#>, <#AVFrame *frame#>)
            avcodec_decode_video2(pCodecContext, pFrame, &frameFinshed, &pPackct);
        }
    }
    if (frameFinshed == 0 && isReleaseResources == NO) {
        [self releaseResources];
    }
    return  frameFinshed!=0;
}

-(void)releaseResources{
    NSLog(@"释放资源");
    isReleaseResources=true;
    avformat_close_input(&pFormartContext);
    av_frame_free(&pFrame);
    av_frame_free(&pYUVFrame);
    avcodec_close(pCodecContext);
    avformat_network_deinit();
}

-(void)setOutputWidth:(int)outputWidth{
    _outputWidth=outputWidth;

}
-(void)setOutputHeight:(int)outputHeight{
    if (_outputHeight == outputHeight) return;
    _outputHeight = outputHeight;
    NSLog(@"当前的高是%d",_outputHeight);
}
-(CGFloat)fps{
    return currentFps;
}

-(UIImage *)currentImage{
    if (!pFrame->data[0]) return nil;
    return [self imageFromAVPicture];
}

-(UIImage *)imageFromAVPicture{
    
    struct SwsContext *img_convert_ctx;
    
    img_convert_ctx=sws_getContext(pCodecContext->width, pCodecContext->height,pCodecContext->pix_fmt, _outputWidth, _outputHeight, AV_PIX_FMT_RGB24, SWS_FAST_BILINEAR, NULL, NULL, NULL);
    if (img_convert_ctx==nil) {
        NSLog(@"%d----%d",_outputWidth,_outputHeight);
        NSLog(@"构建图像失败");
        return nil;
    }
    
    out_buffer=(unsigned char *)av_malloc(av_image_get_buffer_size(AV_PIX_FMT_RGB24, pCodecContext->width, pCodecContext->height, 1));
    av_image_fill_arrays(pYUVFrame->data, pYUVFrame->linesize, out_buffer, AV_PIX_FMT_RGB24, pCodecContext->width, pCodecContext->height,1);
    sws_scale(img_convert_ctx, (const uint8_t**)pFrame->data, pFrame->linesize, 0, pCodecContext->height, pYUVFrame->data, pYUVFrame->linesize);
    sws_freeContext(img_convert_ctx);
    av_free(out_buffer);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault,
                                  pYUVFrame->data[0],
                                  pYUVFrame->linesize[0] * _outputHeight);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSLog(@"myWidth%d----%d",_outputWidth,_outputHeight);
    CGImageRef cgImage = CGImageCreate(_outputWidth,
                                       _outputHeight,
                                       8,
                                       24,
                                       pYUVFrame->linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}





@end
