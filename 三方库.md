# Third party libraries

## SDWebImage

~~~text
介绍：SDWebImage是个支持异步下载与缓存的UIImageView扩展，主要的功能：
    1.提供了一个UIImageView的category用来加载网络图片并且对网络图片的缓存进行管理
    2.采用异步方式来下载网络图片
    3.采用异步方式，使用内存＋磁盘来缓存网络图片，拥有自动的缓存过期处理机制。
    4.支持GIF动画
    5.支持WebP格式
    6.同一个URL的网络图片不会被重复下载
    7.失效，虚假的URL不会被无限重试
    8.耗时操作都在子线程，确保不会阻塞主线程
    9.使用GCD和ARC
    10.支持Arm64
    11.支持后台图片解压缩处理
    12.项目支持的图片格式包括 PNG,JPEG,GIF,Webp等
~~~

~~~objective-c

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView* imageView = [[UIImageView alloc] init];
    NSString* str = @"https://img2.baidu.com/it/u=1337068678,3064275007&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=750";
    [imageView sd_setImageWithURL:[NSURL URLWithString:str]];
    
    imageView.frame = CGRectMake(0, 0, 200, 200);
    imageView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:imageView];
}


@end
~~~

### 效果
<img width="362" alt="image" src="https://github.com/user-attachments/assets/e658a73f-f260-4110-8285-28acf35a0101">

