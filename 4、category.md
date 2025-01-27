## OC代码转换为CPP代码的命令
  xrun -sdk iphoneos clang -arch arm64 -rewrite-objc OC源文件 -o 输出的CPP文件  链接其他的（-framework UIKit）

  clang -rewrite-objc main.m -o main.cpp


category实际上是在运行的时候，利用runtime讲方法合并到类对象或者元类对象中，在调用方法也就是objc_msgSend的时候，通过isa找到类对象或者元类对象进行调用

category的底层数据结构

<img width="771" alt="image" src="https://github.com/user-attachments/assets/09c4cfa3-7016-461b-8d7b-2770c5ec2be8" />


~~~objective-c
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TempPerson : NSObject

- (void)run;

@end

NS_ASSUME_NONNULL_END

#import "TempPerson.h"

@implementation TempPerson

-(void)run{
    NSLog(@"run");
}

@end


#import "TempPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface TempPerson (play)

-(void)play;

@end

NS_ASSUME_NONNULL_END

#import "Person+play.h"

@implementation TempPerson (play)

-(void)play{
    NSLog(@"play");
}

@end
~~~

转换为cpp代码
~~~cpp

struct _category_t {
	const char *name;
	struct _class_t *cls;
	const struct _method_list_t *instance_methods;
	const struct _method_list_t *class_methods;
	const struct _protocol_list_t *protocols;
	const struct _prop_list_t *properties;
};



static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[1];
} _OBJC_$_CATEGORY_INSTANCE_METHODS_TempPerson_$_play __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	1,
	{{(struct objc_selector *)"play", "v16@0:8", (void *)_I_TempPerson_play_play}}
};
static struct _category_t _OBJC_$_CATEGORY_TempPerson_$_play __attribute__ ((used, section ("__DATA,__objc_const"))) = 
{
	"TempPerson",
	0, // &OBJC_CLASS_$_TempPerson,
	(const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_TempPerson_$_play,
	0,
	0,
	0,
};
static void OBJC_CATEGORY_SETUP_$_TempPerson_$_play(void ) {
	_OBJC_$_CATEGORY_TempPerson_$_play.cls = &OBJC_CLASS_$_TempPerson;
}
~~~

category的底层是将原来的方法向后移动，并且将分类的方法放到前面，后参与编译的分类优先调用，也就是放到二维数组的前面

分类与扩展的区别：
扩展实际就是将原来写到.h文件中的属性或者方法私有化，写到.m文件中，在编译的时候实际已经在底层的class_rw_t的结构体当中，而分类是在运行的时候利用runtime合并到class_rw_t的结构体中，底层原来的大小比如为a，分类的总体大小为b，通过申请a+b的大小空间，并且将数组中第一个的位置向后偏移b个位置，并且在遍历分类的时候，是从后往前遍历的，合并的时候是合并到数组的前方，这也就说明了为什么后编译的分类的方法优先调用



## +load方法
+load方法会在runtime加载类、分类时调用，每个类、分类的+load方法在程序运行的过程中只调用一次，底层是先调用类的load方法，然后再去调用分类的load方法


调用时机：+load方法会在Runtime加载类对象(class)和分类(category)的时候调用

调用频率： 每个类对象、分类的+load方法，在工程的整个生命周期中只调用一次

调用顺序：

1、先调用类对象(class)的+load方法：
~~~text
类对象的load调用顺序是按照  类文件的编译顺序  进行先后调用；

调用子类+load之前会先调用父类的+load方法
~~~

2、再调用分类(category)的+load方法：按照编译先后顺序调用（先编译的，先被调用）

+load方法是在程序一启动运行，加载镜像中的类对象(class)和分类(category)的时候就会调用，只会调用一次，不论在项目中有没有用到该类对象或者该分类，他们统统都会先被加载进内存，因为类的加载只有一次，所以所有的load方法肯定都会被调用而且只有一次


load方法会调用自己的父类，然后调用自己的分类，如果不是继承关系则跟编译顺序有关，并且如果先调用父类的load方法，再调用自己的时候就不调用父类的load方法了，因为load方法只调用一次

~~~objective-c
main.m
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
    }
    return 0;
}

--------------------------------------------
person.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@end

NS_ASSUME_NONNULL_END

person.m
#import "Person.h"

@implementation Person

+(void)load{
    NSLog(@"Person load ");
}

@end

--------------------------------------------
person(Eat).h
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (Eat)

@end

NS_ASSUME_NONNULL_END

person(Eat).m
#import "Person+Eat.h"

@implementation Person (Eat)

+(void)load{
    NSLog(@"Person(Eat) load ");
}

@end


--------------------------------------------
person(test).h
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (Test)

@end

NS_ASSUME_NONNULL_END

person(test).m
#import "Person+Test.h"

@implementation Person (Test)

+(void)load{
    NSLog(@"Person(Test) load ");
}

@end


--------------------------------------------
student.h
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student : Person

@end

NS_ASSUME_NONNULL_END



student.m
#import "Student.h"

@implementation Student

+ (void)load{
    NSLog(@"Student load ");
}

@end

--------------------------------------------
student(play).h
#import "Student.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student (play)

@end

NS_ASSUME_NONNULL_END

student(play).m
#import "Student+play.h"

@implementation Student (play)

+ (void)load{
    NSLog(@"Student(play) load ");
}

@end
~~~

编译顺序：

<img width="736" alt="image" src="https://github.com/user-attachments/assets/4ec6b2a5-682b-49ec-9d4c-1b9074c2a90d" />

结果：

<img width="455" alt="image" src="https://github.com/user-attachments/assets/92eb09b9-6ec7-43a8-8a6b-fbf96e4c0cce" />


更换编译顺序：

<img width="269" alt="image" src="https://github.com/user-attachments/assets/9a7adb6b-36ed-4388-a6be-8c83e1fafe0a" />

结果：

<img width="486" alt="image" src="https://github.com/user-attachments/assets/399ef288-0e16-4fb3-a231-e143d52e522d" />







## +initialize

+initialize方法会在类第一次接收到消息时调用，有继承关系的时候先调用父类的initialize方法


如果子类没有实现+initialize，会调用父类的+initialize（所以父类的+initialize可能会被调用多次）

如果分类实现了initialize，就覆盖类本身的+initialize调用

+initialize和+load的很大区别是，+initialize是通过objc_msgSend进行调用的，+load方法是通过函数地址调用的

load：先调用类的load然后是先编译的类先调用，调用子类的load之前会调用父类的load

      然后是分类的load，先编译的分类先调用


initialize：先初始化父类，再初始化子类



把上面的load方法统一换成initialize
~~~objective-c
main.m
#import <Foundation/Foundation.h>
#import "Person.h"
#import "Student.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [Person alloc];
    }
    return 0;
}
~~~
结果：

<img width="364" alt="image" src="https://github.com/user-attachments/assets/5fea3ae4-3fce-4e13-8b42-163d740cd3b6" />

这个结果跟编译顺序有关，编译顺序截图：

<img width="299" alt="image" src="https://github.com/user-attachments/assets/d9c02f40-36df-4a1b-8433-8194d9c37928" />

因为category是把自己的实现向后偏移，前面是分类的实现，又因为是从后遍历分类插入到method的前面，所以后编译的分类，先调用，如果这个分类没有实现这个方法，会找其他分类，如果也没有再找自己的实现，如果都没有回通过isa向上找，这个位置就不详细介绍了，在其他文章有介绍



~~~objective-c
main.m
#import <Foundation/Foundation.h>
#import "Person.h"
#import "Student.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [Student alloc];
    }
    return 0;
}
~~~

结果：

<img width="369" alt="image" src="https://github.com/user-attachments/assets/3fc1b77d-6584-46bf-84c0-e68ac4b0f478" />

因为调用自己的分类的时候，会调用父类的分类，上面介绍了，然后调用自己最好编译的分类


将上面所有分类的initialize方法都注释掉，只留Person类的initialize，并新增一个类继承Person
~~~objective-c
teacher.h
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Teacher : Person

@end

teacher.m
#import "Teacher.h"

@implementation Teacher

@end

main.m
#import <Foundation/Foundation.h>
#import "Person.h"
#import "Student.h"
#import "Teacher.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [Student alloc];
        [Teacher alloc];
    }
    return 0;
}
~~~

结果：

<img width="346" alt="image" src="https://github.com/user-attachments/assets/b65042bb-c0ff-4b5c-82a9-98dc06304819" />


原因：因为initialize是通过msgSend消息机制调用的，所以都没有实现initialize会最终到调用到父类的也就是Person类的方法，三次的原因是第一次调用[Student alloc] 的方法的时候，会先判断自己没有初始化，父类也没有初始化，调用父类的initialize方法，然后调用自己的方法，但是自己没有实现，又调用Person的方法，然后调用[Teacher alloc] 判断自己没有被初始化过，但是他的父类初始化了，所以这步比上步少了调用父类的initialize方法，接下来调用自己的initialize方法，但是自己没有实现，又调用到Person父类的initialize方法，最终是三次



## 关联对象
~~~objective-c
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (Test)

@property(nonatomic,assign) int age;

- (void)setAge:(int)age;
- (int)age;

@end

NS_ASSUME_NONNULL_END
~~~

如果在分类里面@property(nonatomic,assign) int age;声明一个变量，分类只会声明get和set方法，具体的实现是不会做的，而正常的类是会帮我们实现的

不能直接给category添加成员变量，可以间接添加


---------------------------------------------------
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
