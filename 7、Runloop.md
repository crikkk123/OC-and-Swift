# runloop

运行循环，在程序运行过程中循环做一些事情

比如：定时器、PerformSelector
     
     CGD Async Main Queue
     
     事件响应，手势识别、界面刷新
     
     网络请求
     
     AutoreleasePool
     
     
     
如果没有runloop，程序在运行完主函数后就会结束

<img width="1028" alt="image" src="https://github.com/user-attachments/assets/0becb24f-278b-4cf9-8c4b-5df581d6efa8" />


切换mode是在do-while里面做的，所以切换mode不会导致程序的退出



~~~text
runloop与线程：
每条线程都有唯一的一个与之对应的Runloop对象
Runloop保存在一个全局的Dictionary里，线程作为key，runloop作为value
线程刚创建时并没有runloop对象，runloop会在第一次获取它时创建
runloop会在线程结束时销毁
主线程的runloop已经自动获取（创建），子线程默认没有开启Runloop
~~~



~~~text
获取runloop对象
Foudation：
[NSRunLoop currentRunloop];   // 获取当前线程的runloop对象
[NSRunLoop mainRunLoop];      // 获取主线程的runloop对象

core Foundation
CFRunLoopGetCurrent();        // 获取当前线程的runloop对象
CFRunLoopGetMain();           // 获取主线程的runloop对象
~~~


![image](https://github.com/user-attachments/assets/f5c6c54a-c1a2-45ef-bd6d-0689ad084d56)


runloop包含很多个mode，mode里的source0、source1、observers、timers分别是CFRunLoopSourceRef、CFRunLoopSourceRef、CFRunLoopObserverRef、CFRunLoopTimersRef类型的数组


~~~text
CFRunLoopModeRef：
CFRunLoopModeRef代表Runloop的运行模式
一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer
RunLoop启动时只能选择其中一个Mode，作为currentMode
如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入，不同组的Source0/Source1/Timer/Observer能分隔开来，互不影响
如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出


比如在滚动的时候切换到滚动模式的Mode，非滚动模式下的默认模式，这样做的好处是滚动的时候只处理滚动的事件即可，默认情况下处理默认的情况
~~~


~~~text
CFRunLoopModeRef：
常见的2种Mode
kCFRunLoopDefaultMode（NSDefaultRunLoopMode）：App的默认Mode，通常主线程是在这个Mode下运行

UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
~~~


~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%p  %p",[NSRunLoop currentRunLoop],[NSRunLoop mainRunLoop]);
    NSLog(@"%p  %p",CFRunLoopGetCurrent(), CFRunLoopGetMain());
}

@end

~~~




![image](https://github.com/user-attachments/assets/8e4a50c5-fe93-436f-b502-e6d795ad7f3c)

可以看到两个的地址是不同的，因为上面的是对下面的一层封装，也就是OC封装了一下C语言的对象


~~~text
RunLoop的运行逻辑
Source0:触摸事件处理， performSelector:onThread:

Source1:基于Port的线程间通信，系统事件捕捉(点击事件最开始由source1捕捉，封装为Source0再处理)

Timers：NSTimer、performSelector:withObject:afterDelay:

Observers:用于监听RunLoop的状态，UI刷新（BeforeWaiting）、Autorelease pool（BeforeWaiting）

01、通知Observers：进入Loop
02、通知Observers：即将处理Timers
03、通知Observers：即将处理Sources
04、处理Blocks
05、处理Source0（可能会再次处理Blocks）
06、如果存在Source1，就跳转到第8步
07、通知Observers：开始休眠（等待消息唤醒）
08、通知Observers：结束休眠（被某个消息唤醒）
    01> 处理Timer
    02> 处理GCD Async To Main Queue
    03> 处理Source1
09、处理Blocks
10、根据前面的执行结果，决定如何操作
    01> 回到第02步
    02> 退出Loop
11、通知Observers：退出Loop
~~~



~~~objective-c
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%p",__func__);
}

@end

~~~
在NSLog打个断点，打印堆栈：
~~~text
(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
  * frame #0: 0x0000000102f0d714 temp`-[ViewController touchesBegan:withEvent:](self=0x0000000103d130f0, _cmd="touchesBegan:withEvent:", touches=1 element, event=0x0000600003b1c000) at ViewController.m:22:5
    frame #1: 0x0000000185b02d90 UIKitCore`forwardTouchMethod + 352
    frame #2: 0x0000000185b10e3c UIKitCore`-[UIWindow _sendTouchesForEvent:] + 480
    frame #3: 0x0000000185b12438 UIKitCore`-[UIWindow sendEvent:] + 2840
    frame #4: 0x0000000185af20f8 UIKitCore`-[UIApplication sendEvent:] + 376
    frame #5: 0x0000000185b7c25c UIKitCore`__dispatchPreprocessedEventFromEventQueue + 1156
    frame #6: 0x0000000185b7f1ec UIKitCore`__processEventQueue + 5592
    frame #7: 0x0000000185b774fc UIKitCore`updateCycleEntry + 156
    frame #8: 0x000000018505d28c UIKitCore`_UIUpdateSequenceRun + 76
    frame #9: 0x0000000185a07670 UIKitCore`schedulerStepScheduledMainSection + 168
    frame #10: 0x0000000185a06aa8 UIKitCore`runloopSourceCallback + 80
    frame #11: 0x000000018041b7c4 CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
    frame #12: 0x000000018041b70c CoreFoundation`__CFRunLoopDoSource0 + 172
    frame #13: 0x000000018041ae70 CoreFoundation`__CFRunLoopDoSources0 + 232
    frame #14: 0x00000001804153b4 CoreFoundation`__CFRunLoopRun + 788
    frame #15: 0x0000000180414c24 CoreFoundation`CFRunLoopRunSpecific + 552
    frame #16: 0x000000019020ab10 GraphicsServices`GSEventRunModal + 160
    frame #17: 0x0000000185ad82fc UIKitCore`-[UIApplication _run] + 796
    frame #18: 0x0000000185adc4f4 UIKitCore`UIApplicationMain + 124
    frame #19: 0x0000000102f0d9dc temp`main(argc=1, argv=0x000000016cef1b18) at main.m:17:12
    frame #20: 0x0000000102f35410 dyld_sim`start_sim + 20
    frame #21: 0x000000010300a274 dyld`start + 2840
~~~
可以看到__CFRunLoopDoSource0，说明由source0处理




