# OC进阶

## runtime库函数
头文件：类相关函数#import<objc/runtime.h>

消息相关函数：#import<objc/message.h>


## 使用objc_msgSend函数
强制转换：((void(*)(id,SEL,int))(void*)objc_msgSend)   把oc的方法转换成objc_msgSend函数执行


## 三种OC对象
instance  实例对象  ：  isa指针、其他成员变量

class     类对象    ：  isa指针、superclass指针、类的属性信息、类的方法信息、类的协议信息、类的成员变量信息

meta-class  元对象  ：  isa指针、superclass指针、类的方法信息


## OC代码转换为CPP代码的命令
~~~text
xrun -sdk iphoneos clang -arch arm64 -rewrite-objc OC源文件 -o 输出的CPP文件  链接其他的（-framework UIKit）
~~~


## Class objc_getClass(const char *aClassName) 与 Class object_getClass(id obj)
Class objc_getClass(const char *aClassName)：

    入参是一个字符串，也就是类名
    
    返回值是对应的class对象
    
    因为我们通过字符串，只能定义类的名字，所以这个方法只能返回class对象

Class object_getClass(id obj)

    入参obj可以是instance对象、class对象或者meta-class对象
    
    返回值：
        传入instance对象，返回对应的class对象
        
        传入class对象，返回对应的meta-class对象
        
        传入meta-class对象，返回NSObject(基类)的meta-class对象


## instance、class、meta-class（isa、superclass）总结
![image](https://github.com/user-attachments/assets/59e1fe72-2929-41ae-a581-74e5107bc165)


## 验证
~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface CLPerson : NSObject <NSCopying>

@end

@implementation CLPerson

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CLPerson *person = [[CLPerson alloc] init];
        Class personClass = [CLPerson class];
        Class personMetaClass = object_getClass(personClass);
        NSLog(@"%p %p %p", person, personClass, personMetaClass);
    }
    return 0;
}

~~~

<img width="415" alt="image" src="https://github.com/user-attachments/assets/3c779ee9-d5f1-4a43-8f3e-eda45a541f3d">


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

输出
<img width="315" alt="image" src="https://github.com/user-attachments/assets/4d7cba5c-9491-47fc-a2e4-2ba6485f9d40">



malloc_size()
该函数的参数是一个指针，可以计算所传入指针 `所指向内存空间的大小`

~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *obj = [[NSObject alloc] init];
        size_t size = class_getInstanceSize([NSObject class]);
        NSLog(@"NSObject实例对象的大小：%zd",size);
        size_t size2 = malloc_size((__bridge const void *)(obj));
        NSLog(@"对象obj所指向的的内存空间大小：%zd",size2);
    }
    return 0;
}

~~~

图片：
<img width="337" alt="image" src="https://github.com/user-attachments/assets/3229e963-a19e-45ae-b092-6b5bba11991c">

class_getInstanceSize 的实现：
~~~objective-c
size_t class_getInstanceSize(Class cls)
{
    if (!cls) return 0;
    return cls->alignedInstanceSize();
}
~~~

alignedInstanceSize 的实现
~~~objective-c
    // Class's ivar size rounded up to a pointer-size boundary.
    uint32_t alignedInstanceSize() const {
        return word_align(unalignedInstanceSize());
    }
其内部只有一个isa指针在64bit下占8字节
~~~

alloc：
~~~objective-c
id
_objc_rootAllocWithZone(Class cls, objc_zone_t)
{
    // allocWithZone under __OBJC2__ ignores the zone parameter
    return _class_createInstance(cls, 0, OBJECT_CONSTRUCT_CALL_BADALLOC);
}
~~~

_class_createInstance 实现：
~~~objective-c
static ALWAYS_INLINE id
_class_createInstance(Class cls, size_t extraBytes,
                      int construct_flags = OBJECT_CONSTRUCT_NONE,
                      bool cxxConstruct = true,
                      size_t *outAllocatedSize = nil)
{
    ASSERT(cls->isRealized());

    // Read class's info bits all at once for performance
    bool hasCxxCtor = cxxConstruct && cls->hasCxxCtor();
    bool hasCxxDtor = cls->hasCxxDtor();
    bool fast = cls->canAllocNonpointer();
    size_t size;

    size = cls->instanceSize(extraBytes);
    if (outAllocatedSize) *outAllocatedSize = size;

    id obj = objc::malloc_instance(size, cls);
    if (slowpath(!obj)) {
        if (construct_flags & OBJECT_CONSTRUCT_CALL_BADALLOC) {
            return _objc_callBadAllocHandler(cls);
        }
        return nil;
    }

    if (fast) {
        obj->initInstanceIsa(cls, hasCxxDtor);
    } else {
        // Use raw pointer isa on the assumption that they might be
        // doing something weird with the zone or RR.
        obj->initIsa(cls);
    }

    if (fastpath(!hasCxxCtor)) {
        return obj;
    }

    construct_flags |= OBJECT_CONSTRUCT_FREE_ONFAILURE;
    return object_cxxConstructFromClass(obj, cls, construct_flags);
}

~~~

instanceSize 实现：有一个buck的宏定义：16、32、48、64、80 ...
~~~objective-c
    inline size_t instanceSize(size_t extraBytes) const {
        if (fastpath(cache.hasFastInstanceSize(extraBytes))) {
            return cache.fastInstanceSize(extraBytes);
        }

        size_t size = alignedInstanceSize() + extraBytes;
        // CF requires all objects be at least 16 bytes.
        if (size < 16) size = 16;
        return size;
    }
~~~



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
### 如果上面返回NO，则会进入完整的消息转发机制,这里又分为两个步骤：
#### 快速消息转发
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
#### 普通消息转发
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
//- (id)forwardingTargetForSelector:(SEL)aSelector{
//    if (aSelector == sel_registerName("wahaha")) {
//        return [Dog new];
//    }
//    return nil;
//}

//返回方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if (aSelector == sel_registerName("wahaha")) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

//转发消息
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = anInvocation.selector;
    Dog *dog = [Dog new];
    if ([dog respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:dog];
    }
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

## Method class_getInstanceMethod(Class cls, SEL sel)
~~~objective-c
Method class_getInstanceMethod(Class cls, SEL sel)
{
    if (!cls  ||  !sel) return nil;

    // This deliberately avoids +initialize because it historically did so.

    // This implementation is a bit weird because it's the only place that
    // wants a Method instead of an IMP.

#warning fixme build and search caches

    // Search method lists, try method resolver, etc.
    lookUpImpOrForward(nil, sel, cls, LOOKUP_RESOLVER);

#warning fixme build and search caches

    return _class_getMethod(cls, sel);
}
~~~



using mutex_locker_t = mutex_t::locker;

extern ExplicitInitLock<mutex_t> runtimeLock;
~~~objective-c
static Method _class_getMethod(Class cls, SEL sel)
{
    mutex_locker_t lock(runtimeLock);
    return _method_sign(getMethod_nolock(cls, sel));
}
~~~

~~~obejctive-c
static method_t *
getMethod_nolock(Class cls, SEL sel)
{
    method_t *m = nil;

    lockdebug::assert_locked(&runtimeLock.get());

    // fixme nil cls?
    // fixme nil sel?

    ASSERT(cls->isRealized());

    while (cls  &&  ((m = getMethodNoSuper_nolock(cls, sel))) == nil) {
        cls = cls->getSuperclass();
    }

    return m;
}
~~~

~~~objective-c
static inline Method _method_sign(struct method_t *m) {
    if (!m)
        return NULL;
    return (Method)ptrauth_sign_unauthenticated(m, ptrauth_key_process_dependent_data, METHOD_SIGNING_DISCRIMINATOR);
}
~~~


## IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
~~~objective-c
IMP
class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
{
    if (!cls) return nil;

    mutex_locker_t lock(runtimeLock);
    return addMethod(cls, name, imp, types ?: "", YES);
}
~~~

~~~objective-c
static IMP
addMethod(Class cls, SEL name, IMP imp, const char *types, bool replace)
{
    IMP result = nil;

    lockdebug::assert_locked(&runtimeLock.get());

    checkIsKnownClass(cls);

    ASSERT(types);
    ASSERT(cls->isRealized());

    method_t *m;
    if ((m = getMethodNoSuper_nolock(cls, name))) {
        // already exists
        if (!replace) {
            result = m->imp(false);
        } else {
            result = _method_setImplementation(cls, m, imp);
        }
    } else {
        // fixme optimize
        method_list_t *newlist = method_list_t::allocateMethodList(1, fixed_up_method_list);

#if TARGET_OS_EXCLAVEKIT
        auto &first = newlist->begin()->bigStripped();
#else
        auto &first = newlist->begin()->bigSigned();
#endif
        first.name = name;
        first.types = strdupIfMutable(types);
        first.imp = imp;

        addMethods_finish(cls, newlist);
        result = nil;
    }

    return result;
}
~~~
