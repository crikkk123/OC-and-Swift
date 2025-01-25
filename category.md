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
