# OC学习笔记

# 一、基本数据类型

##    1、NSNumber

### 基本用法

```objective-c
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSNumber *number = [[NSNumber alloc] initWithInt:20];
        NSNumber* num1 = @42;
        NSNumber* num2 = [NSNumber numberWithInt:100];
        NSNumber* num3 = [NSNumber numberWithLong:100L];
        NSNumber* num4 = [NSNumber numberWithFloat:1.1];
        NSNumber* num5 = [NSNumber numberWithBool:YES];
        
        NSNumber* num6 = @([@"42" intValue]);   // "42" -> 42
        
        NSLog(@"hello world");
        
        NSString* str1 = @"abc";
        NSLog(@"str1: %@",str1);
        
        NSLog(@"1number: %d",[number intValue]);
        NSLog(@"2number: %@",number);
        
        NSLog(@"num1: %d",[num1 intValue]);
        NSLog(@"nums4: %f",[num4 floatValue]);
        
        NSLog(@"nums5: %d",[num5 boolValue]);
    }
    return 0;
}
```

## 2、NSLog

### 基本用法

```objective-c
 #import<Foundation/Foundation.h>


int main(){
    @autoreleasepool {
        NSString* str = [ [NSString alloc] initWithString:@"helloworld"];
        NSLog(str);
        NSString* str1 = @"hello str1";
        NSLog(@"%@",str1);
        
        int num = 30;
        NSLog(@"num = %d",num);
        
        float f = 5.6;
        NSLog(@"f: %.1f",f);
        
        NSLog(@"num = %d f = %.1f",num,f);
        
        BOOL b = YES;
        NSLog(@"b = %@", b ? @"YES":@"NO");
        
        NSArray* arr = @[@"abc",@"def",@123];
        NSLog(@"arr: %@",arr);
        
        NSDictionary* dir = @{@"name":@"zhangsan",@"age":@18};
        NSLog(@"dir: %@",dir);
    }
}

```

## 3、@

### @符号的作用

```objective-c
#import <Foundation/Foundation.h>

// 5、类的声明
@interface MyClass : NSObject
@end

// 6、协议的声明
@protocol MyProtocol
@end

// 7、宏定义
#define PORT 8000

// @的用法
int main(){
    NSString* str = @"hello world";   // 1、字符串常量
    NSLog(str);
    
    NSArray* arr = @[@"hello",@1234,@"world"];  // 2、数组
    NSLog(@"%@",arr);
    
    NSDictionary* dir = @{@"name":@"lisi",@"sex":@"1"};  // 3、字典
    NSLog(@"%@",dir);
    
    NSNumber* num = @(42);   // 4、NSNumber字面量
    NSLog(@"%@",num);
    
    
    return 0;
}
```

## 4、NSString

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

int main(int argc,const char* argv[]){
    NSString* str1 = [[NSString alloc] initWithFormat:@"hello world"];
    NSLog(@"%@",str1);
    
    NSString* str2 = @"hello object-c";
    NSLog(@"%@",str2);
    
    // str3 后面不能加%d，只有format的可以
    NSString* str3 = [NSString stringWithString:@"abc"];
    NSLog(@"%@",str3);
    
    NSString* str4 = [NSString stringWithFormat:@"str4: %d",42];
    NSLog(@"%@",str4);
    
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfFile:@"path/to/file.txt" encoding:NSUTF8StringEncoding error:&error];
    
    
    return 0;
}
~~~

### NSString函数

~~~objective-c
#import <Foundation/Foundation.h>

int main(int argc,const char* argv[]){
    @autoreleasepool {
        NSString* str1 = [[NSString alloc] initWithFormat:@"hello world"];

        NSUInteger len = [str1 length];     // 1、长度
        NSLog(@"len(str3) : %lu",len);
        
        // 2、拼接
        NSString* str2 = [str1 stringByAppendingFormat:@" object %c",'c'];
        NSLog(@"%@",str2);
        
        // 3、插入字符串。  （2，3），从下标2开始替换3个
        NSString* str3 = [str1 stringByReplacingCharactersInRange:NSMakeRange(2,3) withString:@"NSSTRING"];
        NSLog(@"%@",str3);
        
        // 4、判断两个字符串是否相等
        BOOL bl = [str1 isEqualToString:(str2)];
        NSLog(@"bl : %@",bl?@"YES":@"NO");
        
        // 5、查找两个字符串
        NSRange range = [str1 rangeOfString:@"llo"];
        NSLog(@"%lu",range);
        
        NSArray* arr = @[@"hello",@"world",@123,@YES,@{@"name":@"zhangsan"}];
        NSLog(@"%@",arr);
        NSLog(@"%d",[arr[3] boolValue]);
        
        // 6、截取字符串
        NSString* str4 = [str1 substringWithRange:NSMakeRange(2,8)];
        NSLog(@"%@",str4);
        
        // 7、转换大小写
        NSString* str5 = [str1 uppercaseString];
        NSLog(@"%@",str5);
        NSString* str6 = [str1 lowercaseString];
        NSLog(@"%@",str6);
        
        // 8、去除最前面和后面空格
        NSString* str7 = [str1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"%@",str7);
        
        // 去除中间的空格
        NSString* str8 = [str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"%@",str8);
        
        // 9、是否包含某个字符串
        BOOL bl1 = [str1 containsString:@"a"];
        NSLog(@"bl1 : %@",bl1?@"YES":@"NO");
        
        // 10、检查是否以某个前缀或后缀开头/结尾
        BOOL bl2 = [str1 hasPrefix:@"h"];
        NSLog(@"bl2 : %@",bl2?@"YES":@"NO");
        
        BOOL bl3 = [str1 hasSuffix:@"or"];
        NSLog(@"bl3 : %@",bl3?@"YES":@"NO");
        
        // 11、转换为NSNumber
        NSNumber* num1 = @((int)([@"a" characterAtIndex:0]));
        NSLog(@"%d",[num1 intValue]);
        
        
        // 删除特殊的字符集
        NSString* str = @"----Interactive Tutorials---";
        NSCharacterSet* charset = [NSCharacterSet punctuationCharacterSet];
        str = [str stringByTrimmingCharactersInSet:charset];
        NSLog(@"str: %@",str);
        
        NSMutableString* mutstr = [NSMutableString stringWithCapacity:40];
        NSMutableString* mutstr2 = [[NSMutableString alloc] initWithString:@"this is "];
        [mutstr2 appendString:@" NSMutableString!!! "];
        [mutstr2 insertString:@" asd " atIndex:2];
        NSLog(@"%@",mutstr2);
        
        [mutstr2 deleteCharactersInRange:NSMakeRange(0, 10)];
        NSLog(@"%@",mutstr2);
        
        [mutstr2 setString:@"clear"];
        NSLog(@"%@",mutstr2);
    }
    return 0;
}

~~~

## 5、NSDate

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

int main(int argc,const char* argv[]){
    @autoreleasepool {
        // 1、获取现在的时间
        NSDate* curdate = [NSDate date];
        NSLog(@"%@",curdate);
        
        // 2、获取curdate时间3600秒后的时间
        NSDate* date1 = [NSDate dateWithTimeInterval:3600 sinceDate:curdate];
        NSLog(@"%@",date1);
        
        // 3、获取当前时间的3600秒前的时间
        NSDate* date2 = [NSDate dateWithTimeIntervalSinceNow:-3600];
        NSLog(@"%@",date2);
        
        
        // 4、获取1970年到现在的秒数
        NSLog(@"timeIntervalSince1970 = %f",[curdate timeIntervalSince1970]);
        
        // 5、date2时间到curdate时间的秒数
        NSLog(@"timeIntervalSinceDate = %f",[curdate timeIntervalSinceDate:date2]);
        
        // 6、date1时间减去curdate时间
        NSLog(@"timeIntervalSinceDate = %f",[date1 timeIntervalSinceDate:curdate]);
        
        // 7、判断两个日期是否相同
        NSLog(@"isEqualToDate = %d",[curdate isEqualToDate: date1]);
        
        // 8、判断a日期是否晚于b日期
        NSLog(@"isGreaterThan = %d",[curdate isGreaterThan: date2]);
        
        // 9、判断curdate是否早于或等于date1日期
        NSLog(@"isLessThanOrEqualTo = %d",[curdate isLessThanOrEqualTo:date1]);
        
        // 10、判断curdate 和 date1 关系 <(-1)  ==(0) >(1)
        NSComparisonResult com = [curdate compare: date1];
        NSLog(@"res = %d",(long)com);
        
        // 11、格式化字符串
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-CN"]];
        NSString* currentDateString = [formatter stringFromDate:curdate];
        NSLog(@"%@",currentDateString);
        
        NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate* date = [NSDate date];
        NSLog(@"Date string: %@",[formatter2 stringFromDate:date]);
        
        NSString* dateString = @"2019-03-26 12:21:20";
        NSDateFormatter* formatter3 = [[NSDateFormatter alloc] init];
        NSDate* con = [formatter3 dateFromString:dateString];
        NSLog(@"con = %@",con);
    }
    return 0;
}

~~~

## 6、NSURL网址类

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

int main(int argc,const char* argv[]){
    @autoreleasepool {
        NSURL* baseURL = [NSURL URLWithString:@"file://usr//lib"];
        NSURL* fileURL = [NSURL URLWithString:@"root//index.html" relativeToURL:baseURL];
        NSURL* absURL = [fileURL absoluteURL];
        NSLog(@"绝对路径 = %@",absURL);
        
        NSURL* url = [NSURL URLWithString:@"http://www.baidu.com:8080//tut//filter.html?title=interactive_tur&category=ios"];
        
        // 协议（http/https）
        NSLog(@"Scheme: %@",[url scheme]);
        // 后面的
        NSLog(@"Resource: %@",[url resourceSpecifier]);
        // 域名
        NSLog(@"Host = %@",[url host]);
        // 端口
        NSLog(@"Port = %@",[url port]);
        // 网址域名之后的路径
        NSLog(@"Path = %@",[url path]);
        // 网址域名之后路径的各个部位
        NSLog(@"Path components as array: %@",[url pathComponents]);
        // 网址里的请求参数
        NSLog(@"Query = %@",[url query]);
        // 网址里的参数字符串
        NSLog(@"Parameter string %@",[url parameterString]);
        
    }
}

~~~

## 7、数组

### 基本用法

NSArray创建的也是不可变的对象，一旦创建就不能被修改，   可变数组：NSMutableArray

~~~objective-c
#import <Foundation/Foundation.h>

int main(int args,const char* argv[]){
    @autoreleasepool {
        // 静态的数组存储基础类型
        int nums[10] = {1,2,3};
        for(int i=0;i<sizeof(nums)/sizeof(nums[0]);i++){
            NSLog(@"%d ",nums[i]);
        }
        
        // nil 是数组结束的标记(无法将nil保存到数组中)。只能存储oc对象，不能直接存储C语言的基础类型（需要包装成对象）
        NSArray *array = [[NSArray alloc] initWithObjects:@"Apple",@"Banana",@"Pear",nil];
        NSLog(@"%@",array);
        // 两种数组初始化的方式
        NSArray* fruit = [NSArray arrayWithObjects:@"Apple",@"Banana",@"Pear", nil];
        NSLog(@"%@",fruit);
        
        // 有alloc说明是通过fruit数组初始化另一个数组（深拷贝）。（赋值运算符）
        NSArray* fruit1 = [[NSArray alloc] initWithArray:fruit];
        NSLog(@"%@",fruit1);
        
        // 用一个数组去创建另一个数组（拷贝构造）
        NSArray* fruit2 = [NSArray arrayWithArray:fruit];
        NSLog(@"%@",fruit1);
        
        // 在数组fruit的后面插入一个元素赋值给新的变量
        NSArray* fruit3 = [fruit arrayByAddingObject:@"hello world"];
        NSLog(@"%@",fruit3);
        
        // 截取范围
        NSArray* fruit4 = [fruit subarrayWithRange:NSMakeRange(1, 2)];
        NSLog(@"%@",fruit4);
        
        // 初始化数组打印长度
        NSArray* fruit5 = @[@"helloworld",@"object-c",@"swift"];
        // 取下标为1的元素
        NSLog(@"%@ %d %@",fruit5,[fruit5 count],[fruit5 objectAtIndex:1]);
        // 第一个、最后一个、是否包含某个元素
        NSLog(@"%@ %@ %d",[fruit5 firstObject],[fruit5 lastObject],[fruit5 containsObject:@"Pear"]);
        // 找不到返回NSNotFound（最大值9223...5807）
        NSLog(@"%ld",[fruit5 indexOfObject:@"a"]);
        
        // 打印数组
        for(int i=0;i<[fruit5 count];i++){
            NSLog(@"%d : %@ ",i,fruit5[i]);
        }
        for(NSString* element in fruit5){
            NSLog(@"%@ ",element);
        }
        // 获得fruit5对象的一个枚举器
        NSEnumerator* e = [fruit5 objectEnumerator];
        // id类型的变量，可以转换为任意类型的对象，存储任何数据类型的对象，本质上一个指向这种对象的实例变量的指针
        id enumerator;
        while(enumerator = [e nextObject]){
            NSLog(@"%@ ",enumerator);
        }
        // 枚举和闭包相结合遍历数组
        [fruit5 enumerateObjectsUsingBlock:^(id str,NSUInteger index,BOOL* te){
            NSLog(@"%@,%lu",str,(unsigned long)index);
        }];
        // 设置枚举遍历的顺序，下面上从最后打印到头
        [fruit5 enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id str,NSUInteger index,BOOL* te) {
            NSLog(@"%@,%lu",str,(unsigned long)index);
        }];
        
        // 将字符串转换为数组
        NSString* str = @"dog,pig,cat";
        NSArray* arrstr = [str componentsSeparatedByString:@","];
        NSLog(@"%@ ",arrstr);
        // 数组转换为字符串
        NSString* str1 = [arrstr componentsJoinedByString:@" > "];
        NSLog(@"%@ ",str1);
    }
}

~~~

### 可变数组NSMutableArray

```objective-c
#import <Foundation/Foundation.h>

int main(int args,const char* argv[]){
    @autoreleasepool {
        NSMutableArray* fruit = [[NSMutableArray alloc] init];
        [fruit addObject:@"apple"];
        [fruit addObjectsFromArray:@[@"banana",@"helloworld"]];
        [fruit insertObject:@"Orange" atIndex:2];
        [fruit replaceObjectAtIndex:3 withObject:@"Grape"];
        
        NSLog(@"%@",fruit);
        
        // 在fruit基础上创建另一个数组
        NSMutableArray* fruit1 = [NSMutableArray arrayWithArray:fruit];
        NSLog(@"%@",fruit1);
        
        [fruit removeObject:@"Orange"];
        NSLog(@"%@",fruit);
        [fruit1 removeObjectAtIndex:0];
        [fruit1 removeLastObject];
        NSLog(@"%@",fruit1);      // fruit没有Orange，fruit1有Orange证明是深拷贝
        // 删除和另一个数组中相同的对象
        [fruit1 removeObjectsInArray:@[@"banana",@"object-c"]];
        NSLog(@"%@",fruit1);
        // 删除所有的对象
        [fruit1 removeAllObjects];
        NSLog(@"%@",fruit1);
        // 交换元素
        [fruit exchangeObjectAtIndex:0 withObjectAtIndex:2];
        NSLog(@"%@",fruit);
    }
}
```

### 数组的排序(包括NSString)

```objective-c
#import <Foundation/Foundation.h>

NSInteger sortInt(id num1,id num2,void* context){
    int number1 = [num1 intValue];
    int number2 = [num2 intValue];
    
    if(*(BOOL*)context == YES){     // 升序排列
        if(number1 > number2){
            // 如果第一个参数的值大于第二个参数的值，则返回一个表示降序排列的枚举值，该枚举值的数值是1
            return NSOrderedDescending;
        } else if(number1<number2){
            // 如果第一个参数的值小于第二个参数的值，则返回一个表示生序排列的枚举值，该枚举值的数值是-1
            return NSOrderedAscending;
        }else{
            // 如果两个参数的数值相等，则返回一个表示相等的枚举值，其值为0
            return NSOrderedSame;
        }
    }
    else{
        if(number1 > number2){
            return NSOrderedAscending;
        } else if(number1<number2){
            return NSOrderedDescending;
        } else{
            return NSOrderedSame;
        }
    }
}

NSInteger sortString(id str1,id str2,void* context){
    if(*(BOOL*)context == YES){     // 将序排列
        // 第二个和第一个比较，区分大小写，返回一个枚举值
        return [str2 localizedCaseInsensitiveCompare:str1];
    }
    // 对数组进行升序排列
    return [str1 localizedCaseInsensitiveCompare:str2];
}

int main(int args,const char* argv[]){
    @autoreleasepool {
        // 数字左侧的@符号表示一个NSNumber对象，中括号左侧的@符号表示一个NSArray对象
        NSArray* numbers = @[@4,@6,@8,@1,@15,@7,@9];
        BOOL orderedAscending = YES;
        // 给数组对象发送排序消息，并传递相应的参数，对数组进行生序排列
        NSArray* sortedNumbers = [numbers sortedArrayUsingFunction:sortInt context:&orderedAscending];
        NSLog(@"%@",sortedNumbers);
        
        
        // 排序字符串数组
        NSArray* companies = @[@"Microsoft",@"Facebook",@"Apple",@"IBM",@"Twitter"];
        BOOL orderedDescending = YES;
        NSArray* sortedString = [companies sortedArrayUsingFunction:sortString context:&orderedDescending];
        NSLog(@"%@",sortedString);
    }
}
```

## 8、NSDictionary

### 基本用法

```objective-c
#import <Foundation/Foundation.h>

int main(int argc,const char* argv[]){
    @autoreleasepool {
        // 数组是有序元素的集合，数组通过下标访问，字典通过指定的键获取对应的值  key:name  value:Kitty
        NSDictionary* cat = [NSDictionary dictionaryWithObject:@"Kitty" forKey:@"name"];
        NSLog(@"%@",cat);
        
        NSDictionary* dog = [NSDictionary dictionaryWithObjectsAndKeys:@"Teddy",@"name",@"2",@"age",@"10",@"weight",nil];
        NSLog(@"%@",dog);
        
        // 数组作为键和值 一一对应的
        NSArray* objects =[NSArray arrayWithObjects:@"Peter",@"Swimming",@"Tiger", nil];
        NSArray* keys = [NSArray arrayWithObjects:@"Name",@"Hobby",@"Pet", nil];
        NSDictionary* master = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        NSLog(@"%@",master);
        
        // 获得字典里的所有键
        NSArray* allkeys = [master allKeys];
        NSLog(@"%@",allkeys);
        
        // 获得字典里的所有值
        NSArray* allvalues = [master allValues];
        NSLog(@"%@",allvalues);
        
        // 键的个数
        unsigned long count = [master count];
        NSLog(@"%lu",count);
        
        // 根据键取值    键不存在返回 name = (null) 通过指定的键获得字典里的对象，objectForKey可以获得键对应的任意对象
        NSString* name = [master objectForKey:@"Nam"];
        NSLog(@"name = %@",name);
        // 通过指定的键，获得字典里对应的值，valueForKey用来获取键对应的字符串
        NSString* hobby = [master valueForKey:@"Hobby"];
        NSLog(@"hobby = %@",hobby);
        
        // 遍历
        for(id key in master){
            NSLog(@"master %@ = %@",key,[master objectForKey:key]);
        }
        NSEnumerator* item = [master keyEnumerator];
        id temp;
        while(temp = [item nextObject]){
            NSLog(@"%@",[master valueForKey:temp]);
        }
        // 通过闭包打印
        [master enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL* stop){
            NSLog(@"master.%@ = %@",key,obj);
        }];
        
        
        // 可变字典是字典的子类
        NSMutableDictionary* book = [NSMutableDictionary dictionaryWithObject:@"ios development Tutorials" forKey:@"Tittle"];
        [book setValue:@"Sandra Ciseneros" forKey:@"Author"];
        [book setValue:@"lisi" forKey:@"name"];
        NSLog(@"%@",book);
        
        [book removeObjectForKey:@"name"];
        NSLog(@"%@",book);
        [book removeObjectsForKeys:@[@"Tittle"]];
        NSLog(@"%@",book);
        [book removeAllObjects];
        NSLog(@"%@",book);
    }
    return 0;
}

```

## 9、NSSet

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

int main(int argc,const char* argv[]){
    @autoreleasepool {
        // NSSet建立在哈希表的基础上，通过哈希值查找集合里的元素，要比数组更快
        NSSet* ns = [[NSSet alloc] initWithObjects:@"Cat",@"Dog",@"Horse",@"Cat",@"Dog", nil];
        NSLog(@"%@",ns);
        // 获得任意一个元素
        NSLog(@"%@",[ns anyObject]);
        
        // 打印set中的数量
        NSUInteger cnt = [ns count];
        NSLog(@"%d",cnt);
        
        BOOL bl = [ns containsObject:@"cat"];
        NSLog(@"%d", bl?YES:NO);
        
        NSSet* st1 = [ns setByAddingObject:@[@"app",@"ios"]];
        NSLog(@"%@",st1);
        NSSet* st2 = [ns setByAddingObject:@"all"];
        NSLog(@"%@",st2);
        NSLog(@"%d", [ns isSubsetOfSet:st2]);   // 子集
        
        // 打印
        NSEnumerator* enumator = [ns objectEnumerator];
        id item;
        while(item =[enumator nextObject]){
            NSLog(@"ns : %@",item);
        }
        
        NSMutableSet* set1 = [[NSMutableSet alloc] initWithObjects:@"one",@"two",@"three", nil];
        NSMutableSet* set2 = [[NSMutableSet alloc] initWithObjects:@"two",@"three",@"four", nil];
        // 合并
        [set1 unionSet:set2];
        NSLog(@"set1 = %@",set1);
        // 交集
        [set1 intersectSet:set2];
        NSLog(@"%@",set1);
        // 从一个集合减去另一个集合的元素
        [set1 minusSet:set2];
        NSLog(@"%@",set1);
        // 移除某个元素
        [set1 removeObject:@"one"];
        NSLog(@"%@",set1);
        [set1 removeAllObjects];
        NSLog(@"%@",set1);
        
        // 将数组转换为set去重后再转换为数组
        NSMutableArray* array = [NSMutableArray arrayWithObjects:@"John",@"Peter",@"Jason",@"Kitty",@"Peter",@"John", nil];
        NSSet* set = [[NSSet alloc] initWithArray:array];
        array = [NSMutableArray arrayWithArray:[set allObjects]];
        NSLog(@"%@",array);
    }
    return 0;
}

~~~

## 10、指针

### 基本用法与C相同

## 11、property
~~~objective-c
    
~~~

# 二、结构体、类、闭包

## 1、#define

### 基本用法与C语言相同

## 2、typedef

~~~objective-c
#import <Foundation/Foundation.h>

typedef unsigned int UI;

typedef struct Animal{
    NSString* name;
    NSUInteger age;
} Animal;

int main(int argc,const char* argv[]){
    @autoreleasepool {
        UI a = 10;
        NSLog(@"%d",a);
        
        Animal ani;
        ani.name = @"zhangsan";
        ani.age=20;
        NSLog(@"%@",ani.name);
        NSLog(@"%d",ani.age);
    }
    return 0;
}

~~~

## 3、类

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

// @interface和@implementation 类的定义以关键字@interface开头，后面是接口的名称，冒号后面的名称是继承的父类，类的成员在括号后面
// NSObject父类是所有其他类的父类，提供了内存分配和初始化等基本方法
@interface Car : NSObject{
    NSString* brand;
    NSString* series;
    float price;
}

// 类里的成员是无法直接访问的，这里使用@property关键词，把原来的成员定义成属性，并自动生成属性的getter和setter方法，这些方法被隐藏了起来
@property(nonatomic,readwrite) float price;
// 使用这个@property修饰成员变量，其中nonatomic表示线程不安全的非原子性操作，copy表示在设置成员变量时采用拷贝的方式进行
@property(nonatomic,copy) NSString* series;
// 和结构体不同的是，类是可以定义方法的，前面的-号表示该方法为实例方法，如果使用+号，则是定义一个类的方法，该方法的返回值为空，类的定义以@end结尾
- (void) drive;
@end

// 类外
// 类相当于对象的蓝图，只描述而不实现，要实现类中描述的内容，需要使用@implementation关键词
@implementation Car

// @synthesize关键词是和@property关键词配合使用的，它会实现@property声明的getter和setter方法，这个关键词是可选的，即使没有这行代码，系统也会自动生成
// 一个带下划线的成员供外部读写
@synthesize price;
@synthesize series;

// 初始化方法，类被实例化时，自动调用该方法，对类的成员进行初始化
- (id) init{
    self = [super init];
    brand = @"BWM";
    series = @"X7";
    return self;
}

- (void) drive{
    NSLog(@"brand = %@,series = %@",brand,series);
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        Car* car = [[Car alloc] init];
        Car* car1 = [[Car alloc] init];
        
        car.price = 73900.0;
        
        // 这个成员变量没有暴露出来，无法通过点语法访问它
        // car1.series = @"X5";
        
        // 在类中设置好后可以访问该成员了
        car1.series = @"X5";
        car1.price = 60700.0;
        
        // 向两个对象发送drive消息，对象进行方法的调用，其实是一个消息发送的过程，由于oc语言采用的是动态绑定机制，所以要调用的方法需要运行时才能确定
        [car drive];
        [car1 drive];
    }
    return 0;
}

~~~

### 类的实例化方法

~~~objective-c
#import <Foundation/Foundation.h>

// 不需要访问类的成员属性就不用大括号了
@interface Math : NSObject
// 返回值。第一个参数为整型的number1，第二个参数时同样为整型的number2，andNumber2在此表示参数的签名，其作用是说明参数的含义
- (int) getBigger : (int)number1 andNumber2:(int)number2;
@end

@implementation Math

- (int) getBigger : (int)number1 andNumber2:(int)number2{
    int bigger = (number1>number2)?number1:number2;
    return bigger;
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        Math* mt = [[Math alloc] init];
        int result = [mt getBigger:10 andNumber2:12];
        NSLog(@"%d",result);
    }
    return 0;
}

~~~

### 类的非实例方法（主要区别是+号和-号）

~~~objective-c
#import <Foundation/Foundation.h>

@interface Math : NSObject
+ (int) getSmaller:(int)number1 andNumber2:(int)number2;
@end

@implementation Math

+ (int) getSmaller:(int)number1 andNumber2:(int)number2{
    int smaller = (number1<number2)?number1:number2;
    return smaller;
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        int smaller = [Math getSmaller:10 andNumber2:20];
        NSLog(@"%d",smaller);
    }
    return 0;
}
~~~

### 指针交换两个变量

~~~objective-c
#import <Foundation/Foundation.h>

@interface SwapNum : NSObject
+ (void) swap1:(int)number1 andNumber2:(int)number2;
+ (void) swap2:(int*)number1 andNumber2:(int*)number2;
@end

@implementation SwapNum

+ (void) swap1:(int)number1 andNumber2:(int)number2{
    int temp = number1;
    number1 = number2;
    number2 = temp;
}

+ (void) swap2:(int*)number1 andNumber2:(int*)number2{
    int temp = *number1;
    *number1 = *number2;
    *number2 = temp;
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        int num1 = 1;
        int num2 = 2;
        NSLog(@"num1 = %d num2 = %d",num1,num2);
        
        [SwapNum swap1:num1 andNumber2:num2];
        NSLog(@"num1 = %d num2 = %d",num1,num2);
        
        [SwapNum swap2:&num1 andNumber2:&num2];
        NSLog(@"num1 = %d num2 = %d",num1,num2);
    }
    return 0;
}
~~~

## 4、Block块(闭包)

### 基本用法、作为参数

~~~objective-c
#import <Foundation/Foundation.h>

// Block也称为闭包，定义一个将数据和相关行为相结合的功能块，是一个独立的任务单元
// 返回值为void，闭包的名称在向上箭头的后方，紧挨着的是闭包的参数，这里的参数也为空，括号里的是具体业务功能
void (^firstBlock)(void) = ^{
    NSLog(@"This is the first block.");
};

int (^getBigger)(int,int) = ^(int nums1,int nums2){
    int res = (nums1>nums2)?nums1:nums2;
    return res;
};

// 闭包可以作为参数
typedef void (^ResponseBlock)(NSString* response);
@interface RequestAPIClass : NSObject
- (void) requestAPIWithBlock:(NSString*)url andBlock:(ResponseBlock)completionBlock;
@end

@implementation RequestAPIClass

- (void) requestAPIWithBlock:(NSString*)url andBlock:(ResponseBlock)completionBlock{
    NSLog(@"Request %@...",url);
    
    NSString* response = @"A list of swift tutorials.";
    completionBlock(response);
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        firstBlock();
        NSLog(@"%d",getBigger(10,20));
        
        RequestAPIClass* res = [[RequestAPIClass alloc] init];
        [res requestAPIWithBlock:@"http://www.baidu.com" andBlock:^(NSString* response){
            NSLog(@"Response form server: %@",response);
        }];
    }
    return 0;
}
~~~

## 5、继承

### 基本用法

~~~objective-c
 #import <Foundation/Foundation.h>

@interface Animal : NSObject{
    NSString* name;
}
- (id) initWithName : (NSString*) name;
- (void) say;
@end

@implementation Animal

- (id) initWithName : (NSString*) animalName{
    name = animalName;
    return self;
}

- (void) say{
    NSLog(@"This is %@",name);
}

@end

@interface Tiger : Animal{
    float weight;
}
- (id) initWithName:(NSString *)name andWeight:(float)animalWeight;
- (void) hunt;
@end

@implementation Tiger

- (id) initWithName:(NSString *)animalName andWeight:(float)animalWeight{
    name = animalName;
    weight = animalWeight;
    return self;
}

- (void) hunt{
    NSLog(@"%@ is weigth: %lf",name,weight);
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        Animal* animal = [[Animal alloc] initWithName:@"Brain"];
        [animal say];
        
        Tiger* tiger = [[Tiger alloc] initWithName:@"laohu" andWeight:20.6];
        [tiger say];
        [tiger hunt];
    }
    return 0;
}
~~~

## 6、多态

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

@interface Animal : NSObject{
    NSString* name;
}
- (id)initWithName:(NSString*)animalName;
- (void)moveTo:(NSString*) destination;
@end

@implementation Animal

- (id)initWithName:(NSString*)animalName{
    name = animalName;
    return self;
}

- (void)moveTo:(NSString*) destination{
    NSLog(@"%@ move to %@",name,destination);
}
@end

@interface Tiger : Animal

- (void)moveTo:(NSString*) destination;
@end

@implementation Tiger
- (void)moveTo:(NSString*) destination{
    NSLog(@"%@ jump to %@",name,destination);
}
@end


@interface Brid : Animal
- (void)moveTo:(NSString*) destination;
@end

@implementation Brid
- (void)moveTo:(NSString*) destination{
    NSLog(@"%@ files to %@",name,destination);
}
@end


int main(int argc,const char* argv[]){
    @autoreleasepool {
        Tiger* tiger = [[Tiger alloc] initWithName:@"Will"];
        [tiger moveTo:@"the cave."];
        
        Brid* brid = [[Brid alloc] initWithName:@"Dove"];
        [brid moveTo:@"the nest."];
        
        NSArray* array = [[NSArray alloc] initWithObjects: tiger,brid,nil];
        id a = [array objectAtIndex:1];
        [a moveTo:@"its home."];
    }
    return 0;
}
~~~

## 7、封装

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

@interface Banker : NSObject{
    int counts;
}
- (id) initWithNumber:(int) num;
- (void) addnumber : (int) num;
- (void) subnumber : (int) num;
- (NSString*) getTotalcnts:(NSString*)password;
@end

@implementation Banker

- (id) initWithNumber:(int) num{
    counts = num;
    return self;
}

- (void) addnumber : (int) num{
    counts += num;
}

- (void) subnumber : (int) num{
    counts -= num;
}

- (NSString*) getTotalcnts:(NSString*)password{
    if([password isEqualToString:@"123456"]){
        return [NSString stringWithFormat:@"%d",counts];
    }else{
        return @"password is wstrong";
    }
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        Banker* bk = [[Banker alloc] initWithNumber:0];
        [bk addnumber:10];
        [bk subnumber:6];
        NSString* res = [bk getTotalcnts:@"123456"];
        NSLog(@"%@",res);
    }
    return 0;
}
~~~

## 8、类别

### 用法（向现有类中添加新的方法）

~~~objective-c
#import <Foundation/Foundation.h>

@interface NSNumber(Myadditions)
- (NSNumber*)triple;
@end

@implementation NSNumber(Myadditions)

- (NSNumber*)triple{
    double res = [self doubleValue] * 3;
    return [NSNumber numberWithDouble:res];
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        NSNumber* number = [NSNumber numberWithDouble:2.5];
        NSNumber* res = number.triple;
        NSLog(@"%.1f",res.doubleValue);
    }
    return 0;
}
~~~

### 扩展

### 用法

扩展和类别都可以向现有类添加新的功能，但是扩展只能给在编译时具有源代码的类添加新的功能，并且扩展声明的方法或属性，对于被继承的类来说，是不可以访问的，扩展只可以给类添加私有的方法和变量

~~~objective-c
#import <Foundation/Foundation.h>

@interface MathClass : NSObject
+ (int) getDouble:(int) number;
@end

// 使用类名加一个小括号
@interface MathClass()
+ (int) getTriple:(int)number;
@end

@implementation MathClass

+ (int) getDouble:(int) number{
    return number*2;
}

+ (int) getTriple:(int)number{
    return number*3;
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        int res1 = [MathClass getDouble:2];
        int res2 = [MathClass getTriple:3];
        NSLog(@"res1 = %d, res2 = %d",res1,res2);
    }
    return 0;
}
~~~

## 9、协议

### 基本用法

协议用于声明预期的、用于特定情况的方法，协议里的方法，会在符合协议的类中进行实现

~~~objective-c
#import <Foundation/Foundation.h>

@protocol KeyboardInspectorDelegate

// 检测到键盘即将隐藏时执行
- (void) doWhenkeyboardWillHide;
@end

@interface FormChecker : NSObject{
    id delegate;
}
- (void) setDelegate:(id) newDelegate;
- (void) validateForm;
@end

@implementation FormChecker

- (void) setDelegate:(id) newDelegate{
    delegate = newDelegate;
}

- (void) validateForm{
    NSLog(@"validating form...");
    // 调用代理的协议方法
    [delegate doWhenkeyboardWillHide];
}
@end

// 接口继承NSObject类，遵循自定义的协议，协议的名称放置在一对尖括号内
@interface ControllerClass : NSObject<KeyboardInspectorDelegate>
- (void) enterForm;
@end

@implementation ControllerClass

- (void) enterForm{
    FormChecker* checker = [[FormChecker alloc] init];
    [checker setDelegate:self];
    [checker validateForm];
}

- (void) doWhenkeyboardWillHide{
    NSLog(@"Enter next page.");
}
@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        ControllerClass* control = [[ControllerClass alloc] init];
        [control enterForm];
    }
    return 0;
}
~~~

## 10、错误NSError

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

@interface MyClass : NSObject
- (char*) handler : (int)num second:(NSError**)err;
@end

@implementation MyClass

- (char* ) handler : (int)num second:(NSError**)err{
    if(num == 1){
        return @"news good";
    }
    else{
        // 初始化两个字符串变量，用来表示错误的域和信息，NSError对象的核心属性时由字符串表示的错误域，
        // 特定于域的错误代码和包含特定信息的用户信息字典
        NSString* domain = @"con.xxx.xxx";
        NSString* message = @"Failed to request News";
        NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:message,@"NSLocalizedDescriptionKey", nil];
        // 使用上面的信息，创建一个NSError对象，并将该对象赋予第二个指针参数
        *err = [NSError errorWithDomain:domain code:404 userInfo:userInfo];
        return "";
    }
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        NSError* err = nil;
        MyClass* mc = [[MyClass alloc] init];
        char* new1 = [mc handler:1 second:&err];
        if(err){
            NSLog(@"哈哈哈哈");
        }
        else{
            NSLog(@"嘿嘿嘿嘿");
        }
        
        err = nil;
        char* new2 = [mc handler:2 second:&err];
        if(err){
            NSLog(@"哈哈哈哈");
        }
        else{
            NSLog(@"嘿嘿嘿嘿");
        }
    }
    return 0;
}
~~~

## 11、try catch finally

### 基本用法

~~~objective-c
#import <Foundation/Foundation.h>

int main(int argc,const char* argv[]){
    @autoreleasepool {
        NSString* str = @"hello world";
        char cr;
        @try {
            cr = [str characterAtIndex:40];
            NSLog(@"character = %c",cr);
        } @catch (NSException *exception) {
            NSLog(@"exception.name = %@",exception.name);
            NSLog(@"exception.reason = %@",exception.reason);
        } @finally {
            NSLog(@"charcter = %c",cr);
            NSLog(@"The finally statment.");
        }
    }
    return 0;
}
~~~

## 12、内存管理

### MRC与ARC（自动管理内存与手动管理内存）

默认状态下，Xcode使用ARC自动引用计数的方式，进行内存的管理，所以在删除自动释放池之后，还需要修改代码文件的编译属性

![image-20241102144555091](https://github.com/user-attachments/assets/9a93a2eb-1af3-400c-9330-4590d155de4d)


~~~objective-c
#import <Foundation/Foundation.h>

@interface GreetingClass : NSObject
- (void) sayHello;
@end

@implementation GreetingClass

- (void) sayHello{
    NSLog(@"Hello Object-c \n");
}

// 用来移除通知或监听之类的操作
- (void) dealloc{
    NSLog(@">>>The gretting object is deallocated.>>>>>>");
    [super dealloc];
}

@end

int main(int argc,const char* argv[]){
    GreetingClass* gt = [[GreetingClass alloc] init];
    [gt sayHello];
    
    // 输出对象的保留计数的值，该值表示该对象所在的内存被引用的次数，这个值时对象的内存是否被回收的依据，
    // 当值为0的时候，表示该对象所在的内存可以被回收
    NSLog(@"greeting.retainCount = %lu",(unsigned long)[gt retainCount]);
    
    // 向对象发送retain的消息，消息会导致对象的保留计数的值增加1
    [gt retain];
    NSLog(@"greeting.retainCount（after ratain） = %lu",(unsigned long)[gt retainCount]);
    
    [gt release];
    NSLog(@"greeting.releaseCount = %lu",(unsigned long)[gt retainCount]);
    
    // 值为0，表示对象所在的内存地址，目前处于空闲状态，没有被任何变量引用，此时对象的内存会被操作系统随时回收
    [gt release];
    NSLog(@">>>>>dealloc method will be called");
    
    // 将指针设置为nil，避免出现悬挂指针
    gt = nil;
}
~~~

## 13、ARC内存管理

### 基本用法

在自动引用计数的ARC的机制中，系统使用与手动引用计数相同的引用计数系统，来监视内存是否应该被回收，但是它不需要手动添加retain、release之类的操作

~~~objective-c
#import <Foundation/Foundation.h>

@interface GreetingClass : NSObject
- (void) sayHello;
@end

@implementation GreetingClass

- (void) sayHello{
    NSLog(@"Hello Object-c \n");
}

// 用来移除通知或监听之类的操作
- (void) dealloc{
    NSLog(@">>>The gretting object is deallocated.>>>>>>");
}

@end

int main(int argc,const char* argv[]){
    @autoreleasepool {
        GreetingClass* gc = [[GreetingClass alloc] init];
        [gc sayHello];
        // 不需要这个对象的时候，将对象设置为nil，此时保留计数的值为0，内存将被随时回收
        gc = nil;
        NSLog(@"嘿嘿嘿嘿嘿嘿嘿");
    }
}
~~~

# 三、xcode

![image](https://github.com/user-attachments/assets/d324b015-810a-4648-9c2b-000c64d9a664)



### ios

1、Game：游戏框架模版，主要用来开发二维游戏，目前已经支持了的内容包括：场景、精灵、很酷的特效，并且还集成了物理库等许多内存

2、Augmented Reality App:增强现实模版是新增的应用模版，用来快速搭建和增强现实相关的应用程序，并提供了默认的三位场景

3、iMessage App:消息应用模版，可以使用完整的框架和原生的消息应用进行交互，使用该模版可以再消息应用内，显示一个自定义的交互界面，甚至创建自定义的表情包

4、Sticker Pack App：使用该模版可以将一组表情图片，在多行多列上进行排列，允许用户和朋友交流时发送表情贴纸



上面没有的：

Document Based App：用来创建基于文档的应用程序

master-Detail APP：详情应用模版，可以创建和邮箱相似的应用程序，在程序界面的左侧是右键的标题，右侧可以显示右键的内容

Tabbed App：标签应用模版，可以构建标签导航模式的应用，生成的代码中包含了标签控制器和标签栏等

Page-Based App：基于页面的应用模版，可以构建类似于电子书效果的应用，这是一种平铺导航模式

Single View App：单视图应用模版，可以构建简单的单个视图的应用


![image-20241102152502022](https://github.com/user-attachments/assets/cdf8b2b3-cbe9-4fe3-a2f4-eef91bdd600b)

在开发项目的过程中，需要使用测试证书在真机上测试程序，在将程序发布到苹果商店时，需要发布证书进行产品的发布，这两种证书都是和账号绑定的



## 模拟器显示图片

~~~objective-c
//    // 创建一个UIImage类的实例，可以用来加载和绘制图像
//    UIImage* img = [UIImage imageNamed:@"1"];
//    // 在加载项目中的图片资源后，再将图片指定给UIImageView，可以将图像视图看作是图片的容器
//    UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
//    // 设置图像时图在屏幕上的显示区域，坐标为屏幕左上角的原点位置，宽度320，高度568
//    imgView.frame = CGRectMake(0, 0, 320, 568);
//    // 把图像视图添加到当前视图控制器的根视图，就可以在屏幕上显示图片了
//    [self.view addSubview:imgView];
    
    UIImage* uiimage = [UIImage imageNamed:@"5"];
    UIImageView* imageView1 = [[UIImageView alloc] initWithImage:uiimage];
    [self.view addSubview:imageView1];
~~~

## 屏幕的朝向

~~~objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 通知中心上专为程序中，不同类之间的消息通信而设置的，使用起来极为方便，在此用来捕捉手机方向切换的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
}

- (void) orientationChanged{
    // 获取遍历设备的方向，同时在控制台，输出关于屏幕方向的日志
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕倒立");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"横向且屏幕在左侧的情况");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"横向且屏幕在右侧的情况");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕面朝上");
            break;
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕面朝下");
            break;
        default:
            NSLog(@"无法获得屏幕的朝向");
            break;
    }
}
~~~



## 竖

## AppDelegate

应用的代理实现文件，应用代理文件是系统运行本应用的委托，里面定义了如程序的进入与退出、设备方向旋转等众多全局方法

![image-20241102191914010](https://github.com/user-attachments/assets/1c052e3c-6043-4576-a0ce-05a68bbdd91d)


1、可以把程序载入后需要执行的代码，写在程序完成加载的方法里面，当程序完成加载的过程后，在控制台输出一行提示文字

![image-20241102193119128](https://github.com/user-attachments/assets/a9f37913-969f-4af2-8451-1943e5547e7a)



2、当程序进入非活动状态时，调用此方法，在此期间，程序不会接收消息或事件

![image-20241102193627270](https://github.com/user-attachments/assets/24d68bf3-2b32-4811-8645-c776b4b70fb3)


3、当程序被推送到后台的时候，调用次方法，如果要设置后台继续某些动作，则在这个方法里面添加代码即可

![image-20241102193912209](https://github.com/user-attachments/assets/daab0f67-1af7-446e-9cf2-b7e16db09d38)


4、当程序从后台将要重新回到前台的时候，调用此方法

![image-20241102194127792](https://github.com/user-attachments/assets/845c9657-2cf0-4dff-beb4-7916e8c4aa8f)



5、当程序进入活动状态的时候，执行该方法

![image-20241102194257846](https://github.com/user-attachments/assets/2a5a0e1a-901d-417b-8ed3-ad1ca31c144f)



6、当程序将要退出的时候，调用该方法，通常是用来保存数据，和一些退出前的清理工作

![image-20241102194416123](https://github.com/user-attachments/assets/9168b794-6b56-4139-8cad-c14d40f7c465)



Xcode

![image-20241107222259253](https://github.com/user-attachments/assets/a59bcd0f-b734-4227-865c-339570c54148)

应用代理文件，是系统运行本应用的委托，里面定义了如程序的进入与退出，设备方向的旋转等众多全局方法

## ViewController

![image-20241107222451801](https://github.com/user-attachments/assets/4d959b18-ba56-4aad-8f16-1a80c57422e6)


视图控制器可以创建和管理视图也可以监测设备方向的变化，并调整视图大小以适应屏幕，以及在视图和模型之间进行数据的传递

## Main

![image-20241107222722764](https://github.com/user-attachments/assets/6b8e4a00-0a06-4845-bb78-a70ffebac293)

这个主要是可以使所有的视图控制器以及它们之间的关系一目了然，它也是适配多个分辨率设备的利器（故事板）

## Assets

![image-20241107222908852](https://github.com/user-attachments/assets/0c3f7623-0965-4851-8cc5-c0f4434441ca)

资源文件夹可以方便进行图片管理，并且在读取图片时，不需要加上图片名的后缀，可以提高软件的安全性，它会将图片都加密压缩，并保存在Assets.car文件中

## LaunchScreen

![image-20241107223218441](https://github.com/user-attachments/assets/86664340-87b5-401a-b4a4-2b85e552c4d9)

启动场景故事板，可以帮助设计和适配程序的启动页

## info

![image-20241107223327209](https://github.com/user-attachments/assets/3f08f1b1-275b-4211-a1b2-0a0c730a9b8c)

每个程序都会使用信息属性列表文件，存储项目配置信息，例如程序的版本号，显示用的图标，支持的设备方向等等

## main

![image-20241107223455069](https://github.com/user-attachments/assets/c06a9674-0add-447d-af1c-c037e9770469)


工程根目录下的main文件，是应用程序的入口，它会创建主要的运行循环，处理应用程序里的各种事件，创建一个窗口，加载第一个控制器，并保持程序一直运行

## APPTest

![image-20241107223750341](https://github.com/user-attachments/assets/90d2cd4c-4ba8-4291-8d2f-856b1660b5a8)


项目测试目录下的内容

## UITest

![image-20241107223839015](https://github.com/user-attachments/assets/20ddc239-0938-44ae-b160-c93dbd9b1c86)


产品目录，存放项目编译后生成的文件包，使用产品>编译命令，可以在此处生成合适发布到苹果市场的应用压缩包



## 横

## 版本控制导航器

![image-20241107224050449](https://github.com/user-attachments/assets/d48312b0-352b-4b5c-8062-9150e7e42170)


版本控制导航器图标，进入源码版本控制面板，在此面板可以对源码进行版本的管理



## 状态面板

![image-20241107224527621](https://github.com/user-attachments/assets/ee6275fe-205d-448e-a5ba-3a3d1e8a276e)


状态面板显示项目中所有文档中的代码问题，黄色标志代表各种不影响程序运行的小问题，红色标志表示致命的错误，需要修复才能运行



## 测试面板

![image-20241107224827915](https://github.com/user-attachments/assets/6961f632-07d1-4a18-b96f-5f7dbb9d226c)


测试面板显示了测试的所有用例







# 四、视图控制器UIView

## 1、基础操作

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect rect1 = CGRectMake(30, 50, 200, 200);
    UIView* view1 = [[UIView alloc] initWithFrame:rect1];
    view1.backgroundColor = [UIColor brownColor];
    
    CGRect rect2 = CGRectMake(90, 120, 200, 200);
    UIView* view2 = [[UIView alloc] initWithFrame:rect2];
    view2.backgroundColor = [UIColor purpleColor];
    
    [self.view addSubview:view1];
    [self.view addSubview:view2];
}

@end
~~~

### 效果

![image-20241109103757876](https://github.com/user-attachments/assets/52e51254-e90d-4e5d-97c0-ba705f8100ce)


## 2、多个视图

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建三个视图对象，其中第二个视图上第三个视图的父视图
    UIView* view1 = [[UIView alloc] initWithFrame:CGRectMake(20, 80, 280, 280)];
    view1.backgroundColor = [UIColor redColor];
    // 第一个视图添加到当前视图控制器的根视图
    [self.view addSubview:view1];
    
    UIView* view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    // 设置视图本地坐标系统中的位置和大小，会影响子视图的位置和显示
    view2.bounds = CGRectMake(-40, -20, 200, 200);
    view2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:view2];
    
    UIView* subview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    subview.backgroundColor = [UIColor blueColor];
    [view2 addSubview:subview];
}

@end
~~~

### 效果

![image-20241109105746183](https://github.com/user-attachments/assets/3294a8f6-ce50-4442-b3ba-b3f967fb3716)



## 3、视图的基本操作

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 实现视图的添加与删除，以及切换视图在父视图中的层次
    CGRect rect1 = CGRectMake(30, 50, 200, 200);
    UIView* view1 = [[UIView alloc] initWithFrame:rect1];
    view1.backgroundColor = [UIColor brownColor];
    [self.view addSubview:view1];
    
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(30, 350, 80, 30)];
    btn.backgroundColor = [UIColor grayColor];
    // 设置按钮在正常状态下的标题，其他状态还包括按钮被按下等状态
    [btn setTitle:@"Add" forState:UIControlStateNormal];
    // 给按钮绑定点击事件，点击按钮时执行添加视图的方法
    [btn addTarget:self action:@selector(addView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // 第二个按钮，点击这个按钮的时候，切换到根视图，两个视图的层次顺序
    UIButton* btBack = [[UIButton alloc] initWithFrame:CGRectMake(120, 350, 80, 30)];
    btBack.backgroundColor = [UIColor grayColor];
    [btBack setTitle:@"Switch" forState:UIControlStateNormal];
    // 给按钮绑定点击事件，点击按钮时，交换两个视图的层次顺序
    [btBack addTarget:self action:@selector(bringViewBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btBack];
    
    // 第三个按钮，点击这个按钮的时候，从当前视图控制器的根视图中删除新添加的视图
    UIButton* btRemove = [[UIButton alloc] initWithFrame:CGRectMake(210, 350, 80, 30)];
    btRemove.backgroundColor = [UIColor grayColor];
    [btRemove setTitle:@"Remove" forState:UIControlStateNormal];
    [btRemove addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btRemove];
}

// 按钮的点击事件
- (void) addView{
    CGRect rect = CGRectMake(60, 90, 200, 200);
    UIView* view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor purpleColor];
    // 给视图指定一个标识，这样就可以在以后需要的时候，通过标识找到这个视图了
    view.tag = 1;
    [self.view addSubview:view];
}

- (void) bringViewBack{
    // 通过刚刚给视图对象设置的标识值，找到新添加的视图
    UIView* view = [self.view viewWithTag:1];
    // 将新添加的视图，移到所以兄弟视图的后方
    [self.view sendSubviewToBack:view];
}

- (void) removeView{
    // 通过刚刚给视图对象设置的标识值，找到新添加的视图
    UIView* view = [self.view viewWithTag:1];
    // 将新添加的视图从父视图，也就是当前视图控制器的根视图中删除
    [view removeFromSuperview];
}

@end
~~~

### 效果

![image-20241109112737936](https://github.com/user-attachments/assets/99a4e7c9-5211-43e1-8874-f5f39b30da12)




## 4、图像

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 给一张图片添加一个颜色相框
    // UIImage是一个用来加载和绘制图像的类
    UIImage* image = [UIImage imageNamed:@"1"];
    // 将图片从资源文件夹中加载之后，将图片赋给图像视图，将图像视图看作是图片的容器
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(24, 80, 272, 410);
    // 设置图像视图的图层边框的宽度为10，视图真正的绘图部分，时由一个图层类的对象来管理的
    imageView.layer.borderWidth = 10;
    // 视图本身更像是一个图层的管理器，访问它的跟绘图和坐标有关的属性，实际上都是在访问它所包含的图层的相关属性
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.view addSubview:imageView];
}

@end
~~~

### 效果

![image-20241109114657162](https://github.com/user-attachments/assets/bd74bc93-ba8d-4144-98f7-7bb83d87ad4f)


## 5、图像圆角

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 给矩形图片添加圆角效果
    UIImage* image = [UIImage imageNamed:@"1"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    
    CGRect rect = CGRectMake(10, 80, 300, 300);
    // 设置图像视图的显示区域
    imageView.frame = rect;
    // 设置图像视图层的圆角半径大小，使其半径大小等于图像视图宽度的一半
    imageView.layer.cornerRadius = 150;
    // 设置图像视图层的遮罩覆盖属性，进行边界裁切
    imageView.layer.masksToBounds = true;
    [self.view addSubview:imageView];
}

@end
~~~

### 效果

![image-20241109120153543](https://github.com/user-attachments/assets/76de6809-d86d-4b3c-a24d-19068e2c3a40)


## 6、给图像增加投影

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 给图像视图添加投影效果
    UIImage* image = [UIImage imageNamed:@"1"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    
    CGRect rect = CGRectMake(36, 80, 248, 164);
    imageView.frame = rect;
    
    // 设置图像视图层阴影颜色为黑色
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    // 设置图像视图层，阴影的横向和纵向偏移值
    imageView.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    // 设置图像视图层的阴影透明度
    imageView.layer.shadowOpacity = 0.45;
    // 设置图像视图层的阴影半径大小
    imageView.layer.shadowRadius = 10;
    
    [self.view addSubview:imageView];
}

@end
~~~

### 效果

![image-20241109121114320](https://github.com/user-attachments/assets/0d7a4e82-9aba-41d3-9cc8-8414cd6ff87c)


## 7、渐变颜色

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 渐变填充色的图形
    
    CGRect rect = CGRectMake(30, 60, 200, 200);
    UIView* gradientView = [[UIView alloc] initWithFrame:rect];
    
    // 新建一个渐变层
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    // 设置渐变层的位置和尺寸，与视图对象保持一致
    gradientLayer.frame = gradientView.frame;
    
    // 设置渐变的起始颜色为黄色
    CGColorRef fromColor = [UIColor yellowColor].CGColor;
    // 设置渐变的中间颜色为红色
    CGColorRef midColor = [UIColor redColor].CGColor;
    // 设置渐变的结束颜色为紫色
    CGColorRef toColor = [UIColor purpleColor].CGColor;
    
    // 将渐变层的颜色数组属性，设置为三个颜色所构建的数组
    gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)(fromColor), midColor,toColor,nil];
    [gradientView.layer addSublayer:gradientLayer];
    [self.view addSubview:gradientView];
}

@end
~~~

### 效果

![image-20241109122157707](https://github.com/user-attachments/assets/8d5e8bf1-10f3-4824-aeb1-ced8ed7d7ee6)


## 8、图片文理（平铺整个界面）

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage* image = [UIImage imageNamed:@"1"];
    UIColor* patternColor = [[UIColor alloc] initWithPatternImage:image];
    self.view.backgroundColor = patternColor;
}


@end
~~~

### 效果

![image-20241109224251529](https://github.com/user-attachments/assets/22af51ba-d1d8-4cd3-b74b-a05d529a3e03)


## 9、仿射变换

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用时图对象的仿射变换功能，旋转时图对象
    CGRect rect = CGRectMake(50, 150, 200, 50);
    UIView* view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor brownColor];
    [self.view addSubview:view];
    
    // 创建一个仿射变换变量，仿射变换用于平移，旋转，缩放变换路径或者图形上下文
    CGAffineTransform transform = view.transform;
    // 旋转功能，对视图进行四十五度旋转
    transform = CGAffineTransformRotate(transform,3.14/4);
    // 将变换变量。赋值给视图对象
    view.transform = transform;
}

@end
~~~

### 效果

![image-20241109232207116](https://github.com/user-attachments/assets/f42a8000-b580-464a-b780-97402f6c1053)



## 10、单机手势操作

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 手势功能，完成视图的交互操作
    CGRect rect = CGRectMake(32, 80, 256, 256);
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:rect];
    
    UIImage* image = [UIImage imageNamed:@"1"];
    imageView.image = image;
    
    // 开启图像视图对象的交互功能
    [imageView setUserInteractionEnabled:true];
    [self.view addSubview:imageView];
    
    // 创建一个手势检测类，这是一个抽象类，定义了所有手势的基本行为，并拥有6个子类，来检测发生在设备中的各种手势
    UITapGestureRecognizer* guesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    
    // 将创建的手势，指定给图像视图
    [imageView addGestureRecognizer:guesture];
}

- (void) singleTap{
    // 当接收到手势事件后，弹出一个提示窗口
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Infomation" message:@"Single Tap" preferredStyle:UIAlertControllerStyleAlert];
    
    // 创建一个按钮，作为提示窗口中的确定按钮，用户点击这个按钮时，关闭提示窗口
    UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        NSLog(@"UIAlterAction");
    }];
    
    [alertController addAction:OKAction];
    // 在当前视图控制器中，展示提示窗口
    [self presentViewController:alertController animated:true completion:nil];
}

@end
~~~

### 效果

![image-20241109234811532](https://github.com/user-attachments/assets/85d43c88-e5dd-47f4-8586-8b7402fab688)


## 11、长按手势操作

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(32, 80, 256, 256);
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:rect];
    
    UIImage* image = [UIImage imageNamed:@"1"];
    imageView.image = image;
    
    // 开启图像视图的交互功能
    [imageView setUserInteractionEnabled:true];
    [self.view addSubview:imageView];
    
    UILongPressGestureRecognizer* guesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [imageView addGestureRecognizer:guesture];
}

- (void) longPress:(UILongPressGestureRecognizer* )guesture{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Infomation" message:@"Long Press" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        NSLog(@"UIAlertAction");
    }];
    
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:true completion:nil];
}

@end
~~~

### 效果

![image-20241110115605739](https://github.com/user-attachments/assets/e54333b6-33eb-4f5c-a23c-48e86f5b9d94)


## 12、双击手势操作

~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 双击手势，完成视图的交互功能
    CGRect rect = CGRectMake(32, 80, 256, 256);
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:rect];
    
    UIImage* image = [UIImage imageNamed:@"1"];
    imageView.image = image;
    
    // 开启图像视图对象的交互功能
    [imageView setUserInteractionEnabled:true];
    [self.view addSubview:imageView];
    
    UITapGestureRecognizer* guesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
    // 设置点击次数为2，模拟双击
    [guesture setNumberOfTapsRequired:2];
    // 一次双击事件
    [guesture setNumberOfTouchesRequired:1];
    
    // 将手势指定给图像视图对象
    [imageView addGestureRecognizer:guesture];
}

- (void) doubleTap{
    // 接收到手势事件后，弹出一个提示窗口
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Infomation" message:@"Double Tap" preferredStyle:UIAlertControllerStyleAlert];
    
    // 创建一个按钮，提示窗口中的确定按钮，用户点击这个按钮的时候，关闭提示窗口，将按钮添加到提示窗口
    UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        NSLog(@"UIAlertAction");
    }];
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:true completion:nil];
}

@end
~~~

### 效果

![image-20241110121154632](https://github.com/user-attachments/assets/231b8f6e-3b3c-4ab3-9eb0-8a1857339857)


## 13、滚动视图

![image-20241111223905325](https://github.com/user-attachments/assets/51d588de-6c2d-45a2-83b8-4e73c2a60dc9)




~~~objective-c
#import "FirstSubViewController.h"

@interface FirstSubViewController ()

@end

@implementation FirstSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor brownColor];
}
@end
~~~

~~~objective-c
#import "SecondSubViewController.h"

@interface SecondSubViewController ()

@end

@implementation SecondSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor purpleColor];
}
@end
~~~

~~~objective-c
#import <UIKit/UIKit.h>
#import "FirstSubViewController.h"
#import "SecondSUbViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PageControlViewController : UIViewController<UIScrollViewDelegate>

// 添加两个属性，表示对两个子控制器的引用
@property (nonatomic) FirstSubViewController* firstSubViewController;
@property (nonatomic) SecondSubViewController* secondSubViewController;

// 添加一个页面控制属性，通过该组件中的小白点，观察视图用于查看超出屏幕的内容， 布尔属性则被用来标识页面的滑动状态
@property (nonatomic) UIPageControl* pageControl;
@property (nonatomic) UIScrollView* scrollView;
@property (nonatomic) BOOL isPageControlUsed;

@end

NS_ASSUME_NONNULL_END
~~~

~~~objective-c
#import "PageControlViewController.h"

@interface PageControlViewController ()

@end

@implementation PageControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenFrame = [UIScreen mainScreen].bounds;
       int screenWidth = screenFrame.size.width;
       int screenHeight = screenFrame.size.height;
       
       // 初始化滚动视图，并设置滚动视图的显示区域
       _scrollView = [[UIScrollView alloc] initWithFrame:screenFrame];
       // 设置滚动视图为分页模式，每次滚动一次就是一页
       _scrollView.pagingEnabled = YES;
       // 设置滚动视图的尺寸信息，有两个页面所以将滚动视图的宽度设置为两倍页面宽度
       _scrollView.contentSize = CGSizeMake(screenWidth*2, screenHeight);
       _scrollView.backgroundColor = [UIColor blackColor];
       // 设置滚动视图对象的代理模式为当前的控制器对象，在当前文件中，编写代理方法，以捕捉滚动视图的相关动作
       _scrollView.delegate = self;
       
       // 创建一个高度常量，作为页面控制器对象的高度
       int pcHeight = 50;
       CGRect rect = CGRectMake(0, screenHeight - pcHeight, screenWidth, pcHeight);
       _pageControl = [[UIPageControl alloc] initWithFrame:rect];
       // 设置页面控制器对象的总页数为两页
       _pageControl.numberOfPages = 2;
       // 当前页面控制器对象的当前页编号
       _pageControl.currentPage = 0;
       _pageControl.backgroundColor = [UIColor grayColor];
       // 给页面控制器对象添加监听页面切换事件的方法
       [_pageControl addTarget:self action:@selector(pageControlDidChanged:) forControlEvents:UIControlEventValueChanged];
       
       _firstSubViewController = [[FirstSubViewController alloc] init];
       screenFrame.origin.x = 0;
       // 显示区域
       _firstSubViewController.view.frame = screenFrame;
       
       _secondSubViewController = [[SecondSubViewController alloc] init];
       screenFrame.origin.x = screenFrame.size.width;
       _secondSubViewController.view.frame = screenFrame;
       
       // 将两个视图控制器的根视图，分别添加到滚动视图对象里
       [_scrollView addSubview:_firstSubViewController.view];
       [_scrollView addSubview:_secondSubViewController.view];
       
       // 把滚动视图对象和页面控制器对象，分别添加到当前窗口的根视图里
       [self.view addSubview:_scrollView];
       [self.view addSubview:_pageControl];
   }

   - (void)pageControlDidChanged{
       // 获得当前页面控制器对象的当前页码
       long crtPage = _pageControl.currentPage;
       // 获得滚动视图当前的显示区域
       CGRect frame = _scrollView.frame;
       // 根据页面控制器对象的目标页码。计算滚动视图在下一页中的显示区域
       frame.origin.x = frame.size.width * crtPage;
       frame.origin.y = 0;
       // 滚动视图到目标区域
       [_scrollView scrollRectToVisible:frame animated:YES];
       // 设置通过页面控制器对象切换页面
       _isPageControlUsed = YES;
   }

   // 创建监听滚动视图的滚动事件代理方法
   - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
       // 如果时通过页面控制器对象切换页面，不执行后面的代码
       if(_isPageControlUsed){
           return;
       }
       
       CGFloat pageWidth = _scrollView.frame.size.width;
       // 根据滚动视图的宽度值和横向位移量，计算当前的页码
       int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1;
       // 设置页面控制器的显示页码，通过计算所得的页码
       _pageControl.currentPage = page;
   }

   - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
       // 创建监听滚动视图的滚动减速事件的代理方法，重置标识变量的默认值
       _isPageControlUsed = NO;
   }

@end
~~~

## 14、选项卡（标签）控制器

~~~objective-c

~~~





##  15、导航视图控制器

~~~objective-c

~~~

## 16、UICollectionView



# 三、UIKit

## UIButton

~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 背景为深色的提示信息按钮
    UIButton* bt1 = [UIButton buttonWithType:UIButtonTypeInfoDark];
    bt1.frame = CGRectMake(130, 80, 40, 40);
    
    // 圆角按钮
    UIButton* bt2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt2.frame = CGRectMake(80, 180, 150, 44);
    bt2.backgroundColor = [UIColor purpleColor];
    // 按钮的前景颜色为黄色
    bt2.tintColor = [UIColor yellowColor];
    [bt2 setTitle:@"Tap Me" forState:UIControlStateNormal];
    [bt2 addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* bt3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt3.backgroundColor = [UIColor brownColor];
    bt3.tintColor = [UIColor whiteColor];
    [bt3 setTitle:@"Tap me!" forState:UIControlStateNormal];
    bt3.frame = CGRectMake(80, 280, 150, 44);
    // 给按钮添加边框效果
    bt3.layer.masksToBounds = YES;
    // 设置按钮层的圆角半径为10
    bt3.layer.cornerRadius = 10;
    // 设置按钮层的边框的宽度为4
    bt3.layer.borderWidth = 4;
    // 设置按钮层边框的颜色为浅灰色
    bt3.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.view addSubview:bt1];
    [self.view addSubview:bt2];
    [self.view addSubview:bt3];
}

- (void) buttonTap:(UIButton*) button{
    // 创建一个警告弹出窗口，当按钮被点击时，弹出此窗口
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Infomation" message:@"UIButton Event. " preferredStyle:UIAlertControllerStyleAlert];
    // 创建一个按钮，作为提示窗口中的“确定”按钮，当用户点击此按钮时，将关闭提示窗口
    UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
~~~

### 效果
![image](https://github.com/user-attachments/assets/8e762872-af01-4a7f-b8a8-4694aeb1c489)
![image](https://github.com/user-attachments/assets/bcf6ecba-b589-40a8-b7d1-ce8d57b5e4d3)

## UIButton（UIImage）

~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* bt1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt1.frame = CGRectMake(31, 100, 257, 60);
    
    UIImage* image = [UIImage imageNamed:@"1"];
    // 绑定图片设置为正常状态下
    [bt1 setImage:image forState:UIControlStateNormal];
    [bt1 setTitleColor:@"Tap me" forState:UIControlStateNormal];
    [bt1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bt1.titleLabel.font = [UIFont fontWithName:@"Arail" size:24];
    [bt1 addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt1];
}

- (void) buttonTap:(UIButton*) bt{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Infomation" message:@"UIButton Event. " preferredStyle:UIAlertControllerStyleAlert];
        // 创建一个按钮，作为提示窗口中的“确定”按钮，当用户点击此按钮时，将关闭提示窗口
        UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:OKAction];
        [self presentViewController:alert animated:YES completion:nil];
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/810216fb-1512-4c02-95d6-765de2139d0c)
![image](https://github.com/user-attachments/assets/2230bb0b-4014-41f4-b794-fc8caf1cd834)

## UILabel

~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 标签控件的基础
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 80)];
    label.text = @"hello world";
    UIFont* font = [UIFont fontWithName:@"Arial" size:24];
    
    label.shadowColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(2, 2);
    
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor purpleColor];
    label.backgroundColor = [UIColor yellowColor];
    
    [self.view addSubview:label];
}


@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/6cb83e51-c82d-4e19-81e3-986341defff0)

## UILabel自定义
~~~objective-c
//
//  MyLabel.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "MyLabel.h"

@implementation MyLabel

// 标签对象添加描边效果
// 首先重载父类的绘图方法，这样就可以从底层来自自定义标签的形状来
- (void) drawTextInRect:(CGRect)rect{
    // 获取当前图形环境的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置在上下文中，文字的渲染模式为描边模式
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    // 设置文字秒描边的边框宽度为2
    CGContextSetLineWidth(context, 2);
    // 设置文字描边的顶点连接方式为圆角方式
    CGContextSetLineJoin(context, kCGLineJoinRound);
    self.textColor = [UIColor whiteColor];
    [super drawTextInRect:rect];
    
    // 设置在上下文中，文字的渲染模式为填充
    CGContextSetTextDrawingMode(context, kCGTextFill);
    self.textColor = [UIColor blackColor];
    [super drawTextInRect:rect];
}

@end
~~~
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"
#import "MyLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MyLabel* label = [[MyLabel alloc] init];
    label.frame = CGRectMake(120, 180, 240, 120);
    label.text = @"hello object-c";
    label.font = [UIFont fontWithName:@"Georgia" size:56];
    
    [self.view addSubview:label];
    self.view.backgroundColor = [UIColor purpleColor];
}


@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/8f3019b7-1274-4282-9c37-634034d8abe0)

## UISwitch
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 开关控件的基本用法，开关控件有两个互斥的选项，用来打开或者关闭选项的控件
    UISwitch* uiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 100, 0, 0)];
    // 设置开关对象的默认状态为选中
    [uiSwitch setOn:YES animated:YES];
    // 给开关对象添加状态变化事件
    [uiSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:uiSwitch];
}

- (void) switchChanged:(UISwitch*) uiSwitch{
    NSString* message = @"Turn on the switch.";
    if(!uiSwitch.isOn){
        message = @"Turn off the switch";
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Information" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/4aa9bb65-c169-4fd0-a898-588710304051)
![image](https://github.com/user-attachments/assets/4ce4e85c-fe03-497f-a3c3-936ad55640c8)
![image](https://github.com/user-attachments/assets/92db7f61-29ab-4639-b014-162c27c385fe)

## UITextField
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 文本输入框控制件的基本用法，文本输入框主要用于接收和显示用户输入的内容
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(60, 80, 200, 30)];
    // 设置文本框对象的边框样式为圆角矩形
    textField.borderStyle = UITextBorderStyleRoundedRect;
    // 设置文本框的占位符属性，用来描述输入字段预期值的提示信息，该提示会在输入字段为空时显示，并会在字段获得焦点时消失
    textField.placeholder = @"Your Email ";
    // 关闭文本框对象的语法错误提示功能
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    // 设置在输入文字时，在键盘面板上回车按钮的类型
    textField.returnKeyType = UIReturnKeyDone;
    // 设置文本框对象右侧的清除按钮，仅在编辑状态时显示
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 设置文本框对象的键盘类型，为系统提供的邮箱地址类型
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    // 设置文本框对象的键盘为暗色主题
    textField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    textField.delegate = self;
    [self.view addSubview:textField];
}

// 添加一个代理方法，当用户按下键盘上的回车键时，调用此方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textField.content = %@",[textField text]);
    // 使文本框失去焦点，键盘也将自动隐藏，在方法的末尾返回一个布尔值，表示允许结束文字输入的状态
    [textField resignFirstResponder];
    return YES;
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/ffdba654-98bf-4d53-96b4-de7bba43d1c5)
![image](https://github.com/user-attachments/assets/925393fc-90fb-4b1a-8238-4da4be87c764)

## 普通警告窗口
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 警告窗口的使用方法，警告窗口不仅可以给用户展现提示信息，还可以提供若干选项供用户选择
    UIButton* bt = [UIButton buttonWithType:UIButtonTypeSystem];
    bt.frame = CGRectMake(20, 120, 280, 44);
    [bt setTitle:@"Question" forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
    bt.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bt];
}

-(void) showAlert{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Infomation" message:@"Are you a student" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        NSLog(@"Yes, I'm a student");
    }];
    UIAlertAction* no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        NSLog(@"No, I'm not a student");
    }];
    
    [alert addAction:yes];
    [alert addAction:no];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/7ed21a5f-d050-4591-aa19-befaaf2fdced)
![image](https://github.com/user-attachments/assets/38421725-c59c-48dd-9e31-2ee4ac07d25e)
![image](https://github.com/user-attachments/assets/b55776b2-dc6b-4a8a-b816-0ffb1cf41bb9)
![image](https://github.com/user-attachments/assets/a25da183-3bc9-4b15-b987-7d231db5b6e6)

## 动作表样式警告窗口
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 动作表单窗口的使用，动作表单可以给用户展现一系列的选项，和警告窗口不同的是，动作表单的展示形式和设备的尺寸有关
    UIButton* bt = [UIButton buttonWithType:UIButtonTypeSystem];
        bt.frame = CGRectMake(20, 120, 280, 44);
    [bt setTitle:@"Question" forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    bt.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bt];
    
}

-(void) showActionSheet{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Infomation" message:@"What's your favorite" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* fishing = [UIAlertAction actionWithTitle:@"Fishing" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
        NSLog(@"I like fishing");
    }];
    
    UIAlertAction* hunting = [UIAlertAction actionWithTitle:@"hunting" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
        NSLog(@"I like hunting");
    }];
    
    UIAlertAction* nothing = [UIAlertAction actionWithTitle:@"nothing" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
        NSLog(@"I like nothing");
    }];
    
    [alert addAction:fishing];
    [alert addAction:hunting];
    [alert addAction:nothing];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/91229c42-9667-479e-9a55-4a4a41fe6b9a)
![image](https://github.com/user-attachments/assets/d22ff02a-84c2-418a-bf26-92e1f9fe1667)
![image](https://github.com/user-attachments/assets/a31c1813-9ea6-47ab-9518-c56c1b569551)

## UIDatePicker日期时间选择器
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 日期拾取器控件的使用，可以快速设置和选择日期与时间
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.center = CGPointMake(160, 200);
    // 设置日期拾取器的标识值，以便将来再次使用它
    datePicker.tag = 1;
    // 设置日期拾取器的最小值，最小值为当前的日期
    datePicker.minimumDate = [NSDate date];
    datePicker.maximumDate = [NSDate dateWithTimeInterval:3*24*60*60 sinceDate:[NSDate date]];
    [self.view addSubview:datePicker];
    
    UIButton* bt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt.frame = CGRectMake(20, 360, 280, 44);
    bt.backgroundColor = [UIColor lightGrayColor];
    [bt setTitle:@"Get date" forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(getDate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt];
}

-(void) getDate{
    // 通过标识值获得当前日期拾取器对象
    UIDatePicker* datePicker = [self.view viewWithTag:1];
    // 获得日期拾取器的日期值
    NSDate* date = datePicker.date;
    // 新建一个日期格式化对象，用来实现日期的格式化
    NSDateFormatter* dateFormater = [[NSDateFormatter alloc] init];
    // 设置日期的格式，大写字母H，表示采用24小时制
    dateFormater.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString* dateAndTime = [dateFormater stringFromDate:date];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Infomation" message:dateAndTime preferredStyle:UIAlertControllerStyleAlert];
        
    UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:OKAction];
    // 在当前视图控制器中，展示提示窗口
    [self presentViewController:alert animated:YES completion:nil];
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/818f38cb-5ac8-404e-8edb-e6c73b6bc2e9)
![image](https://github.com/user-attachments/assets/cc5ae614-ab89-4d26-b3c7-67eedd91e8be)

## WKWebView控件加载网页
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 0, 320, 568);
    WKWebView* webView = [[WKWebView alloc] initWithFrame:rect];
    
    NSURL* url = [NSURL URLWithString:@"https://www.apple.com"];
    // 创建一个网址请求对象，作为网页视图对象的网络请求
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    // 使用网页视图对象，加载设置的网址
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/84daea05-5f0d-4485-b54f-b65d753f66d5)

## WKWebView控件加载本地HTML
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 80, 320, 460);
    WKWebView* webView = [[WKWebView alloc] initWithFrame:rect];
    
    NSString* html = @"<span style='font-size:72;'><font color='blue'>Hello</font>,<B>Xcode</B> and <i>Swift</i></span>";
    
    // 网页视图对象加载字符串
    [webView loadHTMLString:html baseURL:nil];
    
    [self.view addSubview:webView];
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/3963cfc5-f43d-4171-bdd4-e84a958b6a60)

## UITableView
~~~objective-c
//
//  ViewController.h
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import <UIKit/UIKit.h>

// 添加文本框代理协议，使用协议中的方法，在完成文本框文字的输入后，隐藏系统键盘的显示
@interface ViewController : UIViewController<UITableViewDataSource>


@end
~~~
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 0, 320, 420);
    UITableView* tableView = [[UITableView alloc] initWithFrame:rect];
    
    // 设置表格视图的数据源，为当前的视图控制器，既由当前的视图控制器，提供的单元格的数据、样式等信息
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
}

// 添加一个代理方法，用来设置表格视图，拥有单元格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

// 添加一个代理方法，用来初始化或复用表格视图中的单元格
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 创建一个字符串，作为单元格的复用标识符
    NSString* identifier = @"reusedCell";
    // 单元格的标识符，可以看作是一种复用机制，此方法可以从，所有已经开辟内存的单元格里面，选择一个具有同样标识符的、空闲的单元格
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // 判断在可重用单元格队列中，是否拥有可以重复使用的单元格
    if(cell == nil){
        // 如果可重用单元格队列中，没有可以重复使用的单元格，则创建新的单元格，用新的单元格具有系统默认的单元格样式，并拥有一个复用标识符
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = @"Cell the Tittle";
    cell.detailTextLabel.text = @"Detail information here";
    return cell;
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/6882f045-c06e-4b91-bf0d-568cba202571)
## UITableView单元格高度
~~~objective-c
//
//  ViewController.h
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import <UIKit/UIKit.h>

// 表格视图的代理协议，可以用来设置单元格的高度
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@end
~~~
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 40, 320, 420);
    UITableView* tableView = [[UITableView alloc] initWithFrame:rect];
    
    // 设置表格视图的数据源，为当前的视图控制器，既由当前的视图控制器，提供的单元格的数据、样式等信息
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
}

// 添加一个代理方法，用来设置表格视图，拥有单元格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

// 添加一个代理方法，设置表格的行的高度为80
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

// 添加一个代理方法，用来初始化或复用表格视图中的单元格
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 创建一个字符串，作为单元格的复用标识符
    NSString* identifier = @"reusedCell";
    // 单元格的标识符，可以看作是一种复用机制，此方法可以从，所有已经开辟内存的单元格里面，选择一个具有同样标识符的、空闲的单元格
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // 判断在可重用单元格队列中，是否拥有可以重复使用的单元格
    if(cell == nil){
        // 如果可重用单元格队列中，没有可以重复使用的单元格，则创建新的单元格，用新的单元格具有系统默认的单元格样式，并拥有一个复用标识符
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = @"Cell the Tittle";
    cell.detailTextLabel.text = @"Detail information here";
    return cell;
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/5beb909c-fe11-4715-b1ee-a01c3f534277)

## UITableView单元格图标
~~~objective-c
//
//  ViewController.h
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import <UIKit/UIKit.h>

// 添加一个表格视图的数据源协议，使用协议里的方法，设置单元格的内容和单元格的数量
@interface ViewController : UIViewController<UITableViewDataSource>


@end
~~~

~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 40, 320, 420);
    UITableView* tableView = [[UITableView alloc] initWithFrame:rect];
    
    // 设置表格视图的数据源，为当前的视图控制器，既由当前的视图控制器，提供的单元格的数据、样式等信息
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
}

// 添加一个代理方法，用来设置表格视图，拥有单元格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

// 添加一个代理方法，用来初始化或复用表格视图中的单元格
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 创建一个字符串，作为单元格的复用标识符
    NSString* identifier = @"reusedCell";
    // 单元格的标识符，可以看作是一种复用机制，此方法可以从，所有已经开辟内存的单元格里面，选择一个具有同样标识符的、空闲的单元格
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // 判断在可重用单元格队列中，是否拥有可以重复使用的单元格
    if(cell == nil){
        // 如果可重用单元格队列中，没有可以重复使用的单元格，则创建新的单元格，用新的单元格具有系统默认的单元格样式，并拥有一个复用标识符
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = @"Cell the Tittle";
    cell.detailTextLabel.text = @"Detail information here";
    
    UIImage* star = [UIImage imageNamed:@"1"];
    UIImage* starGray = [UIImage imageNamed:@"2"];
    
    cell.imageView.image = star;
    cell.imageView.highlightedImage = starGray;
    
    return cell;
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/9aca8c07-f15b-41fe-b6ca-bf280ebde638)

## UITableView滑动到指定单元格
~~~objective-c
//
//  ViewController.h
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import <UIKit/UIKit.h>

// 添加一个表格视图的数据源协议，使用协议里的方法，设置单元格的内容和单元格的数量
@interface ViewController : UIViewController<UITableViewDataSource>


@end
~~~

~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

// 添加一个数组属性，作为表格的数据来源，另一个表格属性，表示需要使用到的表格视图对象
@property (strong,nonatomic) NSArray* months;
@property (strong,nonatomic) UITableView* tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.months = [NSArray arrayWithObjects:@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December",nil];
    
    CGRect rect = CGRectMake(0, 40, 320, 200);
    self.tableView = [[UITableView alloc] initWithFrame:rect];
    
    // 设置表格视图的数据源，为当前的视图控制器，既由当前的视图控制器，提供的单元格的数据、样式等信息
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

// 添加视图完成显示的方式，在该方法里实现表格的滑动的效果
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 初始化一个索引路径对象，用来表示表格中的第一个段落和第12行的位置
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:11 inSection:0];
    // 调用表格对象的滚动到指定位置的方法，表格将以动画的方法，滑动到指定索引位置
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

// 添加一个代理方法，用来设置表格视图，拥有单元格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.months.count;
}

// 添加一个代理方法，用来初始化或复用表格视图中的单元格
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 创建一个字符串，作为单元格的复用标识符
    NSString* identifier = @"reusedCell";
    // 单元格的标识符，可以看作是一种复用机制，此方法可以从，所有已经开辟内存的单元格里面，选择一个具有同样标识符的、空闲的单元格
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // 判断在可重用单元格队列中，是否拥有可以重复使用的单元格
    if(cell == nil){
        // 如果可重用单元格队列中，没有可以重复使用的单元格，则创建新的单元格，用新的单元格具有系统默认的单元格样式，并拥有一个复用标识符
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    long rowNum = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.months objectAtIndex:rowNum]];
    
    return cell;
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/46af5680-6c45-421a-8419-88ade7a3b54e)

## UITableView自定义单元格Accessory样式
~~~objective-c
//
//  ViewController.h
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import <UIKit/UIKit.h>

// 添加一个表格视图的数据源协议，使用协议里的方法，设置单元格的内容和单元格的数量
// 自定义单元格的附件图标
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@end
~~~

~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 40, 320, 420);
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect];
    
    // 设置表格视图的数据源，为当前的视图控制器，既由当前的视图控制器，提供的单元格的数据、样式等信息
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
}

// 添加一个代理方法，用来设置表格视图，拥有单元格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

// 添加一个代理方法，用来初始化或复用表格视图中的单元格
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 创建一个字符串，作为单元格的复用标识符
    NSString* identifier = @"reusedCell";
    // 单元格的标识符，可以看作是一种复用机制，此方法可以从，所有已经开辟内存的单元格里面，选择一个具有同样标识符的、空闲的单元格
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // 判断在可重用单元格队列中，是否拥有可以重复使用的单元格
    if(cell == nil){
        // 如果可重用单元格队列中，没有可以重复使用的单元格，则创建新的单元格，用新的单元格具有系统默认的单元格样式，并拥有一个复用标识符
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    // 获取当前单元格，在段落中的行数，然后根据当前单元格的行数，生成一个序列化的字符串，作为当前单元格的标题文字
    long rowNum = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"Cell item %ld",rowNum];
    
    return cell;
}

// 相应单元格的点击事件
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        // 如果被点击的单元格，没有显示附加图标，则显示复选标记图标，表示当前单元格处于选中状态
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/8d5665be-b9b6-4608-be5d-06de3617408e)

## 删除UITableView单元格
~~objective-c
//
//  ViewController.h
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@end
~~~
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong,nonatomic) NSMutableArray* months;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.months = [NSMutableArray arrayWithObjects:@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December",nil];
    
    CGRect rect = CGRectMake(0, 40, 320, 420);
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect];
    
    // 设置表格视图的数据源，为当前的视图控制器，既由当前的视图控制器，提供的单元格的数据、样式等信息
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
}

// 添加一个代理方法，用来设置表格视图，拥有单元格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.months.count;
}

// 添加一个代理方法，用来初始化或复用表格视图中的单元格
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 创建一个字符串，作为单元格的复用标识符
    NSString* identifier = @"reusedCell";
    // 单元格的标识符，可以看作是一种复用机制，此方法可以从，所有已经开辟内存的单元格里面，选择一个具有同样标识符的、空闲的单元格
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // 判断在可重用单元格队列中，是否拥有可以重复使用的单元格
    if(cell == nil){
        // 如果可重用单元格队列中，没有可以重复使用的单元格，则创建新的单元格，用新的单元格具有系统默认的单元格样式，并拥有一个复用标识符
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    // 获取当前单元格，在段落中的行数，然后根据当前单元格的行数，生成一个序列化的字符串，作为当前单元格的标题文字
    long rowNum = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.months objectAtIndex:rowNum]];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

// 添加一个代理方法，用来响应单元格的删除事件
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 判断如果编辑模式为删除，执行后面的代码
    if(editingStyle == UITableViewCellEditingStyleDelete){
        // 获取待删除的单元格，在段落中的行数，从数组中将该单元格的内容清除，以保证数据的一致性
        long rowNum = indexPath.row;
        [self.months removeObjectAtIndex:rowNum];
        
        // 创建一个包含待删除单元格位置信息的数组
        NSArray* indexPaths = @[indexPath];
        // 再从表格视图中清除该单元格
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/3e8b6d06-dc3a-494f-9438-029f651b58ec)

## UITableView插入单元格
~~~objective-c
//
//  ViewController.h
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@end
~~~
~~~objective-c
//
//  ViewController.m
//  Kit
//
//  Created by cr on 2024/11/16.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong,nonatomic) NSMutableArray* months;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.months = [NSMutableArray arrayWithObjects:@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December",nil];
    
    CGRect rect = CGRectMake(0, 40, 320, 420);
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect];
    // 在默认状态下，开启表格的编辑模式
    [tableView setEditing:YES animated:NO];
    
    // 设置表格视图的数据源，为当前的视图控制器，既由当前的视图控制器，提供的单元格的数据、样式等信息
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
}

// 添加一个代理方法，用来设置表格视图，拥有单元格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.months.count;
}

// 添加一个代理方法，用来初始化或复用表格视图中的单元格
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 创建一个字符串，作为单元格的复用标识符
    NSString* identifier = @"reusedCell";
    // 单元格的标识符，可以看作是一种复用机制，此方法可以从，所有已经开辟内存的单元格里面，选择一个具有同样标识符的、空闲的单元格
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // 判断在可重用单元格队列中，是否拥有可以重复使用的单元格
    if(cell == nil){
        // 如果可重用单元格队列中，没有可以重复使用的单元格，则创建新的单元格，用新的单元格具有系统默认的单元格样式，并拥有一个复用标识符
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    // 获取当前单元格，在段落中的行数，然后根据当前单元格的行数，生成一个序列化的字符串，作为当前单元格的标题文字
    long rowNum = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.months objectAtIndex:rowNum]];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleInsert;
}

// 添加一个代理方法，用来响应单元格的删除事件
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 判断如果编辑模式为删除，执行后面的代码
    if(editingStyle == UITableViewCellEditingStyleInsert){
        // 获取待删除的单元格，在段落中的行数，从数组中将该单元格的内容清除，以保证数据的一致性
        long rowNum = indexPath.row;
        [self.months insertObject:@"Honey Moon" atIndex:rowNum];
        
        // 创建一个包含待插入单元格位置信息的数组
        NSArray* indexPaths = @[indexPath];
        // 再从表格视图中清除该单元格
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
    }
}

@end
~~~
### 效果
![image](https://github.com/user-attachments/assets/778de3cc-ae36-4a0c-bbcd-cdc5df817701)
![image](https://github.com/user-attachments/assets/4304fa52-c595-456e-9c48-5bc3b446c307)

