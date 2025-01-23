## OC代码转换为CPP代码的命令
  xrun -sdk iphoneos clang -arch arm64 -rewrite-objc OC源文件 -o 输出的CPP文件  链接其他的（-framework UIKit）

  clang -rewrite-objc main.m -o main.cpp


category实际上是在运行的时候，利用runtime讲方法合并到类对象或者元类对象中，在调用方法也就是objc_msgSend的时候，通过isa找到类对象或者元类对象进行调用

