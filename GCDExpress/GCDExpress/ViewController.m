//
//  ViewController.m
//  GCDExpress
//
//  Created by JianRongCao on 7/21/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSMutableArray *mArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat positionX = [UIScreen mainScreen].bounds.size.width/2.0 - 90;
    CGFloat width = 200;
    CGFloat height = 40;
    UIButton *button = [self createButton:@"信号量的处理"
                                   action:@selector(queryMainThread:)
                                    frame:CGRectMake(positionX, 60, width, height)];
    [self.view addSubview:button];
    
    button = [self createButton:@"queueExeInfo"
                         action:@selector(queueExeInfo)
                          frame:CGRectMake(positionX, 120, width, height)];
    [self.view addSubview:button];
    
    button = [self createButton:@"queueCreateWithSpecific"
                         action:@selector(queueCreateWithSpecific)
                          frame:CGRectMake(positionX, 180, width, height)];
    [self.view addSubview:button];
    
    button = [self createButton:@"queueCreateWithSpecific"
                         action:@selector(queueCreateWithSpecific)
                          frame:CGRectMake(positionX, 240, width, height)];
    [self.view addSubview:button];

    button = [self createButton:@"dispatchBarrier"
                         action:@selector(dispatchBarrier)
                          frame:CGRectMake(positionX, 300, width, height)];
    [self.view addSubview:button];
    
    button = [self createButton:@"dispatch_apply"
                         action:@selector(dispatch_apply)
                          frame:CGRectMake(positionX, 360, width, height)];
    [self.view addSubview:button];
    
    button = [self createButton:@"dispatchGroup"
                         action:@selector(dispatchGroup)
                          frame:CGRectMake(positionX, 420, width, height)];
    [self.view addSubview:button];

    
    NSBlockOperation *op = [self start];
    NSInvocationOperation *opInvocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(showOperation:) object:@"message"];
//    [opInvocation setQueuePriority:NSOperationQueuePriorityHigh];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperation:op];
    [queue addOperation:opInvocation];
//    [opInvocation start];
    [op setCompletionBlock:^{
        NSLog(@"execute finished");
    }];
    NSLog(@"%@",op);
    
    
    
    
    
    //enumerateObjectsUsingBlock 块的使用。   以及
    NSArray *array = @[@"1",@"2",@"3",@"4"];
    [array enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
    }];
    
    NSDictionary *dic = @{@"key1":@"value1",@"key2":@"value2",@"key3":@"value3"};
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"%@-%@",key,obj);
    }];
    
    
    mArray = [[NSMutableArray alloc] init];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [mArray addObject:@"1111111"];
        NSLog(@"%@",mArray);
    });
    
    for (int i = 0; i<9999; i++) {
        [mArray addObject:@(i)];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [mArray enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%@",obj);
        }];
    });
    
    NSLog(@"哈哈哈");
    
    
    CFArrayRef cfArray = (__bridge CFArrayRef)(mArray);
    CFArrayGetCount(cfArray);
}

- (void)showOperation:(NSString *)message
{
    NSLog(@"%@",message);
}

/**
 *  启动一个BlockOperation,  (此队列是非并发的，只有加入到NSOperationQueue时，才是并发的)
 *
 *  @return 返回生成的BlockOperation
 */
- (NSBlockOperation *)start
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block");
    }];
    [operation addExecutionBlock:^{
        NSLog(@"start 1 op");
        sleep(1);
        NSLog(@"end 1 op");
    }];
    
    [operation addExecutionBlock:^{
        NSLog(@"start 2 op");
        sleep(1);
        NSLog(@"end 2 op");
    }];
//    [operation start];
    NSLog(@"return op");
    
    return operation;
}

/**
 *  串行队列和并行队列在异步情况下的执行情况
 */
- (void)queueExeInfo
{
    /**
     *  1.异步下,同一个队列里面串行还是串行，不同队列里面,串行就是并行
     *          CONCURRENT队列不管在不在一个queue里面，都是并行
     *  2.同步下，全部按代码顺序执行
     */
    dispatch_queue_t queue1 = dispatch_queue_create("com.company.queue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue2 = dispatch_queue_create("com.company.queue2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue1, ^{ // block1
        for (int i = 0; i < 10; i ++) {
            NSLog(@"1st async queue1");
        }
    });
    dispatch_async(queue2, ^{ // block2
        for (int i = 0; i < 5; i ++) {
            NSLog(@"2nd async queue2");
        }
    });
    dispatch_async(queue2, ^{    // block3
        for (int i = 0; i < 5; i ++) {
            NSLog(@"3rd async queue3");
        }
    });
}

/**
 *  队列的不同类别和创建方式，
 *  以及dispatch_queue_set_specific和dispatch_get_specific的作用
 */
- (void)queueCreateWithSpecific
{
    NSLog(@"start");
    //DISPATCH_QUEUE_CONCURRENT   DISPATCH_QUEUE_SERIAL
    //第一种创建队列的办法
    dispatch_queue_t queue = dispatch_queue_create("com.suning.queue", DISPATCH_QUEUE_SERIAL);
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    //    将一个第一个参数的队列放到后面的队列处理。  设置为同一个优先级。
    //    前面的队列通过 dispatch_suspend暂停，不会影响后面的队列，而后面的队列dispatch_suspend，则会导致前面的队列暂停执行
    dispatch_set_target_queue(dispatch_get_main_queue(), queue);
    dispatch_sync(queue, ^{
        dispatch_async(queue, ^{
            NSLog(@"async");
        });
        NSLog(@"queue");
    });
    NSLog(@"end");
    
    //第二种创建队列的办法，主要是可以设置队列的优先级
    dispatch_queue_attr_t cusAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_BACKGROUND, -1);
    dispatch_queue_t cusqueue = dispatch_queue_create("com.suning.cusqueue", cusAttr);
    static void *queueKey1 = "suning";
    dispatch_queue_set_specific(cusqueue, queueKey1, &queueKey1, NULL);
    
    dispatch_sync(cusqueue, ^{
        dispatch_async(cusqueue, ^{
            NSLog(@"cus async");
        });
        if (dispatch_get_specific(queueKey1)) {
            //当前队列是queue1队列，所以能取到queueKey1对应的值，故而执行
            NSLog(@"1. 当前线程是: %@, 当前队列是: %@ 。",[NSThread currentThread],dispatch_get_current_queue());
        }
        NSLog(@"cus queue");
    });
    NSLog(@"cus end");
    
    if (dispatch_get_specific(queueKey1)) {
        //当前队列是主队列，不是cusqueue队列，所以取不到queueKey1对应的值，故而不执行
        NSLog(@"2. 当前线程是: %@, 当前队列是: %@ 。",[NSThread currentThread],dispatch_get_current_queue());
        [NSThread sleepForTimeInterval:1];
    }else{
        NSLog(@"3. 当前线程是: %@, 当前队列是: %@ 。",[NSThread currentThread],dispatch_get_current_queue());
        [NSThread sleepForTimeInterval:1];
    }
}

/**
 *  dispatch_barrier_async的作用
 *  主要是在串行队列下，保证只有一个任务执行。
 */
- (void)dispatchBarrier
{
    //    dispatch_barrier_async 作用是在并行队列中，等待前面并行操作完成才继续执行下面的操作，这里是并行
    //    dispatch_barrier_async中的操作，(现在就只会执行这一个操作)执行完成后，即输出
    //    最后该并行队列恢复原有执行状态，继续并行执行
    //    由结果可以看到，dispatch_barrier_async 线程内部是逐一执行的，而线程之间是异步执行的
    //    而dispatch_barrier_sync 是所有的线程同一同步执行
    dispatch_queue_t queue11 = dispatch_queue_create("com.suning.smart1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue22 = dispatch_queue_create("com.suning.smart2", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_barrier_async(queue11, ^{
        sleep(2);
        for (int i = 0; i < 10; i++) {
            sleep(1);
            NSLog(@"queue11 %d",i);
        }
    });
    
    dispatch_async(queue11, ^{
        for (int i = 0; i < 10; i++) {
            NSLog(@"queue11 ++++++");
        }
    });
    
    dispatch_barrier_async(queue11, ^{
        sleep(2);
        for (int i = 0; i < 10; i++) {
            sleep(1);
            NSLog(@"queue22 %d",i);
        }
    });
    
    dispatch_async(queue11, ^{
        for (int i = 0; i < 10; i++) {
            NSLog(@"queue11 ++++++");
        }
    });
    
    dispatch_barrier_async(queue11, ^{
        sleep(2);
        for (int i = 0; i < 10; i++) {
            sleep(1);
            NSLog(@"queue33 %d",i);
        }
        NSLog(@"3");
    });
    
    dispatch_barrier_async(queue11, ^{
        sleep(2);
        NSLog(@"4");
    });
    
    dispatch_barrier_async(queue22, ^{
        sleep(2);
        NSLog(@"queue2");
    });
    
    dispatch_barrier_async(queue22, ^{
        sleep(2);
        NSLog(@"queue2 - 1");
    });
    
    dispatch_barrier_async(queue22, ^{
        sleep(2);
        NSLog(@"queue2 - 2");
    });
}

/**
 *  dispatch_apply的使用
 *  GCD  dispatch_apply, 作用是把指定次数指定的block添加到queue中, 第一个参数是迭代次数，第二个是所在的队列，第三个是当前索引，
 *  dispatch_apply可以利用多核的优势，所以输出的index顺序不是一定的
 *  dispatch_apply 和 dispatch_apply_f 是 '同步'函数,会'阻塞'当前线程直到所有循环迭代执行完成。 *****  重要。
 *  当提交到并发queue时,循环迭代的执行顺序是不确定的
 *
 */
- (void)dispatch_apply
{
    dispatch_queue_t queue1 = dispatch_queue_create("com.company.queue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue2 = dispatch_queue_create("com.company.queue2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_apply(5, queue1, ^(size_t index) {
        NSLog(@"apply  CONCURRENT %zu",index);
    });
    
    dispatch_apply(5, queue2, ^(size_t index) {
        NSLog(@"apply  SERIAL %zu",index);
    });
    
    NSLog(@"apply done");
}
/**
 *  dispatch_group_t 的使用。
 *  dispatch_group_enter(<#dispatch_group_t group#>)
 *  dispatch_group_leave(<#dispatch_group_t group#>) 成对出现。   进入组开始执行和离开组
 */
- (void)dispatchGroup
{
    dispatch_queue_t queue1 = dispatch_queue_create("com.suning.smart", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("com.suning.smart", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue3 = dispatch_queue_create("com.suning.smart", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue4 = dispatch_queue_create("com.suning.smart", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue1, ^{
        NSLog(@"queue1");
    });
    
    dispatch_group_async(group, queue2, ^{
        NSLog(@"queue2");
    });
    
    dispatch_group_async(group, queue3, ^{
        NSLog(@"queue3");
    });
    
    dispatch_group_async(group, queue4, ^{
        NSLog(@"queue4");
    });
    
    dispatch_queue_t main = dispatch_queue_create("com.suning.main", DISPATCH_QUEUE_SERIAL);
    //group里面所有的线程执行完成之后可以获取完成回调 dispatch_group_notify
    dispatch_group_notify(group, main, ^{
        NSLog(@"group finished");
    });
}

/**
 *  信号量的处理
 *
 *  @param sender button
 */
- (void)queryMainThread:(UIButton *)sender
{
    //申请信号量。   参数代表可以有几个并发。
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t queue = dispatch_queue_create("com.suning.sepahore", DISPATCH_QUEUE_CONCURRENT);
    //    dispatch_queue_t queue = dispatch_queue_create("com.suning.sepahore", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"car 1 here");

        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
        //dispatch_semaphore_wait   等待信号量。后面的参数为等待时间，时间到了之后，不管是否有信号量  均执行
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        int sum = 0;
        for (int idx = 0; idx < 10; idx++) {
            sum += idx;
            NSLog(@"sum1 -- > %d",idx);
        }
        //释放一个信号，让信号总量+1.
        dispatch_semaphore_signal(semaphore);
        NSLog(@"car 1 go");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"car 2 here");
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC);
        dispatch_semaphore_wait(semaphore, time);
        int sum = 0;
        for (int idx = 0; idx < 10; idx++) {
            sum += idx;
            NSLog(@"sum2 -- > %d",idx);
        }
        dispatch_semaphore_signal(semaphore);
        NSLog(@"car 2 go");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"car 3 here");
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
        dispatch_semaphore_wait(semaphore, time);
        int sum = 0;
        for (int idx = 0; idx < 10; idx++) {
            sum += idx;
            NSLog(@"sum3 -- > %d",idx);
        }
        dispatch_semaphore_signal(semaphore);
        NSLog(@"car 3 go");
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    for (int idx = 0; idx < 10; idx++) {
        usleep(500000);
        NSLog(@"sum4 idx = %d",idx);
    }
    dispatch_semaphore_signal(semaphore);
}

- (UIButton *)createButton:(NSString *)title action:(SEL)sel frame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13.0 weight:10]];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    button.frame = frame;
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpOutside];
    return button;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    NSLog(@"%@",NSStringFromCGPoint([touch locationInView:self.view]));
    NSLog(@"remove");
    [mArray removeAllObjects];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"remove");
    [mArray removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
