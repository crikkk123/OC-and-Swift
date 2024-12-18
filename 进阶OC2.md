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
