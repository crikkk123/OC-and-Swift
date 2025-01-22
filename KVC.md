KVC


~~~objective-c
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TempPerson : NSObject
{
@public
    int age;
    int isKey;
    int _isAge;
    int _age;
}
@end

-----
#import "TempPerson.h"

@implementation TempPerson

@end


---------------------------------------
#import "ViewController.h"
#import "TempPerson.h"
#import <objc/runtime.h>

@interface ViewController ()
@property(strong) TempPerson* p1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.p1 = [[TempPerson alloc] init];
    
    
    NSKeyValueObservingOptions oper = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p1 addObserver:self forKeyPath:@"age" options:oper context:nil];
    
    
    [self.p1 setValue:@12 forKey:@"age"];
    NSLog(@"");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@ 的 %@ %@ -> %@",object,keyPath,change[@"old"],change[@"new"]);
    NSLog(@"11");
    
}


@end
~~~

<img width="887" alt="image" src="https://github.com/user-attachments/assets/efea2fe1-238a-40bb-85d3-35914396623a" />
可以看到KVC是会触发KVO的，在KVC的setvalue中调用willchange，didchange了，下面验证一下：
~~~objective-c

~~~



<img width="1080" alt="image" src="https://github.com/user-attachments/assets/9e83a9c7-021c-43bd-81b0-2254a1affa39" />

