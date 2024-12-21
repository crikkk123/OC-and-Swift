# runtime

oc是一门动态性比较强的编程语言，可以在运行的时候修改编译好的文件，runtime的API基本都是C语言实现的，可以去苹果官网下载开源代码，少部分C++和汇编编写的

## isa指针
学习runtime之前，先了解底层常用的结构isa指针

在arm64架构之前，isa指针就是一个普通的指针，存储着Class、Meta-Class对象的内存地址

从arm64架构开始，对isa进行了优化，变成了一个共用体（union）结构，使用位域来存储更多的信息

~~~objective-c
struct objc_object {
private:
    char isa_storage[sizeof(isa_t)];

    isa_t &isa() { return *reinterpret_cast<isa_t *>(isa_storage); }
    const isa_t &isa() const { return *reinterpret_cast<const isa_t *>(isa_storage); }
public:  在这里就不展示了
~~~
其实就是一个C语言联合体，二进制对应的位表示信息，这个在一些read/write属性的时候就比较常见的，通过左移右移来设置和获取信息
我这里就不详细介绍联合体了，这个属于C语言基础

我们在下面验证一下
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
![image](https://github.com/user-attachments/assets/ea3b8904-900f-4c25-b0ca-e962b8bd677e)


苹果从ARM64位架构开始，对isa进行了优化，将其定义成一个共用体（union）结构，结合 位域 的概念以及 位运算 的方式来存储更多类相关信息。isa指针需要通过与一个叫ISA_MASK的值（掩码）进行二进制&运算，才能得到真实的class/meta-class对象的地址

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
简化后
~~~objective-c
union isa_t
{
    Class cls;
    uintptr_t bits;
    struct{
        uintptr_t nonpointer        : 1;                  
        uintptr_t has_assoc         : 1;
        uintptr_t has_cxx_dtor      : 1;
        uintptr_t shiftcls          : 33;
        uintptr_t magic             : 6;              
        uintptr_t weakly_referenced : 1;                            
        uintptr_t unused            : 1;                        
        uintptr_t has_sidetable_rc  : 1;                       
        uintptr_t extra_rc          : 19
    }
};

nonpointer:  0代表普通的指针，存储着class、meta-class对象的内存地址  1代表优化过，使用位域存储更多的信息

has_assoc：  是否有设置过关联对象，如果没有，释放时会更快

has_cxx_dtor：  是否有C++的析构函数（.cxx_destruct）,如果没有，释放时会更快

shiftcls：  存储着class、meta-class对象的内存地址信息

magic：  用于在调试时分辨对象是否未完成初始化

weakly_referenced：  是否有被弱引用指向过，如果没有，释放时会更快

unused：

has_sidetable_rc：  引用计数器是否大于无法存储在isa中，如果为1，那么引用计数会存储在一个叫sideTable的类属性中

extra_rc：  里面存储的值是引用计数器减1
~~~
