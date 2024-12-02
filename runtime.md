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
