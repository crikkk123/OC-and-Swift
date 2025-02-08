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
wkeqjkrg -  200 2354
end
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


当block在栈上时，并不会对__block变量产生强引用

当block被copy到堆时，会调用block内部的copy函数，copy函数内部会调用_Block_object_assign函数，_Block_object_assign函数对_block变量形成强引用（retain）

当block从堆中移除时，会调用block内部的dispose函数，dispose函数内部会调用_Block_object_dispose函数，_Block_object_dispose函数会自动释放引用的_block变量（release）

_block的_forwarding指针：在栈上，自己的forwarding指针指向自己本身的指针，复制到堆上后，栈上的forwarding指针指向复制到堆上的_block变量用结构体的指针（堆上的forwarding指针指向自己本身的指针）

### 对象类型的auto变量、_block变量
当block在栈上时，对他们都不会产生强引用

当block拷贝到堆上时，都会通过copy函数来处理他们：
	_block变量（假设变量名叫做a）_Block_object_assign((void*)&dst->p,(void*)src->p,3/*BLOCK_FIELD_IS_OBJECT*/);

 	对象类型的auto变量（假设变量名叫做p） _Block_object_assign((void*)&dst->p,(void*)src->p,3/*BLOCK_FIELD_IS_OBJECT*/);

当block从堆上移除时，都会通过dispose函数来释放
	_block变量（假设变量名叫做a），_Block_object_dispose((void*)src->a,8/*BLOCK_FIELD_IS_BYREF*/);

 	对象类型的auto变量（假设变量名叫做p），_Block_object_dispose((void*)src->p,3/*BLOCK_FIELD_IS_OBJECT*/);

对象：BLOCK_FIELD_IS_OBJECT        _block变量：BLOCK_FIELD_IS_BYREF

### __block修饰对象
~~~objective-c
#import <Foundation/Foundation.h>
#import "Person.h"


typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block Person* person = [[Person alloc] init];
        person.age = 10;
        
        Block block = ^{
            person.age = 20;
            NSLog(@"%d",person.age);
        };
        block();
    }
    return 0;
}



转换为cpp代码：
typedef void (*Block)(void);
struct __Block_byref_person_0 {
  void *__isa;
__Block_byref_person_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 Person *__strong person;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_person_0 *person; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_person_0 *_person, int flags=0) : person(_person->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

我们可以看到 __Block_byref_person_0 *person; // by ref这句，其实就是使用__block产生的对象，指向这个对象的指针一定是强引用的，这个对象指针的Person对象根据我们传入的强/弱引用来进行引用

这个也很好验证，可以利用作用域来传入强引用和弱引用来验证，由于前面写了很多次，我这里就不验证了


MRC环境：
#import <Foundation/Foundation.h>
#import "Person.h"


typedef void (^Block)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block Person* person = [[Person alloc] init];
        Block block = [^{
            NSLog(@"%p",person);
        } copy];
        
        [person release];
        
        block();
        
        [block release];
    }
    return 0;
}
在没有打印person地址之前就打印了Person的析构，这里用到了__block修饰，内部结构就是block指向block包装的对象，这个包装的对象指向Person（这个永远为弱引用），在MRC环境下不会进行retain操作
~~~

### 循环引用
ARC环境下：

~~~objective-c
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^Block)(void);

@interface Person : NSObject

@property(nonatomic) int age;

@property(copy,nonatomic) Block block;  // 拷贝到堆上

@end

NS_ASSUME_NONNULL_END
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^Block)(void);

@interface Person : NSObject

@property(nonatomic) int age;

@property(copy,nonatomic) Block block;  // 拷贝到堆上

@end

NS_ASSUME_NONNULL_END

#import "Person.h"

@implementation Person

- (void)dealloc{
    NSLog(@"Person dealloc");
}

@end


#import <Foundation/Foundation.h>
#import "Person.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* person = [[Person alloc] init];
        person.age = 10;
        person.block = ^{
            NSLog(@"%d",person.age);
        };
    }
    NSLog(@"123");
    return 0;
}

输出123
可以看到并没有打印析构信息
循环引用：堆上的block指向Person对象，Person对象内部的block指向block
~~~
解决__weak
~~~objective-c
#import <Foundation/Foundation.h>
#import "Person.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* person = [[Person alloc] init];
        person.age = 10;
        __weak Person* pp = person;
        // _unsafe_unretained 、weak
        person.block = ^{
            NSLog(@"%d",pp.age);
        };
    }
    NSLog(@"123");
    return 0;
}

_unsafe_unretained 、weak的区别是weak指向的内存回收后会置为nil，另一个仍然指向，指向一块回收的内存

使用_block解决，但是这种方式缺陷是必须调用block
#import <Foundation/Foundation.h>
#import "Person.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* person = [[Person alloc] init];
        person.age = 10;
        __block Person* pp = person;
        person.block = ^{
            NSLog(@"%d",pp.age);
            pp = nil;
        };
        
        person.block();
    }
    NSLog(@"123");
    return 0;
}

其实这样的内存结构就是，_block变量持有对象的强引用，对象持有Block强引用，Block持有_block变量强引用，一个三角形的形状
~~~

### MRC环境下循环引用
MRC环境下不支持__weak
~~~objective-c
#import <Foundation/Foundation.h>
#import "Person.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* person = [[Person alloc] init];
        person.age = 10;
        __unsafe_unretained Person* pp = person;
        
        person.block = ^{
            NSLog(@"%d",pp.age);
            
        };
        [person release];
    }
    NSLog(@"123");
    return 0;
}

#import <Foundation/Foundation.h>
#import "Person.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* person = [[Person alloc] init];
        person.age = 10;
        __block Person* pp = person;
        
        person.block = ^{
            NSLog(@"%d",pp.age);
            
        };
        [person release];
    }
    NSLog(@"123");
    return 0;
}

我们前面说过被__block修饰的变量在MRC环境下不会进行retain，也就是不对Person对象进行retain
~~~
