//
//  ViewController.m
//  RunloopExpress
//
//  Created by JianRongCao on 8/1/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import "ViewController.h"
#import <CoreFoundation/CoreFoundation.h>

@interface ViewController ()
{
    BOOL end;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    //CADisplayLink 的用法
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkSelector)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    
    NSLog(@"start new thread …");
    [NSThread detachNewThreadSelector:@selector(runOnNewThread) toTarget:self withObject:nil];
    while (!end) {
        NSLog(@"runloop begin in…");
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
        NSLog(@"runloop out.");
    }
    NSLog(@"ok.");
    
    
/**
 *  关于runloop添加source的简单用法
 *  1.首先简单运行执行runlooprun函数并不会让系统停住等待事件，而是需要在运行runloop之前添加source，
 *    只有在有source的情况下线程才会停下来监听各种事件。
 *  2.runloop的使用：
 *    1）生成一个runloop source
 */
    // add send source
    CFRunLoopSourceContext src_context;
    NSError *emsg = nil ;
    // init send source context
    src_context.version = 0;
    src_context.info = @"runloop";
    src_context.retain = NULL;
    src_context.release = NULL;
    src_context.copyDescription = NULL;
    src_context.equal = NULL;
    src_context.hash = NULL;
    src_context.schedule = NULL;
    src_context.cancel = NULL;
    src_context.perform = &callbackFunc;//设置唤醒时调用的回调函数
    
    // create send source from context
    CFRunLoopSourceRef runloopSource;
    runloopSource = CFRunLoopSourceCreate(NULL, 0, &src_context);
    
    //2）将source加入线程所属的runloop中
    // add the send source into  run loop
    CFRunLoopRef threadRunLoop;
    threadRunLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(threadRunLoop ,
                       runloopSource,
                       kCFRunLoopDefaultMode);
    //3)运行runloop
    CFRunLoopRun();
    
    //4）如何调用runloop（首先可以将各个线程的runloop和source保存起来
    //将这个 Source 标记为待处理,然后手动调用 CFRunLoopWakeUp(runloop) 来唤醒 RunLoop,让其处理这个事件
    CFRunLoopSourceSignal(runloopSource); // 参数是你调用的runloop的source
    //这句话的作用时立即执行该runloop的事件，如果没有这句话系统会在空闲的时候执行刚才的runloopSource相关的事件
    CFRunLoopWakeUp(threadRunLoop);
    
//    3.如何停掉runloop退出线程
    //这个函数可以停掉runloop是线程正常退出
    CFRunLoopStop(threadRunLoop);
//    4.ios整个系统基本上是基于runloop这种架构的，ios程序的main线程整体上也是基于runloop的，各种事件的响应应该也是基于source这种思路。
  
    
//RunLoop 启动前内部必须要有至少一个 Timer/Observer/Source，所以 AFNetworking 在 [runLoop run] 之前先创建了一个新的 NSMachPort 添加进去了。通常情况下，调用者需要持有这个 NSMachPort (mach_port) 并在外部线程通过这个 port 发送消息到 loop 内；但此处添加 port 只是为了让 RunLoop 不至于退出，并没有用于实际的发送消息。
//    + (void)networkRequestThreadEntryPoint:(id)__unused object {
//        @autoreleasepool {
//            [[NSThread currentThread] setName:@"AFNetworking"];
//            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
//            [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
//            [runLoop run];
//        }
//    }
   
//    CFRunLoopSourceRef 是事件产生的地方。Source有两个版本：Source0 和 Source1。
//    
//    Source0 只包含了一个回调（函数指针），它并不能主动触发事件。使用时，你需要先调用 CFRunLoopSourceSignal(source)，将这个 Source 标记为待处理，然后手动调用 CFRunLoopWakeUp(runloop) 来唤醒 RunLoop，让其处理这个事件。App自己负责管理.
//    Source1 包含了一个 mach_port 和一个回调（函数指针），被用于通过内核和其他线程相互发送消息。这种 Source 能主动唤醒 RunLoop 的线程.使runloop不至于退出
}

void callbackFunc()
{
    NSLog(@"call when runloop wakeup!");
}

- (void)displayLinkSelector
{
//    CFRunLoopWakeUp(CFRunLoopGetCurrent());
//    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"displayLink");
}

-(void)runOnNewThread{
    NSLog(@"run for new thread …");
    sleep(5);
    end = YES;
    NSLog(@"end.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
