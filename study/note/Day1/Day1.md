# Day1

DeepSeek：sk-d03d7d072e4341cdb5e3a1bebc3fec6b

### 一个NSObject对象占用多少内存

```我们平时编写的Objective-C代码，底层实现其实都是C\C++代码```

<img width="1435" height="155" alt="image" src="https://github.com/user-attachments/assets/702bb722-9b55-4152-8173-59500ff9a7b0" />


所以Objective-C的面向对象都是基于C\C++的数据结构实现的

思考：Objective-C的对象、类主要是基于C\C++的什么数据结构实现的？

结构体

对象和类的底层数据结构都是 C 的 struct（结构体），不是指针。但指针是你访问它们的唯一方式——所以「基于指针」这个说法对了一半，是「访问方式对、存储结构不对」。

将Objective-C代码转换为C\C++代码

~~~text
xcrun  -sdk  iphoneos  clang  -arch  arm64  -rewrite-objc  OC源文件  -o  输出的CPP文件
~~~

如果需要链接其他框架，使用-framework参数。比如-framework UIKit



思考：一个OC对象在内存中是如何布局的？

NSObject的底层实现:
<img width="1465" height="567" alt="image" src="https://github.com/user-attachments/assets/50242071-c5dc-424c-917c-75cb818476b6" />


```一个NSObject对象占用多少内存？```

系统分配了16个字节给NSObject对象（通过malloc_size函数获得）

但NSObject对象内部只使用了8个字节的空间（64bit环境下，可以通过class_getInstanceSize函数获得）
