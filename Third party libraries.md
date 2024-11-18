# Third party libraries

## SDWebImage

～～～objective-c
//
//  ViewController.m
//  testWeb
//
//  Created by Caorui(曹锐)[运营中心] on 2024/11/18.
//

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
～～～

### 效果

