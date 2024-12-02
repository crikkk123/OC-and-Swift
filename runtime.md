# Runtime

## runtime库函数
头文件：类相关函数#import<objc/runtime.h>

消息相关函数：#import<objc/message.h>

## 使用objc_msgSend函数
强制转换：((void(*)(id,SEL,int))(void*)objc_msgSend)   把oc的方法转换成objc_msgSend函数执行

## class_getInstanceSize ()方法可以计算一个类的实例对象所实际需要的的空间大小
~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject* obj = [[NSObject alloc] init];
        
        NSLog(@"%d",class_getInstanceSize([obj class]));
    }
    return 0;
}
~~~

### 输出
<img width="315" alt="image" src="https://github.com/user-attachments/assets/4d7cba5c-9491-47fc-a2e4-2ba6485f9d40">



## malloc_size()
该函数的参数是一个指针，可以计算所传入指针 `所指向内存空间的大小`

## objc_msgSend
~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>


@interface Person : NSObject

- (void)run;

@end

@implementation Person

- (void)run {
    NSLog(@"跑");
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* p = [[Person alloc] init];
        ((void (*)(id, SEL, id))objc_msgSend)(p, @selector(run), nil);
    }
    return 0;
}

~~~

~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>


@interface Person : NSObject

- (void)run;

@end

@implementation Person

- (void)run {
    NSLog(@"跑");
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 分配 Person 对象
        Person *p = ((Person* (*)(id,SEL)) objc_msgSend)([Person class], @selector(alloc));
        p = ((Person* (*)(id,SEL)) objc_msgSend)(p, @selector(init));
        ((void (*)(id, SEL, id))objc_msgSend)(p, @selector(run), nil);
    }
    return 0;
}

~~~

~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>


@interface Person : NSObject

- (void)run;

@end

@implementation Person

- (void)run {
    NSLog(@"跑");
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 分配 Person 对象
        Person *p = ((Person* (*)(id,SEL)) objc_msgSend)(objc_getClass("Person"), sel_registerName("alloc"));
        p = ((Person* (*)(id,SEL)) objc_msgSend)(p, sel_registerName("init"));
        ((void (*)(id, SEL, id))objc_msgSend)(p, @selector(run), nil);
    }
    return 0;
}

~~~

## OC的消息转发
### 如果有一个没有实现的函数，程序崩掉
~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>


@interface Person : NSObject

- (void)run;

@end

@implementation Person

- (void)run {
    NSLog(@"跑");
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 分配 Person 对象
        Person *p = ((Person* (*)(id,SEL)) objc_msgSend)(objc_getClass("Person"), sel_registerName("alloc"));
        p = ((Person* (*)(id,SEL)) objc_msgSend)(p, sel_registerName("init"));
        ((void (*)(id, SEL, id))objc_msgSend)(p, @selector(fly), nil);
    }
    return 0;
}

~~~
图片：
<img width="1400" alt="image" src="https://github.com/user-attachments/assets/e32ab399-4c59-47e6-9ec6-8e944f72484a">

### 解决方法一：动态方法解析（dynamic method resolution）
首先会调用+ resolveInstanceMethod:（对应实例方法）或+ resolveClassMethod:（对应类方法）方法，让你添加方法的实现。如果你添加方法并返回YES，那系统在运行时就会重新启动一次消息发送的过程。

~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>


@interface Person : NSObject

- (void)run;

@end

@implementation Person

- (void)run {
    NSLog(@"跑");
}

//如果增加了方法并返回YES，就会重新发送消息并处理，返回NO，则进入下一步
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == sel_registerName("wahaha")) {
        class_addMethod(self, sel_registerName("wahaha"), imp_implementationWithBlock(^(){
            NSLog(@"wahaha");
        }), "v@:");
    }
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 分配 Person 对象
        Person *p = ((Person* (*)(id,SEL)) objc_msgSend)(objc_getClass("Person"), sel_registerName("alloc"));
        p = ((Person* (*)(id,SEL)) objc_msgSend)(p, sel_registerName("init"));
        ((void (*)(id, SEL, id))objc_msgSend)(p, sel_registerName("wahaha"), nil);
    }
    return 0;
}

~~~
如果上面返回NO，则会进入完整的消息转发机制,这里又分为两个步骤：
## 快速消息转发
~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface Dog : NSObject

@end

@implementation Dog

- (void)wahaha{
    NSLog(@"wa");
}

@end

@interface Person : NSObject

- (void)run;

@end

@implementation Person

- (void)run {
    NSLog(@"跑");
}

//如果增加了方法并返回YES，就会重新发送消息并处理，返回NO，则进入下一步
//+ (BOOL)resolveInstanceMethod:(SEL)sel{
//    if (sel == sel_registerName("wahaha")) {
//        class_addMethod(self, sel_registerName("wahaha"), imp_implementationWithBlock(^(){
//            NSLog(@"wahaha");
//        }), "v@:");
//    }
//    return YES;
//}

//返回一个对象继续处理消息
- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == sel_registerName("wahaha")) {
        return [Dog new];
    }
    return nil;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 分配 Person 对象
        Person *p = ((Person* (*)(id,SEL)) objc_msgSend)(objc_getClass("Person"), sel_registerName("alloc"));
        p = ((Person* (*)(id,SEL)) objc_msgSend)(p, sel_registerName("init"));
        ((void (*)(id, SEL, id))objc_msgSend)(p, sel_registerName("wahaha"), nil);
    }
    return 0;
}

~~~
