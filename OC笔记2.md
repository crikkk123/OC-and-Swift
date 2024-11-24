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
![image](https://github.com/user-attachments/assets/c70b72fc-6461-4d13-8212-0b49934a31cc)

## 对文件夹进行遍历操作
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
    NSString* url = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
    
    NSError* error;
    NSArray* contents = [manager contentsOfDirectoryAtPath:url error:&error];
    NSLog(@"contents:%@",contents);
    
    if(error != nil){
        NSLog(@"Error occurs");
    }
    
    NSDirectoryEnumerator* contents2 = [manager enumeratorAtPath:url];
    NSLog(@"contents2:%@",contents2.allObjects);
}


@end
~~~

### 效果
![image](https://github.com/user-attachments/assets/3104ca14-ca66-44ca-a920-908f93865a1c)

## 复制、移动、删除文件
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
    
    [self copyFile];
    [self moveFile];
    [self removeFile];
    [self removeFolder];
    [self listFolder];
}

// 用来复制一个文件
- (void)copyFile{
    // 文件管理对象的主要功能包括：读取文件中的数据，向一个文件中写入数据、删除或复制文件、移动文件、比较两个文件的内容或测试文件的存在性等
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // 创建一个字符串对象，该字符串对象表示文档目录下的一个文件夹
    NSString* sourceUrl = [NSHomeDirectory() stringByAppendingString:@"/Documents/swift.txt"];
    NSString* targetUrl = [NSHomeDirectory() stringByAppendingString:@"/Documents/swift_bak.txt"];
    
    // 将文本文件复制到目标位置
    NSError* error;
    [fileManager copyItemAtURL:sourceUrl toURL:targetUrl error:&error];
    if(error == nil){
        NSLog(@"Success to copy file");
    } else{
        NSLog(@"Failed to copy file");
    }
}

// 移动一个文件
-(void)moveFile{
    // 文件管理对象的主要功能包括：读取文件中的数据，向一个文件中写入数据、删除或复制文件、移动文件、比较两个文件的内容或测试文件的存在性等
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // 创建一个字符串对象，该字符串对象表示文档目录下的一个文件夹
    NSString* sourceUrl = [NSHomeDirectory() stringByAppendingString:@"/Documents/products.plist"];
    NSString* targetUrl = [NSHomeDirectory() stringByAppendingString:@"/Documents/backUp"];
    
    NSError* error;
    [fileManager moveItemAtURL: sourceUrl toURL:targetUrl error:&error];
    if(error == nil){
        NSLog(@"Success to move file");
    } else{
        NSLog(@"Failed to move file");
    }
}

// 删除一个文件
-(void) removeFile{
    // 文件管理对象的主要功能包括：读取文件中的数据，向一个文件中写入数据、删除或复制文件、移动文件、比较两个文件的内容或测试文件的存在性等
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // 创建一个字符串对象，该字符串对象表示文档目录下的一个文件夹
    NSString* sourceUrl = [NSHomeDirectory() stringByAppendingString:@"/Documents/products.plist"];
    
    NSError* error;
    [fileManager removeItemAtURL:sourceUrl error:&error];
    if(error == nil){
        NSLog(@"Success to remove file");
    } else{
        NSLog(@"Failed to remove file");
    }
}

// 删除文件夹下的内容
-(void)removeFolder{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* folder = [NSHomeDirectory() stringByAppendingString:@"/Documents/backup/"];
    
    // 获得目录下的所有子文件夹
    NSArray* items = [fileManager subpathsAtPath:folder];
    for(NSString* item in items){
        NSError* error;
        [fileManager removeItemAtURL:item error:&error];
        if(error == nil){
            NSLog(@"Success to remove item");
        } else{
            NSLog(@"failed to remove item");
        }
    }
}


// 检查和遍历在复制、移动和删除等操作之后的文件夹
- (void)listFolder{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* url = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
    
    NSDirectoryEnumerator* items = [fileManager enumeratorAtPath:url];
    NSLog(@"items:%@",[items allObjects]);
}

@end

~~~
### 效果
后面补上

## 退出系统前的事件处理
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
    
    // 获得一个应用实例，提供程序运行期间的控制和协作，每一个程序必须有，且只有一个应用实例
    UIApplication* app = [UIApplication sharedApplication];
    
    // 通知中心是基础框架的子系统，下面是向所有监听程序退出事件的对象，广播消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doSomething:) name:UIApplicationWillResignActiveNotification object:app];
}

// 创建一个方法，用来响应程序退出事件，使程序在退出前，保存用户数据
-(void)doSomething:(NSNotificationCenter*) notification{
    NSLog(@"Saving data before exit.");
}

@end

~~~
### 效果
![image](https://github.com/user-attachments/assets/e7aeb44a-696b-4d16-863c-245ab9373e33)

## 读取和解析Plist属性列表文件
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
    
    // 用来存储、串行化后的对象文件
    
    // 获取属性列表文件，在项目中的路径
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"DemoPlist" ofType:@"plist"];
    // 加载属性列表文件，并存入一个可变字典对象中
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    // 将字典对象转换为字符串对象
    NSString* message = data.description;
    NSString* name = data[@"name"];
    NSString* age = data[@"age"];
    
    NSLog(@"message:%@",message);
    NSLog(@"name:%@",name);
    NSLog(@"age:%@",age);
}


@end

~~~

### 效果
![image](https://github.com/user-attachments/assets/421b20ea-b2a4-40d7-b998-5cf9c5486f47)
![image](https://github.com/user-attachments/assets/3488cd60-59e9-4ee4-b524-02e25d7806cc)

## NSKeyedArchiver存储和解析数据
~~~objective-c
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 创建一个继承自NSObject的类，并遵守NSCoding协议，遵循该协议的类，可以被序列化和反序列化，这样可以归档到磁盘上或分发到网络上
@interface UserModel : NSObject<NSCoding,NSCopying>

@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) NSString* password;

@end

NS_ASSUME_NONNULL_END

~~~
~~~objective-c
//
//  UserModel.m
//  imageTest
//
//  Created by cr on 2024/11/24.
//

#import "UserModel.h"


@implementation UserModel

// 添加一个协议方法，用来对模型对象进行序列化操作，在这个方法里，对模型的姓名和密码属性，进行编码操作，并设置对应的键名
- (void) encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:_name forKey:@"_name"];
    [coder encodeObject:_password forKey:@"_password"];
}


// 添加另一个来自协议的方法，用来对模型对象进行反序列化操作
- (instancetype)initWithCoder:(NSCoder *)coder{
// 对模型对象的姓名和密码属性，根据对应的键名，进行解码操作，并返回初始化的对象
    if(self == [super init]){
        _name = [coder decodeObjectForKey:@"_name"];
        _password = [coder decodeObjectForKey:@"_password"];
    }
    return self;
}

// 实现NSCopying协议的方法，用来响应拷贝的消息
- (id)copyWithZone:(NSZone *)zone{
    UserModel* model = [[[self class] allocWithZone:zone] init];
    model.name = [self.name copyWithZone:zone];
    model.password = [self.password copyWithZone:zone];
    return model;
}

@end

~~~
~~~objective-c
//
//  ViewController.m
//  imageTest
//
//  Created by cr on 2024/11/21.
//

#import "ViewController.h"
#import "UserModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 如何使用归档的方法，对模型对象进行持久化工作
    
    UserModel* user1 = [[UserModel alloc] init];
    user1.name = @"Jerry";
    user1.password = @"123";
    
    // 创建一个可变二进制数据对象，用来存储归档后的模型对象
    NSMutableData* data = [[NSMutableData alloc] init];
    // 初始化一个键值归档对象
    NSKeyedArchiver* archive = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    // 对模型对象进行归档操作，归档指的是将对象存储为一个文件，或者网络上的一个数据块
    [archive encodeObject:user1 forKey:@"user1Key"];
    // 完成归档的编码，序列化工作
    [archive finishEncoding];
    
    NSString* path = [NSHomeDirectory() stringByAppendingString:@"/Documents/contacts.data"];
    // 将归档文件存储在程序包的指定位置
    [data writeToFile:path atomically:YES];
    
    // 对归档文件进行加载和恢复归档的操作
    NSMutableData* data2 = [NSMutableData dataWithContentsOfFile:path];
    // 对文件进行恢复归档的操作，恢复归档指的是将一个来自文件或网络的归档数据块，恢复成内存中的一个对象
    NSKeyedUnarchiver* unarchi = [[NSKeyedUnarchiver alloc] initForReadingWithData:data2];
    
    // 根据设置的键名，对数据进行恢复归档的操作，并获得最终结果
    UserModel* savedUser = [unarchi decodeObjectForKey:@"user1Key"];
    // 完成对象的解码操作
    [unarchi finishDecoding];
    
    NSLog(@"%@",savedUser.name);
    NSLog(@"%@",savedUser.password);
}


@end

~~~
### 效果
![image](https://github.com/user-attachments/assets/d5c29cfa-e6a8-4061-81cb-b4e3af69bfad)
![image](https://github.com/user-attachments/assets/185f24c2-cf7c-4738-8f7f-bef5315ac309)

## 解析XML文档
~~~objective-c

~~~
### 效果
