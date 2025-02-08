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
#import "TempPerson.h"

@implementation TempPerson

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    NSLog(@"---willChangeValueForKey----%@",key);
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"---didChangeValueForKey------begin---%@",key);
    [super didChangeValueForKey:key];
    NSLog(@"---didChangeValueForKey------end---%@",key);
}

+(BOOL)accessInstanceVariablesDirectly{
    return YES;  // 默认值为YES
}
@end

伪代码：
willchange
p1->_age = xxx
didchange
~~~
<img width="471" alt="image" src="https://github.com/user-attachments/assets/05171503-65f5-414e-91f5-41e30eb4f6f0" />



下面用图来表示流程

<img width="1080" alt="image" src="https://github.com/user-attachments/assets/9e83a9c7-021c-43bd-81b0-2254a1affa39" />



在这拿文字叙述一遍
调用setValue：forKey：   先按照setKey、_setKey：顺序查找方法，如果找到了方法直接调用，如果没找到方法，查看accessInstanceVariablesDirectly方法的返回值（表示是否可以直接方法变量），如果返回NO，抛出异常，如果返回YES， 按照 _key、_isKey、key、isKey顺序查找成员变量，找到了直接赋值，找不到成员变量抛出异常


调用valueForKey：     按照getKey、key、isKey、_key顺序查找方法，找到了调用方法，找不到查看accessInstanceVariablesDirectly方法的返回值（表示是否可以直接方法变量），如果返回NO，抛出异常，如果返回YES，按照_key、_isKey、key、isKey的顺序查找成员变量，如果找到了直接赋值，找不到成员变量抛出
