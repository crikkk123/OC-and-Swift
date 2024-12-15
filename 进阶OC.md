# OC进阶

## 1、runtime库函数
头文件：类相关函数#import<objc/runtime.h>

消息相关函数：#import<objc/message.h>


## 2、使用objc_msgSend函数
强制转换：((void(*)(id,SEL,int))(void*)objc_msgSend)   把oc的方法转换成objc_msgSend函数执行


## 3、OC代码转换为CPP代码的命令
~~~text
xrun -sdk iphoneos clang -arch arm64 -rewrite-objc OC源文件 -o 输出的CPP文件  链接其他的（-framework UIKit）

clang -rewrite-objc main.m -o main.cpp
~~~


## 4、Class objc_getClass(const char *aClassName) 与 Class object_getClass(id obj)
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

## 5、isa
~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject* abd = [[NSObject alloc] init];
    }
    return 0;
}
~~~

代码：
~~~objective-c
struct NSObject_IMPL {
	Class isa;
};

typedef struct objc_class *Class;

struct objc_object {
    Class _Nonnull isa __attribute__((deprecated));
};
~~~

~~~objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface Student : NSObject

@property(nonatomic,assign) int age;
@property(nonatomic,assign) int weight;

@end

@implementation Student


@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student* abd = [[Student alloc] init];
    }
    return 0;
}
~~~
~~~objective-c
struct Student_IMPL {
	struct NSObject_IMPL NSObject_IVARS;
	int _age;
	int _weight;
};

struct NSObject_IMPL {
	Class isa;
};
~~~

## 6、objc_class
~~~objective-c
源码较多，选取部分

struct objc_class : objc_object {
  objc_class(const objc_class&) = delete;
  objc_class(objc_class&&) = delete;
  void operator=(const objc_class&) = delete;
  void operator=(objc_class&&) = delete;
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags

~~~

objc_class & FAST_DATA_MASK
~~~
直接拿取大神的

struct class_rw_t {
    uint32_t flags;
    uint32_t version;
    const class_ro_t *ro;
    method_list_t *methods;       // 方法列表
    property_list_t *properties;   // 属性列表
    const protocol_list_t *protocols;   // 协议列表
    Class firstSubclass;
    Class nextSiblingClass;
    char *demangledName;
}

~~~

~~~objective-c
struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
#ifdef __LP64__
    uint32_t reserved;
#endif
    const uint8_t * ivarLayout;
    const char *name;   // 类名
    method_list_t *baseMethodList;
    protocol_list_t *ivars;   // 成员变量列表
    const ivar_list_t * ivars;
    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;
~~~

![image](https://github.com/user-attachments/assets/4c96f669-6322-4aeb-9567-22007b176bdf)


## 7、三种OC对象
instance  实例对象  ：  isa指针、其他成员变量

class     类对象    ：  isa指针、superclass指针、类的属性信息、对象方法信息（-方法）、类的协议信息、instance对象的成员变量的描述信息

meta-class  元对象  ：  isa指针、superclass指针、类方法信息（+方法）

![image](https://github.com/user-attachments/assets/de564eb6-0091-4336-be17-b81676b45006)

沿着路线查找最终找不到返回错误：[ERROR: unrecognized selector sent to instance]

## 8、instance、class、meta-class（isa、superclass）总结
![image](https://github.com/user-attachments/assets/59e1fe72-2929-41ae-a581-74e5107bc165)


验证
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

这里利用struct看出实例对象的isa指针指向类对象
![a729aec05c2e1e0dc8b1e3731001d1ef](https://github.com/user-attachments/assets/7cabf501-a18b-4ad8-9112-fc261cac2930)


详细解释：runtime对isa的优化


## 9、objc_msgSend
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

## 10、OC的消息转发
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

## 11、class_getInstanceSize ()方法可以计算一个类的实例对象所实际需要的的空间大小
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

---------------------------------------------------------------------------

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

    size = cls->instanceSize(extraBytes);	// 关键
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

        size_t size = alignedInstanceSize() + extraBytes;	// 调用alignedInstanceSize，一般extraBytes为0
        // CF requires all objects be at least 16 bytes.
        if (size < 16) size = 16;
        return size;
    }

    uint32_t alignedInstanceSize() const {
        return word_align(unalignedInstanceSize());		// 内存对齐后的
    }
~~~


## 12、Method class_getInstanceMethod(Class cls, SEL sel)
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


## 13、IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
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


~~~objective-c
static void
checkIsKnownClass(Class cls)
{
    if (slowpath(!isKnownClass(cls))) {
        _objc_fatal("Attempt to use unknown class %p.", cls);
    }
}
~~~

~~~objective-c
static bool
isKnownClass(Class cls)
{
    if (fastpath(cls->isRealized() && objc::dataSegmentsRanges.contains(cls->data()->witness, (uintptr_t)cls))) {
        return true;
    }
    auto &set = objc::allocatedClasses.get();
    return set.find(cls) != set.end() || dataSegmentsContain(cls);
}
~~~


~~~objective-c
static IMP
_method_setImplementation(Class cls, method_t *m, IMP imp)
{
    lockdebug::assert_locked(&runtimeLock.get());

    if (!m) return nil;
    if (!imp) return nil;

    IMP old = m->imp(false);
    SEL sel = m->name();

    m->setImp(imp);

    // Cache updates are slow if cls is nil (i.e. unknown)
    // RR/AWZ updates are slow if cls is nil (i.e. unknown)
    // fixme build list of classes whose Methods are known externally?

    flushCaches(cls, __func__, [sel, old](Class c){
        return c->cache.shouldFlush(sel, old);
    });

    adjustCustomFlagsForMethodChange(cls, m);

    return old;
}
~~~


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



# KVC
key-value Coding 键值编码，可以通过一个key来访问某个属性


# Category
## 1、category的底层实现原理
~~~objective-c
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

-(void)run;

@end



NS_ASSUME_NONNULL_END

#import "Person.h"

@implementation Person

-(void)run{
    NSLog(@"run");
}

@end


#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (Eat)

-(void)eat;

@end

NS_ASSUME_NONNULL_END


#import "Person+Eat.h"

@implementation Person (Eat)

-(void)eat{
    NSLog(@"eat");
}

@end


#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (Test)

-(void)test;

@end

NS_ASSUME_NONNULL_END


#import "Person+Test.h"

@implementation Person (Test)

-(void)test{
    NSLog(@"test");
}

@end


#import <Foundation/Foundation.h>
#import "Person.h"
#import "Person+Test.h"
#import "Person+Eat.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* p = [[Person alloc] init];
        [p run];
        [p test];
        [p eat];
    }
    return 0;
}

~~~




## +load方法
调用时机：+load方法会在Runtime加载类对象(class)和分类(category)的时候调用

调用频率： 每个类对象、分类的+load方法，在工程的整个生命周期中只调用一次

调用顺序：

1、先调用类对象(class)的+load方法：

	类对象的load调用顺序是按照  类文件的编译顺序  进行先后调用；
 
	调用子类+load之前会先调用父类的+load方法

2、再调用分类(category)的+load方法：按照编译先后顺序调用（先编译的，先被调用）

+load方法是在程序一启动运行，加载镜像中的类对象(class)和分类(category)的时候就会调用，只会调用一次，不论在项目中有没有用到该类对象或者该分类，他们统统都会先被加载进内存，因为类的加载只有一次，所以所有的load方法肯定都会被调用而且只有一次



## +initialize方法

## 关联对象
~~~objective-c
@interface Person ： NSObject
@property(nonatomic,assign) int age;
@end

等同于

@interface Person ： NSObject
{
    int _age;
}
-(void) setAge:(int) age;
-(int) age;
@end

@implementation Person

-(void) setAge:(int) age{
    _age = age;
}

-(int) age{
    return _age;
}

@end

添加一个分类

@interface Person(Test)
@property(nonatomic,assign) int weight;
@end

它会变为下面，私有变量不会生成，并且只有函数声明，既然他不提供手动添加成员变量和实现get、set方法，这样是报错的

@interface Person(Test)
-(void)setWeight:(int)weight;
-(int) weight;
@end

~~~
![image](https://github.com/user-attachments/assets/b20fb767-bb85-4f52-806e-6d0c39dc6411)

在Category底层中也是没有存储成员变量的：
![image](https://github.com/user-attachments/assets/c42da3fd-6378-42ff-988e-5410470766d1)

~~~objective-c
解决方法1：利用全局变量存储，但是这样的话多创建几个对象，使用的是一个全局变量

存在的问题：1、内存泄漏  2、线程安全   3、代码冗余

@implementation Person (Test)

int weight_;

-(void)setWeight:(int) weight{
    weight_ = weight;
}

-(int) weight{
    return weight_;
}

@end

解决方法2：利用字典

@implementation Person (Test)

NSMutableDictionary *weights_;

+(void)load{
    weights_ = [NSMutableDictionary dictionary];
}

-(void)setWeight:(int) weight{
    NSString* key = [NSString stringWithFormat:@"%p",self];
    weights_[key] = @(weight);
}

-(int) weight{
    NSString* key = [NSString stringWithFormat:@"%p",self];
    return [weights_[key] intValue];
}

@end
~~~
![image](https://github.com/user-attachments/assets/de6c1528-48a9-411d-8752-bee4cb918988)

~~~objective-c

objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,
                         id _Nullable value, objc_AssociationPolicy policy)

枚举值：
typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
    OBJC_ASSOCIATION_ASSIGN = 0,           /**< Specifies an unsafe unretained reference to the associated object. */
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, /**< Specifies a strong reference to the associated object. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   /**< Specifies that the associated object is copied. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_RETAIN = 01401,       /**< Specifies a strong reference to the associated object.
                                            *   The association is made atomically. */
    OBJC_ASSOCIATION_COPY = 01403          /**< Specifies that the associated object is copied.
                                            *   The association is made atomically. */
};


NameKey没赋值相当于空值，这样的话只有一个属性是可以的，但是再添加一个属性就有问题了

#import "Person+Test.h"
#import <objc/runtime.h>

@implementation Person (Test)

const void *NameKey;     

- (void) setName:(NSString *)name{
    objc_setAssociatedObject(self,NameKey,name,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*) name{
    return objc_getAssociatedObject(self, NameKey);
}

@end

---------------------------------------------------------------

存储自己的地址：

@interface Person (Test)

@property(nonatomic,assign) NSString* name;
@property(nonatomic,assign) int weight;

@end

#import "Person+Test.h"
#import <objc/runtime.h>

@implementation Person (Test)

static const void *NameKey = &NameKey;

- (void) setName:(NSString *)name{
    objc_setAssociatedObject(self,NameKey,name,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*) name{
    return objc_getAssociatedObject(self, NameKey);
}

static const void *WeightKey = &WeightKey;
- (void) setWeight:(int)weight{
    objc_setAssociatedObject(self,WeightKey,@(weight),OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (int)weight{
    return [objc_getAssociatedObject(self, WeightKey) intValue];
}

@end

---------------------------------------------------------------------------------------------------
static const char方案：

#import "Person+Test.h"
#import <objc/runtime.h>

@implementation Person (Test)

static const char NameKey;

- (void) setName:(NSString *)name{
    objc_setAssociatedObject(self,&NameKey,name,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*) name{
    return objc_getAssociatedObject(self, NameKey);
}

static const char WeightKey;
- (void) setWeight:(int)weight{
    objc_setAssociatedObject(self,&WeightKey,@(weight),OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (int)weight{
    return [objc_getAssociatedObject(self, &WeightKey) intValue];
}

@end


-----------------------------------------------------------------------------------------------------------------
利用字符串常量
#import "Person+Test.h"
#import <objc/runtime.h>

@implementation Person (Test)


- (void) setName:(NSString *)name{
    objc_setAssociatedObject(self,@"name",name,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*) name{
    return objc_getAssociatedObject(self, @"name");
}


- (void) setWeight:(int)weight{
    objc_setAssociatedObject(self,@"weight",@(weight),OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (int)weight{
    return [objc_getAssociatedObject(self, @"weight") intValue];
}

@end


---------------------------------------------------------------------------------
使用selector方法

#import "Person+Test.h"
#import <objc/runtime.h>

@implementation Person (Test)


- (void) setName:(NSString *)name{
    objc_setAssociatedObject(self,@selector(name),name,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*) name{
    return objc_getAssociatedObject(self, @selector(name));
}


- (void) setWeight:(int)weight{
    objc_setAssociatedObject(self,@selector(weight),@(weight),OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (int)weight{
    return [objc_getAssociatedObject(self, @selector(weight)) intValue];
}

@end

~~~

关联对象的底层原理：
AssociationManager
AssociationHashMap
ObjectAssociationMap
ObjcAssociation

~~~objective-c
源码：

void
objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
{
    _object_set_associative_reference(object, key, value, policy);
}


void
_object_set_associative_reference(id object, const void *key, id value, uintptr_t policy)
{
    // This code used to work when nil was passed for object and key. Some code
    // probably relies on that to not crash. Check and handle it explicitly.
    // rdar://problem/44094390
    if (!object && !value) return;

    if (object->getIsa()->forbidsAssociatedObjects())
        _objc_fatal("objc_setAssociatedObject called on instance (%p) of class %s which does not allow associated objects", object, object_getClassName(object));

    DisguisedPtr<objc_object> disguised{(objc_object *)object};
    ObjcAssociation association{policy, value};

    // retain the new value (if any) outside the lock.
    association.acquireValue();

    bool isFirstAssociation = false;
    {
        AssociationsManager manager;	// 在下面这个类型的具体
        AssociationsHashMap &associations(manager.get());

        if (value) {
            auto refs_result = associations.try_emplace(disguised, ObjectAssociationMap{});
            if (refs_result.second) {
                /* it's the first association we make */
                isFirstAssociation = true;
            }

            /* establish or replace the association */
            auto &refs = refs_result.first->second;
            auto result = refs.try_emplace(key, std::move(association));
            if (!result.second) {
                association.swap(result.first->second);
            }
        } else {
            auto refs_it = associations.find(disguised);
            if (refs_it != associations.end()) {
                auto &refs = refs_it->second;
                auto it = refs.find(key);
                if (it != refs.end()) {
                    association.swap(it->second);
                    refs.erase(it);
                    if (refs.size() == 0) {
                        associations.erase(refs_it);

                    }
                }
            }
        }
    }

    // Call setHasAssociatedObjects outside the lock, since this
    // will call the object's _noteAssociatedObjects method if it
    // has one, and this may trigger +initialize which might do
    // arbitrary stuff, including setting more associated objects.
    if (isFirstAssociation)
        object->setHasAssociatedObjects();

    // release the old value (outside of the lock).
    association.releaseHeldValue();
}

class AssociationsManager {
    using Storage = ExplicitInitDenseMap<DisguisedPtr<objc_object>, ObjectAssociationMap>; 	// value的类型在下面
    static Storage _mapStorage;

public:
    AssociationsManager()   { AssociationsManagerLock.lock(); }
    ~AssociationsManager()  { AssociationsManagerLock.unlock(); }

    AssociationsHashMap &get() {
        return _mapStorage.get();
    }

    static void init() {
        _mapStorage.init();
    }
};

typedef DenseMap<const void *, ObjcAssociation> ObjectAssociationMap;	 	// value的类型在下面


api那个存储在这
class ObjcAssociation {
    uintptr_t _policy;	// 1
    id _value;		// 2
public:
    ObjcAssociation(uintptr_t policy, id value) : _policy(policy), _value(value) {}
    ObjcAssociation() : _policy(0), _value(nil) {}
    ObjcAssociation(const ObjcAssociation &other) = default;
    ObjcAssociation &operator=(const ObjcAssociation &other) = default;
    ObjcAssociation(ObjcAssociation &&other) : ObjcAssociation() {
        swap(other);
    }

    inline void swap(ObjcAssociation &other) {
        std::swap(_policy, other._policy);
        std::swap(_value, other._value);
    }

    inline uintptr_t policy() const { return _policy; }
    inline id value() const { return _value; }

    inline void acquireValue() {
        if (_value) {
            switch (_policy & 0xFF) {
            case OBJC_ASSOCIATION_SETTER_RETAIN:
                _value = objc_retain(_value);
                break;
            case OBJC_ASSOCIATION_SETTER_COPY:
                _value = ((id(*)(id, SEL))objc_msgSend)(_value, @selector(copy));
                break;
            }
        }
    }

    inline void releaseHeldValue() {
        if (_value && (_policy & OBJC_ASSOCIATION_SETTER_RETAIN)) {
            objc_release(_value);
        }
    }

    inline void retainReturnedValue() {
        if (_value && (_policy & OBJC_ASSOCIATION_GETTER_RETAIN)) {
            objc_retain(_value);
        }
    }

    inline id autoreleaseReturnedValue() {
        if (slowpath(_value && (_policy & OBJC_ASSOCIATION_GETTER_AUTORELEASE))) {
            return objc_autorelease(_value);
        }
        return _value;
    }
};

~~~

OBJC_EXPORT void
objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,
                         id _Nullable value, objc_AssociationPolicy policy)

![image](https://github.com/user-attachments/assets/e767fbc5-9ffd-4108-92e4-9cecedd7c172)


-------------------------------------------------------------------------------------------------------------
1、不能直接给Category添加成员变量，但是可以间接实现Category有成员变量的效果

# Block
~~~objective-c
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ^{
            NSLog(@"asd");
            NSLog(@"sa435dsfsd");
        }();
        
        int age = 10;
        
        void (^block)(int,int) = ^(int a,int b){
            NSLog(@"wkeqjkrg -  %@",age);
            NSLog(@"12335");
        };
        block(10,20);
        
    }
    return 0;
}
~~~
~~~objective-c
转成cpp代码

struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

struct __main_block_impl_1 {
  struct __block_impl impl;	// 变量相当于把上面结构体内的成员拿过来
  struct __main_block_desc_1* Desc;
  int age;			// 函数里面需要用到外面的age，把他封装到里面
  __main_block_impl_1(void *fp, struct __main_block_desc_1 *desc, int _age, int flags=0) : age(_age) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};


int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA))();
        int age = 10;
        void (*block)(int,int) = ((void (*)(int, int))&__main_block_impl_1((void *)__main_block_func_1, &__main_block_desc_1_DATA, age));
        ((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 10, 20);
    }
    return 0;
}
~~~

~~~objective-c
#import <Foundation/Foundation.h>


struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

static struct __main_block_desc_1 {
  size_t reserved;
  size_t Block_size;
};

struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_1* Desc;
  int age;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ^{
            NSLog(@"asd");
            NSLog(@"sa435dsfsd");
        }();
        
        int age = 100;
        
        void (^block)(int,int) = ^(int a,int b){
            NSLog(@"wkeqjkrg -  %d",age);
            NSLog(@"12335");
        };
        block(10,20);
        
        struct __main_block_impl_1* myblo = (__bridge struct __main_block_impl_1*)block;
        
        NSLog(@"end");
    }
    return 0;
}

~~~
![image](https://github.com/user-attachments/assets/dcaac691-9564-4847-b420-8a88d5ebeb9f)

~~~objective-c
#import <Foundation/Foundation.h>


struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

static struct __main_block_desc_1 {
  size_t reserved;
  size_t Block_size;
};

struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_1* Desc;
  int age;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ^{
            NSLog(@"asd");
            NSLog(@"sa435dsfsd");
        }();
        
        int age = 100;
        
        void (^block)(int,int) = ^(int a,int b){
		// age的值捕获进来（capture）
            NSLog(@"wkeqjkrg -  %d",age);
            NSLog(@"12335");
        };
        
        age = 200;
        
        block(10,20);
        
        struct __main_block_impl_1* myblo = (__bridge struct __main_block_impl_1*)block;
        
        NSLog(@"end");
    }
    return 0;
}

此时打印的age是100

转换后的CPP代码
struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_1* Desc;
  int age;	// 和外面的成员变量一样
  __main_block_impl_1(void *fp, struct __main_block_desc_1 *desc, int _age, int flags=0) : age(_age) {	  // 值传递
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
~~~~

~~~objective-c
#import <Foundation/Foundation.h>


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ^{
            NSLog(@"asd");
            NSLog(@"sa435dsfsd");
        }();
        
        auto int age = 100;
        static int height = 12;
        
        void (^block)(int,int) = ^(int a,int b){
            NSLog(@"wkeqjkrg -  %d %d",age,height);
            NSLog(@"12335");
        };
        
        age = 200;
        height = 2354;
        
        block(10,20);
        
        struct __main_block_impl_1* myblo = (__bridge struct __main_block_impl_1*)block;
        
        NSLog(@"end");
    }
    return 0;
}

static 是会修改的

struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_1* Desc;
  int age;
  int *height;
  __main_block_impl_1(void *fp, struct __main_block_desc_1 *desc, int _age, int *_height, int flags=0) : age(_age), height(_height) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA))();
        auto int age = 100;		// 离开作用域就释放了，闭包存储副本
        static int height = 12;		// 一直在内存中
        void (*block)(int,int) = ((void (*)(int, int))&__main_block_impl_1((void *)__main_block_func_1, &__main_block_desc_1_DATA, age, &height));
        age = 200;
        height = 2354;
        ((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 10, 20);
        struct __main_block_impl_1* myblo = (__bridge struct __main_block_impl_1*)block;
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_12_mm73jkz91yndqd1l04vb3s6m0000gn_T_main_6b91ae_mi_4);
    }
    return 0;
}

~~~

~~~objective-c
#import <Foundation/Foundation.h>

int age = 100;
static int height = 12;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        void (^block)() = ^(){
            NSLog(@"wkeqjkrg -  %d %d",age,height);
        };
        
        age = 200;
        height = 2354;
        
        block();
        
        NSLog(@"end");
    }
    return 0;
}

cpp代码
int age = 100;
static int height = 12;

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
可以看到没有捕获到结构体中
~~~

~~~objective-c
Person.h:
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

-(void) test;

@end

NS_ASSUME_NONNULL_END

Person.m:
#import "Person.h"

@implementation Person

-(void)test{         // 对应C语言：void test(Person* self, SEL _cmd)
    void(^block1)(void) = ^{
        NSLog(@"------ %p",self);
    };
    block1();
}

@end

转成cpp代码：
struct __Person__test_block_impl_0 {
  struct __block_impl impl;
  struct __Person__test_block_desc_0* Desc;
  Person *self;			// 捕获了self
  __Person__test_block_impl_0(void *fp, struct __Person__test_block_desc_0 *desc, Person *_self, int flags=0) : self(_self) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
~~~

block本质上也是一个oc对象，也有isa指针，只要有isa指针就是oc对象，block是封装了函数调用以及函数调用环境的OC对象

block的类型：
~~~objective-c
#import <Foundation/Foundation.h>

void test(){
    void (^block)(void) = ^{
        NSLog(@"Hello world");
    };
    
    NSLog(@"%@",[block class]);
    NSLog(@"%@",[[block class] superclass]);
    NSLog(@"%@",[[[block class] superclass] superclass]);
    NSLog(@"%@",[[[[block class] superclass] superclass] superclass]);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        void (^block1)(void) = ^{
            NSLog(@"Hello");
        };
        
        int age = 10;
        void (^block2)(void) = ^{
            NSLog(@"Hello world %d",age);
        };
        
        NSLog(@"%@  %@  %@",[block1 class],[block2 class],[^{
            NSLog(@"%d",age);
        } class]);
    }
    return 0;
}


~~~

block有3种类型，可以调用class方法或者isa指针查看具体的类型，最终都继承NSBlock类型

_NSGlobalBlock__   (_NSConcreateGlobalBlock)     没有访问auto变量    程序的数据区域     copy：什么也不做    
  
_NSStackBlock__    (_NSConcreateStackBlock)      访问了auto变量      栈                 copy：从栈复制到堆

_NSMallocBlock__   (_NSConcreteMallocBlock)      __NSStackBlock__调用了copy             copy：引用计数增加
 
![image](https://github.com/user-attachments/assets/9eed55d2-9621-4f6f-86fb-274662997444)

![image](https://github.com/user-attachments/assets/98f2144d-0349-4c80-88c7-d45ecbbbd1b0)



~~~objective-c
#import <Foundation/Foundation.h>

void (^block123)(void);

void test(){
    int age = 100;
    block123 = ^{
        NSLog(@"block  %d ",age);
    };
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // Global:没有访问auto变量   放在数据段
        void (^block)(void) = ^{
            NSLog(@"Hello world");
        };
        NSLog(@"%@",[block class]);   // __NSGlobalBlock__
        
        
        // stack：访问了auto变量
        int age = 10;
        void (^block1)(void) = ^{
            NSLog(@"Hello world - %d",age);
        };
        NSLog(@"%@",[block1 class]);    // ARC：__NSMallocBlock__
        
        int weight = 10;
        void (^block2)(void) = [^{
            NSLog(@"Hello world - %d",weight);
        } copy];	// 会在堆上创建内存存放和栈上相同的值
        NSLog(@"%@",[block2 class]);
        
        test();
        block123();
        
    }
    return 0;
}

上面都是MRC环境下
输出：
__NSGlobalBlock__
__NSStackBlock__
__NSMallocBlock__
block  -1074793912
~~~

ARC环境下，编译器会根据情况自动将栈上的block复制到堆上：
1、block作为函数返回值时
~~~objective-c
#import <Foundation/Foundation.h>

typedef void (^Block)(void);

Block myBlock(){
    // ARC   release也不需要我们调用
    return ^{
        NSLog(@"hello world");
    };;
}

Block myBlock2(){
    int age = 10;
    return ^{
        NSLog(@"hello world %d",age);
    };;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Block block1 = myBlock();
        block1();
        NSLog(@"%@",[block1 class]);  // __NSGlobalBlock__ 进行copy什么也不做
        
        Block block2 = myBlock2();
        block2();
        NSLog(@"%@",[block2 class]);  // __NSMallocBlock__
    }
    return 0;
}

~~~
2、将block赋值给__strong指针时
~~~objective-c
#import <Foundation/Foundation.h>

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int age = 10;
        Block block = ^{
            NSLog(@"hello world %d",age);
        };
        NSLog(@"%@",[block class]);   // ARC: __NSMallocBlock__    MRC: __NSStackBlock__
        
        
        NSLog(@"%@",[^{         // __NSStackBlock__  没有强指针指向
            NSLog(@"hello world %d",age);
        } class]);
        
        NSLog(@"%@",[^{         // __NSGlobalBlock__
            NSLog(@"hello world %d");
        } class]);
    }
    return 0;
}

~~~

3、block作为Cocoa API中方法名含有usingBlock的方法参数时
~~~objective-c
#import <Foundation/Foundation.h>

// 像这种
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray* array = @[];
        
        [array enumerateObjectsUsingBlock:<#^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)block#>]
    }
    return 0;
}

~~~

4、block作为GCD API的方法参数时
~~~objective-c
#import <Foundation/Foundation.h>


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            <#code to be executed once#>
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(<#delayInSeconds#> * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            <#code to be executed after a specified delay#>
        });
    }
    return 0;
}
~~~

~~~objective-c

在ARC环境下Person对象出了作用域调用析构

#import <Foundation/Foundation.h>
#import "Person.h"

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        {
            Person* p = [[Person alloc] init];
            p.age = 10;
        }
        
        
    return 0;
}

#import <Foundation/Foundation.h>
#import "Person.h"

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Block block1;
        
        {
            Person* p = [[Person alloc] init];
            p.age = 10;
            
            block1 = ^{
                NSLog(@"%d",p.age);
            };
        }
        
        block1();
    }
    return 0;
}
输出结果：10、Person dealloc

转成的cpp代码：
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  Person *p;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, Person *_p, int flags=0) : p(_p) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
有一个Person类型的指针，其实将Person对象的引用计数+1，当引用计数为0的时候进行释放（C++智能指针）


在ARC环境下，自动copy：
#import <Foundation/Foundation.h>
#import "Person.h"

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Block block1;
        
        {
            Person* p = [[Person alloc] init];
            p.age = 10;
            
            block1 = ^{
                NSLog(@"%d",p.age);
            };
            [p release];
        }
        
//        block1();
        NSLog(@"------");
    }
    return 0;
}
输出：Person dealloc   ------

如果是MRC环境下其操作，其实就是copy，将栈上的对象拷贝到堆上（前面写过），栈空间上的block不用持有外面对象的，如果是堆空间上的是可以保住外面对象的声明周期的：

#import <Foundation/Foundation.h>
#import "Person.h"

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Block block1;
        
        {
            Person* p = [[Person alloc] init];
            p.age = 10;
            
            block1 = [^{
                NSLog(@"%d",p.age);
            } copy];
            [p release];
        }
        
//        block1();
        NSLog(@"------");
    }
    return 0;
}


我们回到ARC环境：
#import <Foundation/Foundation.h>
#import "Person.h"

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Block block1;
        
        {
            Person* p = [[Person alloc] init];
            p.age = 10;
            
            __weak Person* weakPer = p;
            block1 = ^{
                NSLog(@"%d",weakPer.age);
            };
        }
        
//        block1();
        NSLog(@"------");
    }
    return 0;
}
输出：Person dealloc、------

转换成cpp代码：
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  Person *__weak weakPer;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, Person *__weak _weakPer, int flags=0) : weakPer(_weakPer) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

可以发现__main_block_impl_0与之前有所不同

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

第三个参数传递的是__main_block_copy_0的地址

在内部调用_Block_object_assign
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->weakPer, (void*)src->weakPer, 3/*BLOCK_FIELD_IS_OBJECT*/);}

第四个参数传递的是__main_block_dispose_0
static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->weakPer, 3/*BLOCK_FIELD_IS_OBJECT*/);}

~~~

总结：
当block内部访问了对象类型的auto变量时，如果block是在栈上，将不会对auto变量产生强引用

当block被拷贝到堆上，会调用block内部的copy函数，copy函数内部会调用_Block_object_assign函数，_Block_object_assign函数会根据auto变量的修饰符(_strong、_weak、_unsafe_unretained)做出相应的操作，形成强引用(retain)或者弱引用

当block从堆上移除，会调用block内部的dispose函数，dispose函数内部会调用_Block_object_dispose函数，_Block_object_dispose函数会自动释放引用的auto变量（release）

copy函数：栈上的Block复制到堆时调用     dispose 堆上的Block被废弃时调用


~~~objective-c

正常情况下，我们在block里面是没办法直接修改age的值的，底层是创建一个相同的变量（前面写过），我们又不想创建一个全局或者static的变量

#import <Foundation/Foundation.h>

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int age = 10;
        Block block = ^{
//            age = 20;
            NSLog(@"%d",age);
        };
        block();
    }
    return 0;
}


可以用__block
~~~

### __block
~~~objective-c
#import <Foundation/Foundation.h>

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block int age = 10;
        Block block = ^{
            age = 20;
            NSLog(@"%d",age);
        };
        NSLog(@"%d",age);
        block();
    }
    return 0;
}

转换为cpp代码：
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_age_0 *age; // by ref			这里__block是包装为一个对象
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_age_0 *_age, int flags=0) : age(_age->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

typedef void (*Block)(void);
struct __Block_byref_age_0 {
  void *__isa;
__Block_byref_age_0 *__forwarding;
 int __flags;
 int __size;
 int age;
};

int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        __attribute__((__blocks__(byref))) __Block_byref_age_0 age = {(void*)0,(__Block_byref_age_0 *)&age, 0, sizeof(__Block_byref_age_0), 10};   // 部分1
        Block block = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_age_0 *)&age, 570425344));
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_12_mm73jkz91yndqd1l04vb3s6m0000gn_T_main_6519ba_mi_1,(age.__forwarding->age));
        ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
    }
    return 0;
}   在主函数中我们看到部分1传递的参数，传到上面的结构体中，__forwarding实际指向的是他自己

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_age_0 *age = __cself->age; // bound by ref

            (age->__forwarding->age) = 20;
            NSLog((NSString *)&__NSConstantStringImpl__var_folders_12_mm73jkz91yndqd1l04vb3s6m0000gn_T_main_6519ba_mi_0,(age->__forwarding->age));
        }    修改age值的时候调用，拿到结构体中的值


如果是这种：
#import <Foundation/Foundation.h>

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block NSObject* obj = [[NSObject alloc] init];
        Block block = ^{
            obj = nil;
            NSLog(@"%p",obj);
        };
        block();
    }
    return 0;
}

转成cpp代码：
typedef void (*Block)(void);
struct __Block_byref_obj_0 {
  void *__isa;
__Block_byref_obj_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);	// 涉及到了内存管理
 void (*__Block_byref_id_object_dispose)(void*);
 NSObject *obj;
};

注:
#import <Foundation/Foundation.h>

typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSMutableArray* arr = [[NSMutableArray alloc] init];
        
        Block block = ^{
            [arr addObject:@123];
            NSLog(@"%p",arr);
        };
        block();
    }
    return 0;
}
这种是没必要加__block的，没有修改arr，只是用到arr往里面添加元素
~~~

~~~objective-c
#import <Foundation/Foundation.h>


typedef void (^Block)(void);

struct __Block_byref_age_0 {
    void *__isa;
    struct __Block_byref_age_0 *__forwarding;
    int __flags;
    int __size;
    int age;
};

struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    void (*copy)(void);
    void (*dispose)(void);
};

struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    struct __Block_byref_age_0 *age;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block int age = 10;
        Block block = ^{
            age = 20;
            NSLog(@"%d",age);
        };
        
        // 0x0000600002808510
        struct __main_block_impl_0 *p = (__bridge struct __main_block_impl_0*)block;
        
//        block();
        NSLog(@"%p",&age);
        NSLog(@"-----");
    }
    return 0;
}
图片：
~~~
![image](https://github.com/user-attachments/assets/2d9ed845-78b3-4201-a4ea-ead2bb8737d9)
结构体__Block_byref_age_0里面的age跟我们直接打印age的地址是一样的，打印出来地址差18，结构体偏移后正好为age的地址

同时这也能证明：
![image](https://github.com/user-attachments/assets/d74e93b7-d8f9-4648-83ca-728579ca4029)



# runtime
## 1、Apple对isa的优化
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
<img width="482" alt="image" src="https://github.com/user-attachments/assets/430f5b81-486d-4f59-8045-3e08a4ba1e0c">

苹果从ARM64位架构开始，对isa进行了优化，将其定义成一个共用体（union）结构，结合  位域 的概念以及  位运算  的方式来存储更多类相关信息。isa指针需要通过与一个叫ISA_MASK的值（掩码）进行二进制&运算，才能得到真实的class/meta-class对象的地址

ISA_MASK部分源码:
~~~objective-c
# if __arm64__
// ARM64 simulators have a larger address space, so use the ARM64e
// scheme even when simulators build for ARM64-not-e.
#   if TARGET_OS_EXCLAVEKIT
      // Because there's no TBI on ExclaveKit, the PAC takes up all of
      // the remaining bits and we can't have the inline reference count
#     define ISA_MASK        0xfffffffffffffff8ULL
#     define ISA_MAGIC_MASK  0x0000000000000001ULL
#     define ISA_MAGIC_VALUE 0x0000000000000001ULL
#     define ISA_HAS_CXX_DTOR_BIT 0
#     define ISA_BITFIELD                                                      \
        uintptr_t nonpointer        : 1;                                       \
        uintptr_t has_assoc         : 1;                                       \
        uintptr_t weakly_referenced : 1;                                       \
        uintptr_t shiftcls_and_sig  : 61;
#     define ISA_HAS_INLINE_RC 0
#   elif __has_feature(ptrauth_calls) || TARGET_OS_SIMULATOR
#     define ISA_MASK        0x007ffffffffffff8ULL
#     define ISA_MAGIC_MASK  0x0000000000000001ULL
#     define ISA_MAGIC_VALUE 0x0000000000000001ULL
#     define ISA_HAS_CXX_DTOR_BIT 0
#     define ISA_BITFIELD                                                      \
        uintptr_t nonpointer        : 1;                                       \
        uintptr_t has_assoc         : 1;                                       \
        uintptr_t weakly_referenced : 1;                                       \
        uintptr_t shiftcls_and_sig  : 52;                                      \
        uintptr_t has_sidetable_rc  : 1;                                       \
        uintptr_t extra_rc          : 8
#     define ISA_HAS_INLINE_RC    1
#     define RC_HAS_SIDETABLE_BIT 55
#     define RC_ONE_BIT           (RC_HAS_SIDETABLE_BIT+1)
#     define RC_ONE               (1ULL<<RC_ONE_BIT)
#     define RC_HALF              (1ULL<<7)
#   else
#     define ISA_MASK        0x0000000ffffffff8ULL
#     define ISA_MAGIC_MASK  0x000003f000000001ULL
#     define ISA_MAGIC_VALUE 0x000001a000000001ULL
#     define ISA_HAS_CXX_DTOR_BIT 1
#     define ISA_BITFIELD                                                      \
        uintptr_t nonpointer        : 1;                                       \
        uintptr_t has_assoc         : 1;                                       \
        uintptr_t has_cxx_dtor      : 1;                                       \
        uintptr_t shiftcls          : 33; /*MACH_VM_MAX_ADDRESS 0x1000000000*/ \
        uintptr_t magic             : 6;                                       \
        uintptr_t weakly_referenced : 1;                                       \
        uintptr_t unused            : 1;                                       \
        uintptr_t has_sidetable_rc  : 1;                                       \
        uintptr_t extra_rc          : 19
#     define ISA_HAS_INLINE_RC    1
#     define RC_HAS_SIDETABLE_BIT 44
#     define RC_ONE_BIT           (RC_HAS_SIDETABLE_BIT+1)
#     define RC_ONE               (1ULL<<RC_ONE_BIT)
#     define RC_HALF              (1ULL<<18)
#   endif

#   if TARGET_OS_SIMULATOR
#     define ISA_MASK_NOSIG ISA_MASK
#   elif TARGET_OS_OSX
#     define ISA_MASK_NOSIG 0x00007ffffffffff8ULL
#   elif TARGET_OS_EXCLAVEKIT
#     define ISA_MASK_NOSIG objc_debug_isa_class_mask
#   else
#     define ISA_MASK_NOSIG 0x0000000ffffffff8ULL
#   endif

# elif __x86_64__
#   define ISA_MASK        0x00007ffffffffff8ULL
#   define ISA_MAGIC_MASK  0x001f800000000001ULL
#   define ISA_MAGIC_VALUE 0x001d800000000001ULL
#   define ISA_HAS_CXX_DTOR_BIT 1
#   define ISA_BITFIELD                                                        \
      uintptr_t nonpointer        : 1;                                         \
      uintptr_t has_assoc         : 1;                                         \
      uintptr_t has_cxx_dtor      : 1;                                         \
      uintptr_t shiftcls          : 44; /*MACH_VM_MAX_ADDRESS 0x7fffffe00000*/ \
      uintptr_t magic             : 6;                                         \
      uintptr_t weakly_referenced : 1;                                         \
      uintptr_t unused            : 1;                                         \
      uintptr_t has_sidetable_rc  : 1;                                         \
      uintptr_t extra_rc          : 8
#   define ISA_HAS_INLINE_RC    1
#   define RC_HAS_SIDETABLE_BIT 55
#   define RC_ONE_BIT           (RC_HAS_SIDETABLE_BIT+1)
#   define RC_ONE               (1ULL<<RC_ONE_BIT)
#   define RC_HALF              (1ULL<<7)

# else
#   error unknown architecture for packed isa
# endif

// SUPPORT_PACKED_ISA
#endif
~~~
