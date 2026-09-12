# Day1



DeepSeek：sk-d03d7d072e4341cdb5e3a1bebc3fec6b

### 一个NSObject对象占用多少内存



```
我们平时编写的Objective-C代码，底层实现其实都是C\C++代码
```
<img width="1942" height="242" alt="image" src="https://github.com/user-attachments/assets/8209cd50-79af-4e36-b910-ea057e916ebc" />


所以Objective-C的面向对象都是基于C\C++的数据结构实现的

思考：Objective-C的对象、类主要是基于C\C++的什么数据结构实现的？

结构体

对象和类的底层数据结构都是 C 的 struct（结构体），不是指针。但指针是你访问它们的唯一方式——所以「基于指针」这个说法对了一半，是「访问方式对、存储结构不对」。

将Objective-C代码转换为C\C++代码

```text
xcrun  -sdk  iphoneos  clang  -arch  arm64  -rewrite-objc  OC源文件  -o  输出的CPP文件
```



如果需要链接其他框架，使用-framework参数。比如-framework UIKit

思考：一个OC对象在内存中是如何布局的？

NSObject的底层实现:
<img width="1896" height="716" alt="image" src="https://github.com/user-attachments/assets/8b56b362-8fdb-4c3d-84d8-40e4fb5d0708" />


```
一个NSObject对象占用多少内存？
```

系统分配了16个字节给NSObject对象（通过malloc_size函数获得）

但NSObject对象内部只使用了8个字节的空间（64bit环境下，可以通过class_getInstanceSize函数获得）



class_getInstanceSize:

~~~objc
size_t class_getInstanceSize(Class cls)
{
    if (!cls) return 0;
    cls->realizeIfNeeded();
    return cls->alignedInstanceSize();
}

// Class's ivar size rounded up to a pointer-size boundary.
/// 返回成员变量的大小
uint32_t alignedInstanceSize() const {
    return word_align(unalignedInstanceSize());
}

~~~

分配了 16 个字节，但是成员变量占用 8 个字节，一个 isa 指针变量





alloc的源码，会调用_objc_rootAllocWithZone

~~~Objc
id
_objc_rootAllocWithZone(Class cls, objc_zone_t)
{
    // allocWithZone under __OBJC2__ ignores the zone parameter
    cls->realizeIfNeeded();
    return _class_createInstance_realized(cls, 0, OBJECT_CONSTRUCT_CALL_BADALLOC);
}

// ---------------------------------------------------

_class_createInstance_realized:
static ALWAYS_INLINE id
_class_createInstance_realized(Class cls, size_t extraBytes,
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
// size = cls->instanceSize(extraBytes);这里的大小

inline size_t instanceSize(size_t extraBytes) const {
    if (fastpath(cache.hasFastInstanceSize(extraBytes))) {
        return cache.fastInstanceSize(extraBytes);
    }

    size_t size = alignedInstanceSize() + extraBytes;
    // CF requires all objects be at least 16 bytes.
    if (size < 16) size = 16;
    return size;
}
// 小于 16 时，分配 16 个字节
~~~



~~~text
一个NSObject对象占用多少内存？
答：系统分配了 16 个字节给 NSObject 对象（通过 malloc_size 函数获得）
但 NSObject 对象内部只使用了 8 个字节的空间（64Bit 环境下，可以用过 class_getInstanceSize 函数获得）
~~~

NSObject 代码：

~~~objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSObject *obj = [[NSObject alloc] init];
    
    // 获得NSObject实例对象的成员变量所占用的大小：8
    NSLog(@"%zd",class_getInstanceSize([NSObject class]));  // 8

    // 获得obj指针所指向内存的大小
    NSLog(@"%zd", malloc_size((__bridge const void *)obj));  // 16
}
~~~

Stundet:

~~~objc
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

struct NSObject_IMPL {
    Class isa;
};

struct Student_IMPL {
    struct NSObject_IMPL NSObject_IVARS;    // Class isa;
    int _no;
    int _age;
};


@interface Student : NSObject
{
    @public
    int _no;
    int _age;
}
@end

@implementation Student

@end



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student* stu = [[Student alloc] init];
        stu->_no = 4;
        stu->_age = 5;
        
        struct Student_IMPL *stuImpl = (__bridge struct Student_IMPL*)stu;
        NSLog(@"no is %d, age is %d",stuImpl->_no,stuImpl->_age); // no is 4, age is 5
        
        
        NSLog(@"%zd",class_getInstanceSize([Student class]));  // 16
        NSLog(@"%zd", malloc_size((__bridge const void *)stu));  // 16
    }
    return EXIT_SUCCESS;
}

~~~

<img width="2032" height="924" alt="image" src="https://github.com/user-attachments/assets/8df0c606-d659-491f-8bd4-db584c054cff" />
<img width="1936" height="714" alt="image" src="https://github.com/user-attachments/assets/dbc3ba3a-9347-4513-a43d-bdcc659ea237" />
<img width="1894" height="1052" alt="image" src="https://github.com/user-attachments/assets/7de0b507-4e45-4d07-a10b-91716ce20833" />


16 ,16

alloc 创建出来的实例对象，内存中只有成员变量，方法是不放在实例对象里面的，方法一份就够了，放在类对象的方法列表里面



==================================================================================

