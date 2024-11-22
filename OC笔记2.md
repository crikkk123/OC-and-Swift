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

## 使用CoreImage框架更改图片的色相
~~~objective-c

~~~
### 效果
