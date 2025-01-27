# KVO
key-value observe

~~~objective-c

#import "ViewController.h"

@interface ViewController ()
@property(strong) TempPerson* p1;
@property(strong) TempPerson* p2;
@end

@implementation TempPerson



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.p1 = [[TempPerson alloc] init];
    self.p1.age = 10;
    self.p2 = [[TempPerson alloc] init];
    self.p2.age = 100;
    
    NSKeyValueObservingOptions oper = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p1 addObserver:self forKeyPath:@"age" options:oper context:nil];
    
    self.p1.age = 20;
    self.p2.age = 200;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@ 的 %@ %@ -> %@",object,keyPath,change[@"old"],change[@"new"]);
    NSLog(@"11");
}

@end

~~~
图片：

<img width="673" alt="image" src="https://github.com/user-attachments/assets/79aa3b5c-4bc7-44b7-94dd-23d34522ed0f">

根据下面的图片可以看出，p1的isa指针和p2的isa指针指向的class类不同（！！！后面会补具体的p1->isa类型：自己写其struct类型进行强转）

<img width="313" alt="image" src="https://github.com/user-attachments/assets/ae1af168-9f0f-444c-8d00-bd8f8dede7d0">


## 1、本质
	KVO的本质实际上是把instance的isa指针原本指向类对象的指针指向了一个runtime动态生成的类，
 	名为NSKVONotifying_XXXX 的类，这个类会调用 Foundation 的 _NSSetXXXValueAndNotify函数，
  	新生成的这个类的isa指向原本 instance对象指向的类对象
   
~~~objective-c
_NSSetXXXValueAndNotify函数的伪代码
	[self willChangeValueForKey:@"age"];
	[super setAge:age];
	[self didChangeValueForKey:@"age"];  在这个里面进行通知监听器，属性发生了改变
		[observer observerValueForKeyPath:key ofObject:self change:nil context:nil];
~~~

----   dealloc、set、class、_isKVOA

~~~objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.p1 = [[TempPerson alloc] init];
    self.p1.age = 10;
    self.p2 = [[TempPerson alloc] init];
    self.p2.age = 100;
    
    NSLog(@"-%@  %@",object_getClass(self.p1),object_getClass(self.p2));
    
    NSKeyValueObservingOptions oper = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p1 addObserver:self forKeyPath:@"age" options:oper context:nil];
    
    NSLog(@"-%@  %@",object_getClass(self.p1),object_getClass(self.p2));
    
    self.p1.age = 20;
    self.p2.age = 200;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@ 的 %@ %@ -> %@",object,keyPath,change[@"old"],change[@"new"]);
    NSLog(@"11");
    
}
~~~
图片：

<img width="498" alt="image" src="https://github.com/user-attachments/assets/4b18939c-550d-43fa-b6db-077af0f66141" />
