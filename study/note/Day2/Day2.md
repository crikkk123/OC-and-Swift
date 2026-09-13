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


## OC对象的分类

Objective-C中的对象，简称OC对象，主要可以分为3种

instance对象（实例对象）

class对象（类对象）

meta-class对象（元类对象） 

### instance

instance对象就是通过类alloc出来的对象，每次调用alloc都会产生新的instance对象
<img width="942" height="130" alt="image" src="https://github.com/user-attachments/assets/ec5309af-8878-4df2-b665-ee78e593ca48" />
object1、object2是NSObject的instance对象（实例对象）

它们是不同的两个对象，分别占据着两块不同的内存

instance对象在内存中存储的信息包括

isa指针

其他成员变量



### class

class对象在内存中存储的信息主要包括

isa指针

superclass指针

类的属性信息（@property）

类的对象方法信息（instance method）

类的协议信息（protocol）

类的成员变量信息（ivar）（名字、类型）

~~~objc
- (void) test;
~~~

这种方法放到类对象里面

<img width="486" height="816" alt="image" src="https://github.com/user-attachments/assets/bb202045-ca1c-40fb-a648-6ed22f128c7b" />

### meta-class

~~~objc
// 将类对象当做参数传入，获得元类对象
Class objectMetaClass = object_getClass([NSObject class]); // runtime API
// 是否是元类对象
class_isMetaClass(objectMetaClass);

object_getClass 里面要传入类对象才能获得元类对象
否则传入的是实例对象，返回的是类对象
  
Class objectMetaClass = [[NSObject class] class];
这里不管调用多少次 class 都是类对象，元类只能通过object_getClass传入类对象获得
~~~

这种类方法放到元类对象里面

~~~Objc
+ (void) test;
~~~



objectMetaClass是NSObject的meta-class对象（元类对象）

每个类在内存中有且只有一个meta-class对象

meta-class对象和class对象的内存结构是一样的，但是用途不一样，在内存中存储的信息主要包括

isa指针

superclass指针

类的类方法信息（class method）

![image-20260913133032812](/Users/yuan/Library/Application Support/typora-user-images/image-20260913133032812.png)
![image-20260913133150951](/Users/yuan/Library/Application Support/typora-user-images/image-20260913133150951.png)

```objc_getClass```
Class objc_getClass(const char *aClassName)
{
    if (!aClassName) return Nil;

    // NO unconnected, YES class handler
    return look_up_class(aClassName, NO, YES);
}


look_up_class
Class
look_up_class(const char *name,
              bool includeUnconnected __attribute__((unused)),
              bool includeClassHandler __attribute__((unused)))
{
    if (!name) return nil;

    Class result;
    bool unrealized;
    {
        runtimeLock.lock();
        result = getClassExceptSomeSwift(name);
        unrealized = result  &&  !result->isRealized();
        if (unrealized) {
            result = realizeClassMaybeSwiftAndUnlock(result, runtimeLock);
            // runtimeLock is now unlocked
        } else {
            runtimeLock.unlock();
        }
    }

    if (!result) {
        // Ask Swift about its un-instantiated classes.

        // We use thread-local storage to prevent infinite recursion
        // if the hook function provokes another lookup of the same name
        // (for example, if the hook calls objc_allocateClassPair)

        auto *tls = _objc_fetch_pthread_data(true);

        // Stop if this thread is already looking up this name.
        for (unsigned i = 0; i < tls->classNameLookupsUsed; i++) {
            if (0 == strcmp(name, tls->classNameLookups[i])) {
                return nil;
            }
        }

        // Save this lookup in tls.
        if (tls->classNameLookupsUsed == tls->classNameLookupsAllocated) {
            tls->classNameLookupsAllocated =
                (tls->classNameLookupsAllocated * 2 ?: 1);
            size_t size = tls->classNameLookupsAllocated *
                sizeof(tls->classNameLookups[0]);
            tls->classNameLookups = (const char **)
                realloc(tls->classNameLookups, size);
        }
        tls->classNameLookups[tls->classNameLookupsUsed++] = name;

        // Call the hook.
        Class swiftcls = nil;
        if (GetClassHook.get()(name, &swiftcls)) {
            ASSERT(swiftcls->isRealized());
            result = swiftcls;
        }

        // Erase the name from tls.
        unsigned slot = --tls->classNameLookupsUsed;
        ASSERT(slot >= 0  &&  slot < tls->classNameLookupsAllocated);
        ASSERT(name == tls->classNameLookups[slot]);
        tls->classNameLookups[slot] = nil;
    }

    return result;
}


getClassExceptSomeSwift
static Class getClassExceptSomeSwift(const char *name)
{
    lockdebug::assert_locked(&runtimeLock.get());

    // Try name as-is
    Class result = getClass_impl(name);
    if (result) return result;

    // Try Swift-mangled equivalent of the given name.
    if (char *swName = copySwiftV1MangledName(name)) {
        result = getClass_impl(swName);
        free(swName);
        return result;
    }

    return nil;
}


getClass_impl
static Class getClass_impl(const char *name)
{
    lockdebug::assert_locked(&runtimeLock.get());

    // allocated in _read_images
    ASSERT(gdb_objc_realized_classes);

    // Try runtime-allocated table
    if (Class cls = getClassFromNamedClassTable(name))
        return cls;

    // Try table from dyld shared cache.
    // Note we do this last to handle the case where we dlopen'ed a shared cache
    // dylib with duplicates of classes already present in the main executable.
    // In that case, we put the class from the main executable in
    // gdb_objc_realized_classes and want to check that before considering any
    // newly loaded shared cache binaries.
    return getPreoptimizedClass(name);
}


getClassFromNamedClassTable
static Class getClassFromNamedClassTable(const char *name) {
    unsigned hash = namedClassTableHash(name);
    void *result = (Class)NXMapGetWithHash(gdb_objc_realized_classes, name, hash);
    if (!result)
        return nullptr;

    return (Class)ptrauth_auth_data(result, namedClassTablePtrauthKey, namedClassTableDiscriminator(hash));
}


NXMapGetWithHash
void *NXMapGetWithHash(NXMapTable *table, const void *key, unsigned hash) {
    void	*value;
    return (_NXMapMemberWithHash(table, key, hash, &value) != NX_MAPNOTAKEY) ? value : NULL;
}


注：传入一个字符串的类名，返回类对象

```object_getClass```

Class object_getClass(id obj)
{
		// obj如果是 instance 对象，返回 class 对象
		// obj 如果是 class 对象，返回 meta-class 对象
		// objc 如果是 meta-class 对象，返回 NSObject（基类）的 meta-class 对象
    if (obj) return obj->getIsa();
    else return Nil;
}
