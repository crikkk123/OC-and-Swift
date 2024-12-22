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

define ISA_MASK        0x007ffffffffffff8ULL  =》 0111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1000  可以看到转换二进制后 后三位全是0，所以class类，meta-class类的十六进制地址应该为0或者8结尾


## class的结构
元类对象的内部结构和类对象的内部结构是相同的，内部放的数据是不同的，元类对象是特殊的类对象
![image](https://github.com/user-attachments/assets/01900ddf-2569-4265-a9c0-e26273f723e4)

![image](https://github.com/user-attachments/assets/0bc7eaed-d766-4f73-b9b2-460c8d1be6ad)

methods里面存储的是类的和分类的方法列表，如果是类存储的是实例方法，meta-class存储的是类方法

properties里面存储了类的属性以及分类的属性

### class_rw_t
class_rw_t里面的methods、properties、protocols是二维数组，是可读可写的，包含了类的初始化内容、分类的内容

~~~objective-c
struct class_rw_ext_t {
    DECLARE_AUTHED_PTR_TEMPLATE(class_ro_t)
    class_ro_t_authed_ptr<const class_ro_t> ro;
    method_array_t methods;
    property_array_t properties;
    protocol_array_t protocols;
    const char *demangledName;
    uint32_t version;
};
~~~

method_array_t实际上是一个二维数组，里面存储的是一维数组，再里面是方法，二维数组指向的一维数组可能包含几个分类的方法最后是类的方法，分类的方法要在类方法的前面     这样可以动态的往里面增加方法和修改方法
~~~objective-c
class method_array_t : 
    public list_array_tt<method_t, method_list_t, method_list_t_authed_ptr>
{ .....
~~~

### class_ro_t
class_ro_t 里面的baseMethodList、baseProtocols、ivars、baseProperties是一维数组，是只读的，包含了类的初始内容，不包含分类

当程序运行起来的时候，将分类的内容和类的内容合并起来的时候放到可读可写的二维数组中

### method_t
method_t是对方法或函数的封装

~~~objective-c
struct method_t {
    SEL name;
    const char *types;
    IMP imp;

    struct SortBySELAddress :
        public std::binary_function<const method_t&,
                                    const method_t&, bool>
    {
        bool operator() (const method_t& lhs,
                         const method_t& rhs)
        { return lhs.name < rhs.name; }
    };
};

简化后：
struct method_t {
    SEL name;        // 函数名  选择器当做方法名
    const char *types;   // 编码（返回值类型，参数类型）
    IMP imp;     // 指向函数的指针（函数地址）
};

IMP代表函数的具体实现
typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...);

SEL代表方法/函数名，一般叫做选择器，底层结构跟char*类似
可以通过@selector()和sel_registerName()获得
可以通过sel_getName()和NSStringFromSelector()转成字符串
不同类中相同名字的方法，所对应的方法选择器是相同的（通过IMP找到实现）
typedef struct objc_selector *SEL;

types包含了函数返回值、参数编码的字符串
返回值 参数1  参数2  .... 参数n
~~~

### cache
