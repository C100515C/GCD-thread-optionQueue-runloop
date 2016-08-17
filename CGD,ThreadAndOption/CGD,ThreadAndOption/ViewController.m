//
//  ViewController.m
//  CGD,ThreadAndOption
//
//  Created by chenchen on 16/8/17.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import "ViewController.h"

#define kURL @"http://www.iyi8.com/uploadfile/2014/0506/20140506085929652.jpg" 
#define kURL1 @"http://www.fengdu100.com/uploads/allimg/160815/1545334116-9.png"
@interface ViewController ()
{
    int             _tickets;
    int             _count;
    
    NSThread        *_threadOne;
    NSThread        *_threadTwo;
    NSThread        *_threadThree;
    NSThread         *_runThread;
    NSCondition     *_condition;
    
    NSLock          *_lock;
    
    UIImage      *_image;
}
@property (weak, nonatomic) IBOutlet UIImageView *pic;
@property (weak, nonatomic) IBOutlet UILabel *picTitle;

@property (strong,nonatomic) NSMutableArray *arr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self threadTest];
//    [self threadLoadPic];
//    [self optionTest];
//    [self GCDTest];
    [self CGDTestGroup];
//    [self GCD];
    [self runloopTest];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self stopRunloop];
    [self stopRunloop1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray*)arr{
    if (_arr==nil) {
        _arr = [NSMutableArray array];
    }
    return _arr;
}

-(void)loadPic:(NSString*)url{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData:data];
    
    if (image==nil) {
        [self updateImage:image];
    }else{
        [self performSelectorOnMainThread:@selector(updateImage:) withObject:image waitUntilDone:YES];
    }
}
-(void)updateImage:(UIImage*)image{
    self.pic.image = image;
}

- (void)run
{
    while (true) {
        //上锁
        [_lock lock];
        if (_tickets > 0) {
            [NSThread sleepForTimeInterval:0.09];
            _count = 200 - _tickets;
            NSLog(@"当前物品名称:%d,售出数量:%d,线程名: %@", _tickets, _count, [[NSThread currentThread] name]);
            _tickets--;
        }else{
            break;
        }
        
        [_lock unlock];
    }
}
- (void)run3
{
    while (true) {
        [_condition lock];
        [NSThread sleepForTimeInterval:3];
        NSLog(@"当前物品名称:%d,售出数量:%d,线程名-=-==: %@", _tickets, _count, [[NSThread currentThread] name]);
        
        [_condition signal];
        [_condition unlock];
    }
}

#pragma mark - runloop 常驻线程 

-(void)runloop1{
    _threadOne = [[NSThread alloc] initWithTarget:self selector:@selector(changeImage:) object:nil];
    _threadOne.name = @"test1.runloop";
    [_threadOne start];
}
-(void)changeImage:(id)obj{
    @autoreleasepool {
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(changePic:) userInfo:nil repeats:YES];
        
        [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
        
        CFRunLoopRun();
    }
}

-(void)changePic:(id)obj{
    int x = 0;
    x = arc4random()%2;
//
    dispatch_async(dispatch_get_main_queue(), ^{
    
        self.pic.image = (UIImage*)self.arr[x];
        
    });
    NSLog(@"ll=%d",x);
}
-(void)stopRunloop1{
    [self performSelector:@selector(stop1) onThread:_threadOne withObject:nil waitUntilDone:YES];
    
}
- (void)stop1{
    NSLog(@"stop1");
    // self.shouldKeepRunning = NO;
    CFRunLoopStop(CFRunLoopGetCurrent());
}
/*****************/
-(void)runloopTest{
    _runThread = [[NSThread alloc] initWithTarget:self selector:@selector(change:) object:nil];
    _runThread.name = @"test.runloop";
    [_runThread start];
    
//    [self performSelector:@selector(changeTitle:) onThread:_runThread withObject:nil waitUntilDone:YES];
}

-(void)change:(id)obj{
    @autoreleasepool {
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//        NSPort *port = [NSPort port];
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(changeColor:) userInfo:nil repeats:YES];
//        [runloop addPort:port forMode:NSDefaultRunLoopMode];//runloop 这里的 Port 用来维持 runloop 的运行，根据官方文档的描述，如果 runloop 中没有任何 modeItem，就不会启动，而是立刻退出。之所以选择作为属性而不是临时变量，是因为我发现每次调用 [NSMachPort port] 方法都会占用内存，原因暂时不清楚
        [runloop addTimer:timer forMode:NSDefaultRunLoopMode];

        CFRunLoopRun();
    }
}

-(void)changeTitle:(id)obj{
//    [self performSelector:@selector(changeColor:) withObject:nil afterDelay:1];
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(changeColor:) userInfo:nil repeats:YES];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
    
}
-(void)changeColor:(id)obj{
    int x,y,z;
    
    x = arc4random()%100;
    y = arc4random()%255;
    z = arc4random()%50;
    UIColor *color = [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:1];
    dispatch_async(dispatch_get_main_queue(), ^{
    
        self.picTitle.backgroundColor = color;
        
    });
    NSLog(@"1=%d=%d=%d",x,y,z);
}

-(void)stopRunloop{
    [self performSelector:@selector(stop) onThread:_runThread withObject:nil waitUntilDone:YES];

}
- (void)stop{
    NSLog(@"stop");
    // self.shouldKeepRunning = NO;
    CFRunLoopStop(CFRunLoopGetCurrent());
}
#pragma mark -NSthread test
-(void)threadTest{
    _tickets    = 200;
    _count      = 0;
    _lock       = [[NSLock alloc] init];
    
    //锁对象
    _condition = [[NSCondition alloc] init];
    //线程1
    _threadOne = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    _threadOne.name = @"thread-1";
    [_threadOne start];
    
    //线程2
    _threadTwo = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    _threadTwo.name = @"thread-2";
    [_threadTwo start];
    
    //线程3
    _threadThree = [[NSThread alloc] initWithTarget:self selector:@selector(run3) object:nil];
    _threadThree.name = @"thread-3";
    [_threadThree start];
    //run  如果没有线程同步的lock，物品售出数量就会出现重复导致数据竞争不同步问题.加上lock之后线程同步保证了数据的正确性。
}

-(void)threadLoadPic{
    [NSThread detachNewThreadSelector:@selector(loadPic:) toTarget:self withObject:kURL];//开启一个新线程，并且自动开启无需手动开启和清理
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadPic:) object:kURL1];
    [thread start];
}

#pragma mark - option
-(void)optionTest{
    NSInvocationOperation *option = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadPic:) object:kURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *option1 = [NSBlockOperation blockOperationWithBlock:^{
        [self loadPic:kURL1];
    }];
    
    [option addDependency:option1];//option 从属option1， 先执行option1
    [queue addOperation:option];
    [queue addOperation:option1];

//    [queue addOperations:@[option,option1] waitUntilFinished:NO];
    //更多操作 可以去看api operation 操作更灵活 自由
}

#pragma mark- CGD test
-(void)GCDTest{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:kURL]];
        UIImage *image = [UIImage imageWithData:data];
        
        if (image!=nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pic.image = image;
            });
        }
    });
    
    dispatch_async(queue, ^{
        NSData *data1 = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:kURL1]];
        UIImage *image1 = [UIImage imageWithData:data1];
        if (image1!=nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pic.image = image1;

            });
        }
    });
}

-(void)CGDTestGroup{
    //此方法可以实现监听一组任务是否完成，如果完成后通知其他操作(如界面更新),此方法在下载附件时挺有用，
    //在搪行几个下载任务时，当下载完成后通过dispatch_group_notify通知主线程下载完成并更新相应界面
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:0.09];
        
        NSLog(@"group1");
        NSURL * url = [NSURL URLWithString:kURL];
        NSData * data = [[NSData alloc]initWithContentsOfURL:url];
        [self.arr addObject: [[UIImage alloc]initWithData:data]];
        
        
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:0.09];
        NSURL * url = [NSURL URLWithString:kURL1];
        NSData * data = [[NSData alloc]initWithContentsOfURL:url];
        [self.arr addObject: [[UIImage alloc]initWithData:data]];

        NSLog(@"group2");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:0.09];
        NSLog(@"group3");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"updateUi");
        
        self.pic.image = self.arr[0];
        
        [self runloop1];

        
    });
}

-(void)GCD{
    
    dispatch_queue_t queue = dispatch_queue_create("gcd.test.com", DISPATCH_QUEUE_CONCURRENT);//DISPATCH_QUEUE_CONCURRENT 并行队列  DISPATCH_QUEUE_SERIAL 串行队列
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async1");
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async2");
    });
    //是在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行
//    dispatch_barrier_async(queue, ^{
//        NSLog(@"dispatch_barrier_async");
//        [NSThread sleepForTimeInterval:1];
//    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async");
    });
}

@end
