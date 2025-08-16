# iOS

![image-20250622133432829](C:\Users\23057\AppData\Roaming\Typora\typora-user-images\image-20250622133432829.png)

## GCD

### 同步方式：dispatch_sync(dispatch_queue_t queue,dispatch_block_t);

queue:队列

block：任务



### 异步方式：dispatch_async(dispatch_queue_t queue,dispatch_block_t);

GCD源码地址：https://github.com/swiftlang/swift-corelibs-libdispatch

GCD的队列分为2大类型

如果传入的queue为主队列，那么不会开启一个线程



### 并发队列

可以让多个任务并发（同时）执行（自动开启多个线程同时执行任务）

并发功能只有在异步函数下才有效

~~~objective-c
dispatch_queue_t queue = dispatch_get_global_queue(0,0);

dispatch_async(queue,^{});
dispatch_async(queue,^{});
~~~



### 串行队列

让任务一个接着一个执行

~~~objc
dispatch_queue_t queue = dispatch_queue_create("xxx",DISPATCH_QUEUE_SERIAL);

dispatch_async(queue,^{});
dispatch_async(queue,^{});
~~~



### 同步、异步、并发、串行

同步和异步的主要影响是能不能开启新的线程

同步：在当前线程中执行任务，不具备开启新线程的能力

异步：在新的线程中执行任务，具备开启新线程的能力



并发和串行的主要影响是：任务的执行方式

并发：多个任务并发（同时）执行

串行：一个任务执行完毕后，再执行下一个任务



![image-20250622140031791](C:\Users\23057\AppData\Roaming\Typora\typora-user-images\image-20250622140031791.png)

、

### 使用sync函数往当前串行队列中添加任务，会卡住当前的串行队列（产生死锁）

~~~objc
-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"任务1");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue,^{
        NSLog(@"任务2");
    });
    
    NSLog(@"任务3");
}
~~~

这个代码会产生一个死锁的问题，因为在主队列中，viewDidLoad是一个任务，队列中又放入任务2这个任务，但是任务viewDidLoad执行完需要执行完任务2，但是任务2又需要等待viewDidLoad执行完，从而导致的死锁问题



~~~objc
-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"任务1");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue,^{
        NSLog(@"任务2");
    });
    
    NSLog(@"任务3");
}
~~~

不会产生死锁，async是异步的，sync是立马在当前线程执行，打印结果：任务1、任务3、任务2



~~~objc
-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("xxx",DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue,^{
        NSLog(@"任务2");
        dispatch_sync(queue,^{
            NSLog(@"任务3");
        });
        
        NSLog(@"任务4");
    });
    
    NSLog(@"任务5");
}
~~~

会产生死锁，流程：

主队列：viewDidLoad

打印：任务1，任务5，任务2

xxx队列：8-13行代码为一个任务放到xxx队列中（假设名为a），先会打印任务2，但是9-11行代码为同步的需要等待a的代码完成，但是a的代码又需要等待9-13行代码执行完，从而导致的死锁



~~~objc
-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("xxx",DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("xxx2",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue,^{
        NSLog(@"任务2");
        dispatch_sync(queue2,^{
            NSLog(@"任务3");
        });
        
        NSLog(@"任务4");
    });
    
    NSLog(@"任务5");
}
~~~

不会产生死锁



~~~objc
-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("xxx",DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("xxx2",DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue,^{
        NSLog(@"任务2");
        dispatch_sync(queue2,^{
            NSLog(@"任务3");
        });
        
        NSLog(@"任务4");
    });
    
    NSLog(@"任务5");
}
~~~

不会产生死锁



~~~objc
-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("xxx",DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue,^{
        NSLog(@"任务2");
        dispatch_sync(queue,^{
            NSLog(@"任务3");
        });
        
        NSLog(@"任务4");
    });
    
    NSLog(@"任务5");
}
~~~

不会产生死锁、、



#### 总结

使用sync函数往当前串行队列中添加任务，会卡住当前的串行队列（产生死锁）



### 面试题

~~~objc
-(void)test{
    NSLog(@"2");
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    
    dispatch_async(queue,^{
        NSLog(@"1");
        [self performSelector:@selector(test) withObject:nil];
        NSLog(@"3");
    })
}
~~~

这个是能打印的，打印：1、2、3，实际是通过objc_msgSend调用的



~~~objc
-(void)test{
    NSLog(@"2");
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    
    dispatch_async(queue,^{
        NSLog(@"1");
        [self performSelector:@selector(test) withObject:nil afterDelay:.0];
        NSLog(@"3");
    });
}
~~~

这个是打印不了2的，打印：1、3，这个是通过Runloop调用的，向runloop添加一个NSTimer定时器



~~~objc
-(void)test{
    NSLog(@"2");
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"1");
    [self performSelector:@selector(test) withObject:nil afterDelay:.0];
    NSLog(@"3");
}
~~~

这个是能打印的，主线程中是有runloop的



~~~objc
-(void)test{
    NSLog(@"2");
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    
    dispatch_async(queue,^{
        NSLog(@"1");
        [self performSelector:@selector(test) withObject:nil afterDelay:.0];
        NSLog(@"3");
    });
    
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSData distantFuture]];
}
~~~

打印：1、3、2

子线程默认没有启动Runloop



### GunStep

GNUstep是GNU计划的项目之一，它将Cocoa的OC库重新开源实现了一遍

源码地址：

虽然GNUStep不是苹果官方源码，但还是具有一定的参考价值



根据GunStep的代码 [self performSelector:@selector(test) withObject:nil afterDelay:.0];  这个代码是拿到runloop往里面加东西，并没有启动runloop（runmode）



~~~objc
-(void)test{
    NSLog(@"2");
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSThread* thread = [[NSThread alloc] initWithBlock:^{
       NSLog(@"1"); 
    }];
    
    [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
}
~~~

这个会打印1，但是会报错，没有启动runloop，线程打印完1就退出了再performSelector就会报错



~~~objc
-(void)test{
    NSLog(@"2");
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSThread* thread = [[NSThread alloc] initWithBlock:^{
       NSLog(@"1"); 
        
       [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
       [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSData distantFuture]];
    }];
    
    [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
}
~~~

这个会打印1,2，启动了runloop





用GCD实现：异步并发执行任务1、2，等任务1、2都执行完后再回到主线程中执行任务3

~~~objc
-(void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("myqueue",DISPATCH_QUEUE_CONCURRENT);
    
    // 添加异步任务
    dispatch_group_async(group,queue,^{
        for(int i =0;i<5;i++){
            NSLog(@"任务1-%@",[NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group,queue,^{
        for(int i =0;i<5;i++){
            NSLog(@"任务2-%@",[NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group,queue,^{
        dispatch_async(dispatch_get_main_queue(),^{
            for(int i =0;i<5;i++){
            	NSLog(@"任务3-%@",[NSThread currentThread]);
        	}
        })
    });
    
    /// 或者
    dispatch_group_notify(group,dispatch_get_main_queue(),^{  
        for(int i =0;i<5;i++){
            NSLog(@"任务3-%@",[NSThread currentThread]);
        }
    });
    
    
    dispatch_group_notify(group,queue,^{  
        for(int i =0;i<5;i++){
            NSLog(@"任务3-%@",[NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group,queue,^{  
        for(int i =0;i<5;i++){
            NSLog(@"任务4-%@",[NSThread currentThread]);
        }
    });
}
~~~





## 线程同步

OSSpinLock

os_unfair_lock

pthread_mutex

dispatch_semaphore

dispatch_queue(DISPATCH_QUEUE_SERIAL)

NSLock

NSRecursiveLock

NSCondition

NSConditionLock

@synchronized



### OSSpinLock  自旋锁

~~~objc
// 初始化锁
OSSpinLock lock = OS_SPINLOCK_INIT;

// 加锁
OSSpinLockLock(&lock);

// 解锁
OSSpinLockUnLock(&lock);
~~~

等待的线程会处于忙等状态，一直占用CPU的资源

目前已经不再安全，可能会出现优先级反转的问题

如果等待锁的线程优先级比较高，它会一直占用CPU的资源，优先级比较低的线程就无法释放锁

iOS10.0后就不推荐使用了

头文件：#import<libkern/OSAtomic.h>



### os_unfair_lock

os_unfair_lock用于取代不安全的OSSpinLock，从iOS10开始才支持

从底层调用看，等待os_unfair_lock锁的线程会处于休眠状态，并非忙等

头文件：#import<os/lock.h>

~~~objc
os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;

os_unfair_lock_trylock(&lock);

os_unfair_lock(&lock);

os_unfair_lock_unlock(&lock);
~~~



### pthread_mutex

mutex叫做互斥锁，等待线程会处于休眠状态

头文件：#import<pthread.h>

~~~objc
pthread_mutexatt_t attr;
pthread_mutexattr_init(&attr);
pthread_mutexattr_settype(&attr,PTHREAD_MUTEX_NORMAL);
pthread_mutex_t mutex;
pthread_mutex_init(&mutex,&attr);
pthread_mutex_trylock(&mutex);
pthread_mutex_lock(&mutex);
pthread_mutex_unlock(&mutex);
pthread_mutexattr_destory(&attr);
pthread_mutex_destory(&mutex);
~~~

~~~objc
#define PTHREAD_MUTEX_NORMAL   0
#define PTHREAD_MUTEX_ERRORCHECK 1
#define PTHREAD_MUTEX_RECURSIVE  2
#define PTHREAD_MUTEX_DEFAULT  PTHREAD_MUTEX_NORMAL
~~~



~~~objc
pthread_mutexattr_t attr;
pthread_mutexattr_init(&attr);
pthread_mutexattr_settype(&_mutex,&attr);
pthread_mutexattr_destory(&attr);
~~~





### pthread_mutex_cond

~~~objc
pthread_mutex_t mutex;
pthread_mutex_init(&mutex,NULL);
pthread_cond_t condition;
pthread_cond_init(&condition,NULL);
pthread_cond_wait(&condition,&mutex);
pthread_cond_signal(&condition);
pthread_cond_broadcast(&condition);
pthread_mutex_destory(&mutex);
pthread_cond_destory(&condition);
~~~



### NSLock、NSRecursiveLock

NSLock是对mutex普通锁的封装

~~~objc
@interface NSLock : NSObject<NSLocking> {
- (BOOL) tryLock;
- (BOOL) lockBeforeDate:(NSDate*)limit;
}
~~~

~~~objc
@protocol NSLocking
- (void)lock;
- (void)unlock;
@end
~~~

~~~objc
NSLock *lock = [[NSLock alloc] init];
~~~



NSRecursiveLock也是对mutex递归锁的封装，API跟NSLock基本一致





### NSCondition

NSCondition是对mutex和cond的封装

~~~objc
@interface NSCondition : NSObject <NSLocking> {
- (void) wait;
- (BOOL) waitUntilDate:(NSDate *)limit;
- (void) signal;
- (void) broadcast;
}
~~~





### NSConditionLock

NSConditionLock是对NSCondition的进一步封装，可以设置具体的条件值

~~~objc
@interface NSConditionLock : NSObject<NSLocking> {
- (instancetype)initWithCondition:(NSInteger)condition;
@property (readonly) NSInteger condtion;
- (void)lockWhenCondition:(NSInteger)condtion;
- (BOOL)tryLock;
- (BOOL)tryLockWhenCondition:(NSInteger)condtion;
- (void)unlockWithCondition:(NSInteger)condtion;
- (BOOL)lockBeforeDate:(NSDate*)limit;
- (BOOL)lockWhenCondition:(NSInteger)condtition beforeDate:(NSDate*)limit;
}
@end
~~~







### dispatch_queue

直接使用GCD的串行队列，也是可以实现线程同步的

~~~objc
dispatch_queue_t queue = dispatch_queue_create("xxx",DISPATCH_QUEUE_SERIAL);
dispatch_sync(queue,^{
    
});
~~~





### dispatch_semaphore

semaphore叫做信号量

信号量的初始值，可以用来控制线程并发访问的最大数量

信号量的初始值为1，代表同时允许1条线程访问资源，保证线程同步

~~~objc
int value = 1;
dispatch_semaphore_t semaphore = dispatch_semaphore_create(value);
dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
dispatch_semaphore_signal(semaphore);
~~~



### synchronized

@synchronized是对mutex递归锁的封装

~~~objc
@synchronized(){
    
}
()括号内写一个对象，来进行加锁，
~~~



### 性能排序

![image-20250810195337367](C:\Users\23057\AppData\Roaming\Typora\typora-user-images\image-20250810195337367.png)





### pthread_rwlock

