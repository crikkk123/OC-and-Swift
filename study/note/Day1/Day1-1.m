#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>


@interface NSObject {
     Class isa;  // Class 为指针
}
@end
typedef struct objc_class *Class


struct NSObject_IMPL {
    Class isa;
};

int main(int argc,const char * argv[]) {
    @autoreleasepool {
        NSObject *obj = [[NSObject alloc] init]; 

        // 获得NSObject类的实例对象的大小
        NSLog(@"%zd",class_getInstanceSize([NSObject class]));  // 8


        // 获得obj指针所指向内存的大小
        NSLog(@"%zd", malloc_size((__bridge const void *)obj));  // 16
    }
    return 0;
}
