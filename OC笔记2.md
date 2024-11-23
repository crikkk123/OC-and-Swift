# 动画以及多谋体

## 使用图形上下文按一定比例缩放图片
~~~objective-c
//
//  ViewController.m
//  imageTest
//
//  Created by cr on 2024/11/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 如何通过图形上下文，来实现缩放图片的功能
    
    UIImage* image = [UIImage imageNamed:@"1"];
    UIImage* scaledImage = [self scaleImage:image newSize:CGSizeMake(180, 180)];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:scaledImage];
    imageView.center = CGPointMake(160, 160);
    [self.view addSubview:imageView];
}

// 创建一个方法，传递一个图像参数，和一个缩放比例参数，实现将图像，缩放至指定比例的功能
- (UIImage*)scaleImage:(UIImage* )image newSize:(CGSize)newSize{
    
    CGSize imageSize = image.size;
    int width = imageSize.width;
    int height = imageSize.height;
    
    // 计算图像新尺寸与旧尺寸的宽高比例
    float widthFactor = newSize.width/width;
    float heightFactor = newSize.height/height;
    float scaleFactor = (widthFactor < heightFactor) ? widthFactor : heightFactor;
    
    // 计算图像新的宽度和高度
    float scaleWidth = width * scaleFactor;
    float scaleHeight = height * scaleFactor;
    
    // 将新的宽度和高度，构建成标准的尺寸对象
    CGSize targetSize = CGSizeMake(scaleWidth, scaleHeight);
    
    // 创建绘图上下文环境
    UIGraphicsBeginImageContext(targetSize);
    
    // 将图像对象，画入之前计算的新尺寸里，原点为0，0
    [image drawInRect:CGRectMake(0, 0, scaleWidth, scaleHeight)];
    
    // 获取上下文里的内容，将内容写入到新的图像对象
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

@end

~~~
### 效果
![image-20241121230648110](https://github.com/user-attachments/assets/1b747709-ff85-4034-8bda-fa015ae617aa)


## 使用图形上下文转换图片为灰度图
~~~objective-c
//
//  ViewController.m
//  imageTest
//
//  Created by cr on 2024/11/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage* image = [UIImage imageNamed:@"1"];
    UIImage* scaledImage = [self grayImage:image];
        
    UIImageView* imageView = [[UIImageView alloc] initWithImage:scaledImage];
    imageView.center = CGPointMake(160, 160);
    [self.view addSubview:imageView];
    
}


-(UIImage*)grayImage:(UIImage*)image{
    CGSize imageSize = image.size;
    int width = imageSize.width;
    int height = imageSize.height;
    
    // 创建灰度色彩空间对象，各种设备对待颜色的方式都不同，颜色必须有一个相关的色彩空间，否则图形上下文将不知道如何解释相关的颜色值
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceGray();
    
    // 参数1，指向要渲染的绘制内存的地址，参数2，3分别表示宽度和高度，参数4，表示内存中像素的每个组件的位数
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, spaceRef, kCGBitmapByteOrderDefault);
    
    // 参数5，表示每一行，在内存所占的比特数，参数6，表示上下文使用的颜色空间，参数7表示是否包含alpha通道，然后创建一个和原图像同样尺寸的空间
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    // 在灰度上下文中画入图片
    CGContextDrawImage(context, rect, image.CGImage);
    
    // 从上下文中，获取并生成转为灰度的图片
    UIImage* grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    
    return grayImage;
}

@end

~~~
### 效果
![image](https://github.com/user-attachments/assets/f1a8bf98-957a-4a7e-9807-d9c2d26fcc59)

## CoreImage框架设置图片的单色效果
~~~objective-c
//
//  ViewController.m
//  imageTest
//
//  Created by cr on 2024/11/21.
//

#import "ViewController.h"

// 导入使用的框架，提供了强大和高效的图像处理功能，用来基于像素的图像进行分析，操作和特效处理
#import <CoreImage/CoreImage.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用图像处理框架，将图片转换成单色调样式
    UIImage* image = [UIImage imageNamed:@"1"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
    // 初始化一个CoreImage图像对象，并加载之前导入的图片
    CIImage* ciImage = [[CIImage alloc] initWithImage:image];
    // 初始化一个颜色对象，并设置其颜色为棕色，其参数值介于0和1之间
    CIColor* color = [[CIColor alloc] initWithRed:0.8 green:0.6 blue:0.4];
    // 初始化一个滤镜对象，并设置滤镜类型为单色调滤镜
    CIFilter* filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    // 设置单色调滤镜的输入颜色值
    [filter setValue:color forKey:kCIInputColorKey];
    // 设置单色调滤镜的颜色浓度值
    [filter setValue:@1.0 forKey:kCIInputIntensityKey];
    // 设置需要应用单色调滤镜的图像
    [filter setValue:ciImage forKey:kCIInputImageKey];
    // 获得应用单色调滤镜后的图像
    CIImage* outImage = filter.outputImage;
    // 更改图像视图的内容，为应用滤镜后的图像
    imageView.image = [UIImage imageWithCIImage:outImage];
}


@end

~~~
### 效果
![image](https://github.com/user-attachments/assets/b1fcbdd4-d2b5-4b64-b009-470a4fd8915c)

## CoreImage框架更改图片的色相
~~~objective-c
//
//  ViewController.m
//  imageTest
//
//  Created by cr on 2024/11/21.
//

#import "ViewController.h"

// 导入使用的框架，提供了强大和高效的图像处理功能，用来基于像素的图像进行分析，操作和特效处理
#import <CoreImage/CoreImage.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用图像处理框架，将图片转换成单色调样式
    UIImage* image = [UIImage imageNamed:@"1"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
    // 初始化一个CoreImage图像对象，并加载之前导入的图片
    CIImage* ciImage = [[CIImage alloc] initWithImage:image];
    // 初始化一个滤镜对象，并设置滤镜类型为色相调整滤镜
    CIFilter* filter = [CIFilter filterWithName:@"CIHueAdjust"];
    // 设置色相调整滤镜的输入角度值为30度
    [filter setValue:[NSNumber numberWithDouble:3.14/6] forKey:kCIInputAngleKey];
    // 设置需要应用色相调整滤镜的图像
    [filter setValue:ciImage forKey:kCIInputImageKey];
    // 获得应用色相调整滤镜后的图像
    CIImage* outImage = filter.outputImage;
    
    imageView.image = [UIImage imageWithCIImage:outImage];
}


@end

~~~
### 效果
![image](https://github.com/user-attachments/assets/1f55a28e-2454-4694-bab9-db1af39fc830)

## CoreImage框架给图片添加马赛克效果
~~~objective-c
//
//  ViewController.m
//  imageTest
//
//  Created by cr on 2024/11/21.
//

#import "ViewController.h"

// 导入使用的框架，提供了强大和高效的图像处理功能，用来基于像素的图像进行分析，操作和特效处理
#import <CoreImage/CoreImage.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用图像处理框架，将图片转换成单色调样式
    UIImage* image = [UIImage imageNamed:@"1"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
    // 初始化一个CoreImage图像对象，并加载之前导入的图片
    CIImage* ciImage = [[CIImage alloc] initWithImage:image];
    // 初始化一个滤镜对象，并设置滤镜类型为像素化滤镜
    CIFilter* filter = [CIFilter filterWithName:@"CIPixellate"];
    // 设置像素化滤镜，采用默认的配置选项
    [filter setDefaults];
    // 设置需要应用色相调整滤镜的图像
    [filter setValue:ciImage forKey:kCIInputImageKey];
    // 获得应用色相调整滤镜后的图像
    CIImage* outImage = filter.outputImage;
    
    imageView.image = [UIImage imageWithCIImage:outImage];
}


@end

~~~
### 效果
![image](https://github.com/user-attachments/assets/aab929d8-a1ed-41c9-a6fe-b76c684f8856)


# 数据解析和网络编程

## 程序沙箱结构中常用的几个目录
~~~Objective-c
//
//  ViewController.m
//  imageTest
//
//  Created by cr on 2024/11/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取程序沙箱结构中，常见的几个目录
    
    // 获得应用程序的路径，包含三个文件夹：文档目录，库目录，临时目录以及一个程序包，该目录就是应用程序的沙盒，程序只能访问该目录下的内容
    NSString* homePath = NSHomeDirectory();
    NSLog(@"homePath:\(homePath)");
    
    // 系统会为每个程序，生成一个私有目录，并随即生成一个数字字母串作为目录名，在每次程序启动时，这个目录的名称都是不同的，而使用此方法可以获得对应的目录集合
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // 获得并输出目录集合中的第一个元素，即沙箱中的文档目录，将应用程序的所有数据文件，写入这个目录下，这个目录通常用于存储用户数据
    NSLog(@"documentPath1:%@",documentPaths[0]);
    // 创建一个字符串对象，该字符串对象同样表示沙箱中的文档目录
    NSString* documentPath2 = [homePath stringByAppendingString:@"/Documents"];
    // 打印目录，与上条日志比较是否相同
    NSLog(@"documentPath2:%@",documentPath2);
    
    // 获得沙箱下的库目录，包含两个子目录：缓存目录和参数目录
    NSArray* libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSLog(@"libraryPath1:%@",libraryPaths[0]);
    // 创建一个字符串对象，表示沙箱中的库目录
    NSString* libraryPath2 = [homePath stringByAppendingString:@"/Library"];
    // 打印目录，与上条日志比较是否相同
    NSLog(@"libraryPath2:%@",libraryPath2);
    
    // 获得沙箱下的缓存目录
    NSArray* cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    // 存放应用程序专用的支持文件，保持应用程序再次启动过程中，需要的信息
    NSLog(@"cachePath1:%@",cachePaths[0]);
    // 沙箱中的缓存目录
    NSString* cachePath2 = [homePath stringByAppendingString:@"/Library/Caches"];
    // 打印目录，与上条日志比较是否相同
    NSLog(@"cachePath2:%@",cachePath2);
    
    // 创建一个常量，用来存储当前用户的临时路径
    NSString* tmpPath1 = NSTemporaryDirectory();
    NSLog(@"%@",tmpPath1);
    // 表示沙箱中的临时目录
    NSString* tmpPath2 = [homePath stringByAppendingString:@"/tmp"];
    NSLog(@"%@",tmpPath2);
}


@end

~~~
### 效果
![image](https://github.com/user-attachments/assets/3de86732-c393-4d5b-aa89-ff8dbca4eb54)

## 创建文件夹
~~~objective-c
//
//  ViewController.m
//  imageTest
//
//  Created by cr on 2024/11/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 文件管理对象的主要功能包括：读取文件中的数据，向一个文件中写入数据、删除或复制文件、移动文件、比较两个文件的内容或测试文件的存在性等
    NSFileManager* manager = [NSFileManager defaultManager];
    
    // 创建一个字符串对象，该字符串对象表示文档目录下的一个文件夹
    NSString* baseUrl = [NSHomeDirectory() stringByAppendingString:@"/Documents/txtFolder1"];
    // 使用文件管理对象，判断文件夹是否存在，并把结果存储在常量中
    BOOL exist = [manager fileExistsAtPath:baseUrl];
    if(!exist){
        // 首先创建一个异常捕捉语句，用于创建一个新的文件夹
        NSError* error;
        // 使用try语句，创建指定位置上的文件夹
        [manager createDirectoryAtPath:baseUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if(error == nil){
            NSLog(@"Success to create folder");
        }
        else{
            NSLog(@"Error to create folder:%@",[error description]);
        }
    }
}


@end

~~~
### 效果
