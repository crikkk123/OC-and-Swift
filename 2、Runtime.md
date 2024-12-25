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
Class内部结构中有一个方法缓存（cache_t），用散列表（哈希表）来缓存曾经调用过的方法，可以提高方法的查找速度
~~~objective-c
#import <Foundation/Foundation.h>
#import "Person.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* p = [[Person alloc] init];
        
        [p test];
    }
    return 0;
}

这样写其实就是给p对象发送test消息，在p对象利用isa指针找到类对象，在methods调用实例方法，也就是class_rw_t中遍历二维数组，如果找不到通过superclass找到父类的类对象，直到找到最后基类
这样不断地遍历，但是我们要是调用很多次，每次都找到基类很费时间，OC是利用方法缓存来解决这个问题，第一次调用的时候就放到方法缓存中，下次的时候找到缓存中的方法，不用找数组和superclass

struct cache_t {
    struct bucket_t *_buckets;        // 散列表
    mask_t _mask;                     // 散列表的长度  -1
    mask_t _occupied;                 // 已经缓存的方法数量
};

struct bucket_t {
private:
    cache_key_t _key;                // SEL作为key
    IMP _imp;                        // 函数的内存地址
};
~~~
我们知道cache底层是一个哈希表，他是如下操作的： @selector(test) & _mask当做索引存到哈希表中，有点像C++中的unordered_map的通过散列函数算出的哈希值

~~~objective-c
bucket_t * cache_t::find(cache_key_t k, id receiver)
{
    assert(k != 0);

    bucket_t *b = buckets();
    mask_t m = mask();
    mask_t begin = cache_hash(k, m);
    mask_t i = begin;
    do {
        if (b[i].key() == 0  ||  b[i].key() == k) {
            return &b[i];
        }
    } while ((i = cache_next(i, m)) != begin);

    // hack
    Class cls = (Class)((uintptr_t)this - offsetof(objc_class, cache));
    cache_t::bad_cache(receiver, (SEL)k, cls);
}
在这个cache_hash(k, m);函数中
static inline mask_t cache_hash(cache_key_t key, mask_t mask) 
{
    return (mask_t)(key & mask);
}
可以看到实际就是&上mask

do {
    if (b[i].key() == 0  ||  b[i].key() == k) {
        return &b[i];
    }
} while ((i = cache_next(i, m)) != begin);

#define CACHE_END_MARKER 1
static inline mask_t cache_next(mask_t i, mask_t mask) {
    return (i+1) & mask;
}

#elif __arm64__
// objc_msgSend has lots of registers available.
// Cache scan decrements. No end marker needed.
#define CACHE_END_MARKER 0
static inline mask_t cache_next(mask_t i, mask_t mask) {
    return i ? i-1 : mask;
}
他在缓存的时候 & 上mask 可能那个索引的位置已经有元素了，他会将索引值减1 （__arm64__）
在这里可以看到，如果 & 上的结果是我们要找的就直接返回了，如果索引位置的key不是我们要找的，则直接减1寻找


void cache_t::expand()
{
    cacheUpdateLock.assertLocked();
    
    uint32_t oldCapacity = capacity();
    uint32_t newCapacity = oldCapacity ? oldCapacity*2 : INIT_CACHE_SIZE;

    if ((uint32_t)(mask_t)newCapacity != newCapacity) {
        // mask overflow - can't grow further
        // fixme this wastes one bit of mask
        newCapacity = oldCapacity;
    }

    reallocate(oldCapacity, newCapacity);
}
如果内存不够的时候进行扩容2倍的空间，将mask更新，并将哈希表的内容清空，将原来的内存释放
~~~
![image](https://github.com/user-attachments/assets/8eec3a2a-c8ae-4723-b8b7-3049f7a83e02)
我来简单复述一下这个过程，实例对象首先通过isa指针找到类对象，先在类对象的objc_class的cache中查找，如果没有找到通过 & 上一个mask  找到 class_rw_t结构体，在里面的methods中查找方法，
如果找到了存储到自己的cache中，如果没有找到，通过上图中的superclass找到父类的类对象，首先在父类的objc_class的cache中查找，如果找到了返回，并存在自己类对象的cache中，如果cache中没有找到
则在父类的类对象的class_rw_t中的methods查找方法，如果找到了在父类的类对象的cache和自己类对象的cache中存储，如果没有找到则再通过superclass往上查找，直到基类，这个过程中可能涉及扩容在上面有写到

在这里我就懒得验证了，可以通过强转为自己的结构体来观察，如果需要我再验证吧

## objc_msgSend
### 消息发送
OC中的方法调用，其实都是转换为objc_msgSend函数的调用

objc_msgSend的执行流程可以分为3大阶段：消息发送、动态方法解析、消息转发
~~~objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* p = [[Person alloc] init];
        
        // ((void (*)(id, SEL))(void *)objc_msgSend)((id)p, sel_registerName("test"));
        // objc_msgSend(p, sel_registerName("test");
        // 消息接收者（receiver）：p
        // 消息名称：test
        [p test];
        
        // ((void (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("Person"), sel_registerName("initialize"));
        // objc_msgSend(objc_getClass("Person"), sel_registerName("initialize");
        // 消息接收者（receiver）：[Person class]
        // 消息名称：initialize
        [Person initialize];
        
        
        NSLog(@"%p  %p",sel_registerName("test"),@selector(test));  // 相同
    }
    return 0;
}
~~~

objc_msgSend的汇编
~~~objective-c
由于我不太懂汇编就不解释了
ENTRY _objc_msgSend
	UNWIND _objc_msgSend, NoFrame
	MESSENGER_START

	cmp	x0, #0			// nil check and tagged pointer check
	b.le	LNilOrTagged		//  (MSB tagged pointer looks negative)
	ldr	x13, [x0]		// x13 = isa
	and	x16, x13, #ISA_MASK	// x16 = class	
LGetIsaDone:
	CacheLookup NORMAL		// calls imp or objc_msgSend_uncached

LNilOrTagged:
	b.eq	LReturnZero		// nil check

	// tagged
	mov	x10, #0xf000000000000000
	cmp	x0, x10
	b.hs	LExtTag
	adrp	x10, _objc_debug_taggedpointer_classes@PAGE
	add	x10, x10, _objc_debug_taggedpointer_classes@PAGEOFF
	ubfx	x11, x0, #60, #4
	ldr	x16, [x10, x11, LSL #3]
	b	LGetIsaDone

LExtTag:
	// ext tagged
	adrp	x10, _objc_debug_taggedpointer_ext_classes@PAGE
	add	x10, x10, _objc_debug_taggedpointer_ext_classes@PAGEOFF
	ubfx	x11, x0, #52, #8
	ldr	x16, [x10, x11, LSL #3]
	b	LGetIsaDone
	
LReturnZero:
	// x0 is already zero
	mov	x1, #0
	movi	d0, #0
	movi	d1, #0
	movi	d2, #0
	movi	d3, #0
	MESSENGER_END_NIL
	ret

	END_ENTRY _objc_msgSend


	ENTRY _objc_msgLookup
	UNWIND _objc_msgLookup, NoFrame

    // x0寄存器，里面存放的是receiver，在这里判断消息接收者是否小于等于0
	cmp	x0, #0			// nil check and tagged pointer check
    // 如果小于0跳转到 LLookup_NilOrTagged           
	b.le	LLookup_NilOrTagged	//  (MSB tagged pointer looks negative)
	ldr	x13, [x0]		// x13 = isa
	and	x16, x13, #ISA_MASK	// x16 = class	
LLookup_GetIsaDone:
    // 查找缓存
	CacheLookup LOOKUP		// returns imp

LLookup_NilOrTagged:
	b.eq	LLookup_Nil	// nil check

	// tagged
	mov	x10, #0xf000000000000000
	cmp	x0, x10
	b.hs	LLookup_ExtTag
	adrp	x10, _objc_debug_taggedpointer_classes@PAGE
	add	x10, x10, _objc_debug_taggedpointer_classes@PAGEOFF
	ubfx	x11, x0, #60, #4
	ldr	x16, [x10, x11, LSL #3]
	b	LLookup_GetIsaDone

LLookup_ExtTag:	
	adrp	x10, _objc_debug_taggedpointer_ext_classes@PAGE
	add	x10, x10, _objc_debug_taggedpointer_ext_classes@PAGEOFF
	ubfx	x11, x0, #52, #8
	ldr	x16, [x10, x11, LSL #3]
	b	LLookup_GetIsaDone

LLookup_Nil:
	adrp	x17, __objc_msgNil@PAGE
	add	x17, x17, __objc_msgNil@PAGEOFF
	ret

	END_ENTRY _objc_msgLookup
~~~
整个流程：
先判断receiver是否为nil，如果为nil直接退出，如果不为nil，receiver通过isa指针找到receiverClass，从receiverClass的cache中查找方法，找到了方法调用方法，结束查找，没找到的话从receiverClass的class_rw_t中查找方法，如果已经排序使用二分查找，没有排序遍历查找，如果找到了方法，调用方法，结束查找，并将方法缓存到receiverClass的cache中，如果没有找到receiverClass通过superClass指针找到superClass，如果找到了方法，调用方法，并将方法缓存到receiverClass的cache中，如果没有找到方法从superClass的class_rw_t中查找方法，同样也有排序和未排序的情况，如果找到了调用方法，结束查找，并将方法缓存到receiverClass的cache中，如果没有找到判断上层是否还有superClass，如果有继续查找，如果没有进入动态方法解析阶段
![image](https://github.com/user-attachments/assets/8186d0f0-5af3-48c7-8739-280904f30043)

如果上述没有找到进入第二个阶段，动态方法解析阶段
### 动态方法解析
~~~objective-c
IMP lookUpImpOrForward(Class cls, SEL sel, id inst, 
                       bool initialize, bool cache, bool resolver)
{
    IMP imp = nil;
    bool triedResolver = NO;

    runtimeLock.assertUnlocked();

    // Optimistic cache lookup
    if (cache) {
        imp = cache_getImp(cls, sel);
        if (imp) return imp;
    }

    // runtimeLock is held during isRealized and isInitialized checking
    // to prevent races against concurrent realization.

    // runtimeLock is held during method search to make
    // method-lookup + cache-fill atomic with respect to method addition.
    // Otherwise, a category could be added but ignored indefinitely because
    // the cache was re-filled with the old value after the cache flush on
    // behalf of the category.

    runtimeLock.read();

    if (!cls->isRealized()) {
        // Drop the read-lock and acquire the write-lock.
        // realizeClass() checks isRealized() again to prevent
        // a race while the lock is down.
        runtimeLock.unlockRead();
        runtimeLock.write();

        realizeClass(cls);

        runtimeLock.unlockWrite();
        runtimeLock.read();
    }

    if (initialize  &&  !cls->isInitialized()) {
        runtimeLock.unlockRead();
        _class_initialize (_class_getNonMetaClass(cls, inst));
        runtimeLock.read();
        // If sel == initialize, _class_initialize will send +initialize and 
        // then the messenger will send +initialize again after this 
        // procedure finishes. Of course, if this is not being called 
        // from the messenger then it won't happen. 2778172
    }

    
 retry:    
    runtimeLock.assertReading();

    // Try this class's cache.

    imp = cache_getImp(cls, sel);
    if (imp) goto done;

    // Try this class's method lists.
    {
        Method meth = getMethodNoSuper_nolock(cls, sel);
        if (meth) {
            log_and_fill_cache(cls, meth->imp, sel, inst, cls);
            imp = meth->imp;
            goto done;
        }
    }

    // Try superclass caches and method lists.
    {
        unsigned attempts = unreasonableClassCount();
        for (Class curClass = cls->superclass;
             curClass != nil;
             curClass = curClass->superclass)
        {
            // Halt if there is a cycle in the superclass chain.
            if (--attempts == 0) {
                _objc_fatal("Memory corruption in class list.");
            }
            
            // Superclass cache.
            imp = cache_getImp(curClass, sel);
            if (imp) {
                if (imp != (IMP)_objc_msgForward_impcache) {
                    // Found the method in a superclass. Cache it in this class.
                    log_and_fill_cache(cls, imp, sel, inst, curClass);
                    goto done;
                }
                else {
                    // Found a forward:: entry in a superclass.
                    // Stop searching, but don't cache yet; call method 
                    // resolver for this class first.
                    break;
                }
            }
            
            // Superclass method list.
            Method meth = getMethodNoSuper_nolock(curClass, sel);
            if (meth) {
                log_and_fill_cache(cls, meth->imp, sel, inst, curClass);
                imp = meth->imp;
                goto done;
            }
        }
    }

    // No implementation found. Try method resolver once.
    // -------------------------------------------------------下面是动态方法解析
    if (resolver  &&  !triedResolver) {
        runtimeLock.unlockRead();
        _class_resolveMethod(cls, sel, inst);
        runtimeLock.read();
        // Don't cache the result; we don't hold the lock so it may have 
        // changed already. Re-do the search from scratch instead.
        triedResolver = YES;
        goto retry;
    }

    // No implementation found, and method resolver didn't help. 
    // Use forwarding.

    imp = (IMP)_objc_msgForward_impcache;
    cache_fill(cls, sel, imp, inst);

 done:
    runtimeLock.unlockRead();

    return imp;
}

triedResolver标记是否动态解析过
~~~

~~~objective-c
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

-(void)test;
-(void)temp;
@end

NS_ASSUME_NONNULL_END

-------------------------------
#import "Person.h"
#import <objc/runtime.h>


@implementation Person

//-(void)test{
//    NSLog(@"test");
//}

void abc(id self, SEL _cmd){
    printf("hello world\n");
}



-(void)other{
    NSLog(@"%s",__func__);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    
    if(sel == @selector(temp)){
        class_addMethod(self, sel, (IMP)abc, "v16@0:8");
        return YES;
    }
    
    Method mt = class_getInstanceMethod(self, @selector(other));
    if(sel == @selector(test)){
        class_addMethod(self, sel, method_getImplementation(mt), method_getTypeEncoding(mt));
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

@end

------------------------------------
#import <Foundation/Foundation.h>
#import "Person.h"
#import <objc/runtime.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* p = [[Person alloc] init];
        
        [p test];
        [p temp];
    }
    return 0;
}
~~~

流程：先看是否曾经有动态解析，如果有走消息转发机制，如果没有，调用+resloveInstanceMethod:或者+resloveClassMethod:方法来动态解析方法，并标记为已经动态解析，然后重新走消息发送（从receiverClass的cache中查找方法执行）
![image](https://github.com/user-attachments/assets/95e956ea-0706-4e57-9652-c5e80f943411)


### 消息转发
forwardingTargetForSelector：方法，有实例方法也有类方法
~~~objective-c
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

-(void)test;

@end

NS_ASSUME_NONNULL_END

--------------------------------
#import "Person.h"
#import <objc/runtime.h>
#import "Student.h"

@implementation Person

//-(void)test{
//    NSLog(@"test");
//}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    if(aSelector == @selector(test)){
        return [[Student alloc] init];
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end

-----------------------------------
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject

-(void)test;

@end

NS_ASSUME_NONNULL_END
-----------------------------------------
#import "Student.h"

@implementation Student

-(void)test{
    NSLog(@"%s",__func__);
}

@end
-------------------------------------------------
#import <Foundation/Foundation.h>
#import "Person.h"
#import <objc/runtime.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* p = [[Person alloc] init];
        
        [p test];
    }
    return 0;
}

输出：-[Student test]
~~~
源码：
~~~objective-c
........
    // No implementation found, and method resolver didn't help. 
    // Use forwarding.

    imp = (IMP)_objc_msgForward_impcache;
    cache_fill(cls, sel, imp, inst);

 done:
    runtimeLock.unlockRead();

    return imp;
}

看一下这个函数_objc_msgForward_impcache：

	STATIC_ENTRY __objc_msgForward_impcache

	MESSENGER_START
	nop
	MESSENGER_END_SLOW

	// No stret specialization.
	b	__objc_msgForward		// 调用 __objc_msgForward

	END_ENTRY __objc_msgForward_impcache

	
	ENTRY __objc_msgForward   

	adrp	x17, __objc_forward_handler@PAGE
	ldr	x17, [x17, __objc_forward_handler@PAGEOFF]
	br	x17
	
	END_ENTRY __objc_msgForward
后面就不太会了........
~~~

当forwardingTargetForSelector返回nil时
~~~objective-c
#import "Person.h"
#import <objc/runtime.h>
#import "Student.h"

@implementation Person

//-(void)test{
//    NSLog(@"test");
//}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    if(aSelector == @selector(test)){
//        return [[Student alloc] init];
        return nil;
    }
    return [super forwardingTargetForSelector:aSelector];
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if(aSelector == @selector(test)){
        return [NSMethodSignature signatureWithObjCTypes:"v16@0:8"];
    }
    return [super methodSignatureForSelector:aSelector];
}

// NSInvocation封装了一个方法调用，包括：方法调用者、方法、方法参数
// anInvocation.target 方法调用者
// anInvocation.selector 方法名
// [anInvocation getArgument: atIndex:] 方法参数
- (void)forwardInvocation:(NSInvocation *)anInvocation{
//    anInvocation.target = [[Student alloc] init];
//    [anInvocation invoke];
    
    [anInvocation invokeWithTarget:[[Student alloc] init]];
}

@end

~~~

整体流程：第1阶段： 先判断receiver是否为nil，如果为nil直接退出，如果不为nil，receiver通过isa指针找到receiverClass，从receiverClass的cache中查找方法，找到了方法调用方法，结束查找，没找到的话从receiverClass的class_rw_t中查找方法，如果已经排序使用二分查找，没有排序遍历查找，如果找到了方法，调用方法，结束查找，并将方法缓存到receiverClass的cache中，如果没有找到receiverClass通过superClass指针找到superClass，如果找到了方法，调用方法，并将方法缓存到receiverClass的cache中，如果没有找到方法从superClass的class_rw_t中查找方法，同样也有排序和未排序的情况，如果找到了调用方法，结束查找，并将方法缓存到receiverClass的cache中，如果没有找到判断上层是否还有superClass，如果有继续查找，如果没有进入动态方法解析阶段

第2阶段： 有一个bool类型的变量标记是否进入过动态方法解析阶段，如果为true进入第3阶段消息转发，如果为false，调用 +resolveInstanceMethod：  或者+resolveClassMethod： 方法来动态解析方法，标记为已经动态解析，再次进入第1阶段消息发送，如果走完第1个阶段还是没有解决，此时这个bool类型的变量为true，直接进入第3阶段消息发送

第3阶段：消息转发阶段：  调用forwardingTargetForSelector： 方法，返回值不为nil调用：objc_msgSend(返回值，SEL)   如果调用forwardingTargetForSelector返回值为nil，调用  methodSignatureForSelector：  方法，如果返回值不为nil  调用forwardInvocation： 方法，   methodSignatureForSelector返回值为nil，调用  doesNotRecognizeSelector：方法，也就是我们熟悉的方法找不到

![image](https://github.com/user-attachments/assets/fe765add-4f35-4b7a-b3e4-37b9c4fc754c)
![image](https://github.com/user-attachments/assets/093b5f79-9045-40b4-a9d9-e6cd077ed496)
![image](https://github.com/user-attachments/assets/8368196b-8bcc-42f8-926c-9e5bc58a9a49)



### 处理类方法
~~~objective-c
#import <Foundation/Foundation.h>
#import "Person.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [Person test];
    }
    return 0;
}
------------------------------------------------------
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
+(void)test;
@end

NS_ASSUME_NONNULL_END
-------------------------------------------------------------
#import "Person.h"
#import "Student.h"
#import <objc/runtime.h>

@implementation Person


+(id)forwardingTargetForSelector:(SEL)aSelector{
    return [Student class];
}
@end
----------------------------------------------------------------------
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject

+(void)test;

@end

NS_ASSUME_NONNULL_END
-----------------------------------------------------------------------------
#import "Student.h"

@implementation Student

+(void)test{
    NSLog(@"%s",__func__);
}

@end

~~~
