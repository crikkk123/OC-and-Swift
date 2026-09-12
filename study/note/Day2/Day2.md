# Day2

~~~objc
#import <Foundation/Foundation.h>
#import <malloc/malloc.h>
#import <objc/runtime.h>


struct NSObject_IMPL {
    Class isa;
};

struct Person_IMPL {
    struct NSObject_IMPL NSObject_IVARS; // 8
    int _age;       // 4
    int _height;    // 4
    int _no;    // 4
};


@interface Person : NSObject
{
    int _age;
    int _height;
    int _no;
}
@end

@implementation Person
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* per = [[Person alloc] init];
        
        NSLog(@"%zd",sizeof(struct Person_IMPL));  // 24
        
        NSLog(@"%zd %zd",class_getInstanceSize([Person class]), malloc_size((__bridge const void *)(per))); //24 32
        
    }
    return EXIT_SUCCESS;
}
~~~



~~~objc
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

static inline id
malloc_instance(size_t size, Class cls __unused)
{
#if _MALLOC_TYPE_ENABLED
    malloc_type_descriptor_t desc = {};
    desc.summary.type_kind = MALLOC_TYPE_KIND_OBJC;
    return (id)malloc_type_calloc(1, size, desc.type_id);
#else
    return (id)calloc(1, size);
#endif
}

} // namespace objc

#endif // _OBJC_MALLOC_INSTANCE_H
~~~

size = cls->instanceSize(extraBytes);，这里传进来的值是 24，系统分配 32

~~~objc
void *
calloc(size_t num_items, size_t size)
{
	return _malloc_zone_calloc(default_zone, num_items, size, MZ_POSIX);
}

void *
_malloc_zone_calloc(malloc_zone_t *zone, size_t num_items, size_t size,
		malloc_zone_options_t mzo)
{
	if (zone == default_zone && !lite_zone) {
		// Eagerly resolve the virtual default zone to make the zone version
		// check accurate
		zone = malloc_zones[0];
	}

	if (os_unlikely(malloc_slowpath || _malloc_has_logger() || zone->version < 13)) {
		return _malloc_zone_calloc_instrumented_or_legacy(zone, num_items, size, mzo);
	}

	if (zone->version >= 16) {
		return zone->malloc_type_calloc(zone, num_items, size,
				malloc_callsite_fallback_type_id());
	}

	// zone versions >= 13 set errno on failure so we can tail-call
	return zone->calloc(zone, num_items, size);
}
~~~

操作系统给的内存对齐，与结构体内存对齐不同

堆空间有个 buckets，iOS 堆空间中想创建一个对象操作系统给的内存都是 16 的倍数，这样对操作系统/CPU 访问最快

~~~objc
#define NANO_MAX_SIZE			256 /* Buckets sized {16, 32, 48, ..., 256} */
~~~



其他实例：

~~~objc
#import <Foundation/Foundation.h>
#import <malloc/malloc.h>
#import <objc/runtime.h>


struct NSObject_IMPL {
    Class isa;
};

struct Person_IMPL {
    struct NSObject_IMPL NSObject_IVARS; // 8
    int _age;       // 4
    int _height;    // 4
    int _no;    // 4
};


@interface Person : NSObject
{
    int _age;
    int _height;
    int _no;
}
@end

@implementation Person
@end


struct Student_IMPL {
    struct NSObject_IMPL NSObject_IVARS; // 8
    int _age;       // 4
    int _height;    // 4
    int _no;
    int _width;
    int _work;
    int _hours;
    int _day;
};


@interface Student : NSObject
{
    int _age;
    int _height;
    int _no;
    int _width;
    int _work;
    int _hours;
    int _day;
}
@end

@implementation Student
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person* per = [[Person alloc] init];
        NSLog(@"%zd",sizeof(struct Person_IMPL));  // 24
        NSLog(@"%zd %zd",class_getInstanceSize([Person class]), malloc_size((__bridge const void *)(per))); //24 32
        
        
        Student* stu = [[Student alloc] init];
        NSLog(@"%zd",sizeof(struct Student_IMPL));  // 40
        NSLog(@"%zd %zd",class_getInstanceSize([Student class]), malloc_size((__bridge const void *)(stu))); //40 48
        
    }
    return EXIT_SUCCESS;
}

~~~



```创建一个实例对象，至少需要多少内存？```

~~~text
#import <objc/runtime.h>
class_getInstanceSize([NSObject class]);
~~~

```创建一个实例对象，实际上分配了多少内存？```

~~~text
#import <malloc/malloc.h>
malloc_size((__bridge const void *)obj);
~~~
