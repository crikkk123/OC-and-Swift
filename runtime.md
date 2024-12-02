# Runtime

## runtime库函数
头文件：类相关函数#import<objc/runtime.h>

消息相关函数：#import<objc/message.h>

## 使用objc_msgSend函数
强制转换：((void(*)(id,SEL,int))(void*)objc_msgSend)   把oc的方法转换成objc_msgSend函数执行

## class_getInstanceSize ()方法可以计算一个类的实例对象所实际需要的的空间大小

