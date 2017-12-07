# FFmpeg解码本地视频

*觉得有用star 一下，么么哒*

## 总结:
**读取编码并依据编码初始化内容结**
1.在开始编解码视频的时候首先第一步需要注册一个编解码器 ：av_register_all()；
2.avformat_open_input 来打开这个文件并给AVformartcontext 赋值 ，在其中会去查找当前缓存文件的格式
3.avformat_find_stream_info 使用该方法给每个视频/音频流的AVStream 结构体进行赋值并得到，这个参数在里面实现了一定的解码过程
4.在AVstream 有值了以后我们需要拿到当前当前的avcodecContext 和其对应的AVcodeC(使用avcodec_find_decoder)
5.avcodec_open2,初始化一个视音频编解码器的AVCodecContext,，调用AVCodeC的初始化到具体的解码器 AVCodeC init() 所以是在
avcodec_open2在开始真正的初始化avcodecContext
6.在得到了初始化的AVcodecContext之后我们就可以开始为解码之后的AVframe 分配空间(使用(unsigned char *)av_mallocz(av_image_get_buffer_size(AV_PIX_FMT_YUV420P, pCodecContex->width, pCodecContex->height, 1)))
av_image_fill_arrays():为AVframe 的像素点分配空间
sws_getContext:使用源图像的高和宽得到目标图像的高和宽，flag 为设定图像拉伸的算法

**每一帧的视频解码处理**
7.av_read_frame 在解码之前来获取一帧的视频帧压缩数据 或者是多帧的音频帧压缩数据 及我们得到的只是AVpacket
8.avcodec_decode_video2使用该函数来解码得到的AVpacket，输出一个下一帧的AVframe 函数
9.使用sws_scale 来对下一帧的AVframe 进行拉伸变化 ，输出想要得到的AVframe
10.释放上述的AVformartcontext ，AVstream，avcodecContext.






