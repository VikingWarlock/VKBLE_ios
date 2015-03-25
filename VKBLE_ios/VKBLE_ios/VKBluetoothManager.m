//
//  VKBluetoothManager.m
//  VKBLE_ios
//
//  Created by viking warlock on 3/25/15.
//  Copyright (c) 2015 viking warlock. All rights reserved.
//

#import "VKBluetoothManager.h"


extern NSString * const vk_StartScanningPeripheralWithTimeout;


static VKBluetoothManager *shared;

@interface VKBluetoothManager()<CBCentralManagerDelegate>
{
    //搜索到的外设
    NSMutableArray *PrivatePeripheralList;
    //搜索到的外设对应表
    NSMutableDictionary *DiscoverPeripheralDictionary;
    //UUID池
    NSMutableArray *UUID_Pool;
    //目的UUID池
    NSMutableArray *TargetList;
    //自动连接的外设池
    NSMutableArray *ConnectedList;
    //已连设备对应表
    NSMutableDictionary *ConnectedDictionary;
    //自动连接计数器
    NSInteger TargetConnectedCount;
    
    //超时计时器
    NSTimer *TimeoutTimer;
    
    //当前计时到
    float timerCount;
    
    //超时目标
    float timeoutValue;
    
    //block
    __weak FinishScanning StrongBlock;
    
    
    //当前扫描状态
    VKBluetoothManagerScanningState CurrentScanningState;
    
}

-(void)clearData;

@end

@implementation VKBluetoothManager



#pragma Getter

/*
 *Maybe later
 *
 */
-(NSArray *)peripheralList
{
    return nil;
}

#pragma Public Method


+(void)setup
{
    [[VKBluetoothManager sharedObject]clearData];
}



+(VKBluetoothManager*)sharedObject
{
    if (!shared) {
        shared=[[VKBluetoothManager alloc]init];
    }
    return shared;
}


+(void)startScanPeripheralOneByOneWithServices:(NSArray *)services
{
    [[VKBluetoothManager sharedObject].centerManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

+(void)stopScanningPeripheral
{
    [[VKBluetoothManager sharedObject].centerManager stopScan];
}

+(void)startScanPeripheralsWithServices:(NSArray *)services WithTimeOut:(float)time andDoneBlock:(FinishScanning)block
{
    [[VKBluetoothManager sharedObject].centerManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    [[NSNotificationCenter defaultCenter]postNotificationName:vk_StartScanningPeripheralWithTimeout object:nil];
}

+(void)startScanPeripheralsWithServices:(NSArray *)services WithTimeOut:(float)time AndTargetUUIDs:(NSArray *)uuids andDoneBlock:(FinishScanning)block
{
    [[VKBluetoothManager sharedObject].centerManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    [[NSNotificationCenter defaultCenter]postNotificationName:vk_StartScanningPeripheralWithTimeout object:nil];
}

#pragma Private Delegate Method

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self.delegate respondsToSelector:@selector(VKBluetoothStateChange:ForVKBluetoothManager:)]) {
        [self.delegate VKBluetoothStateChange:central.state ForVKBluetoothManager:self];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([UUID_Pool containsObject:peripheral.identifier.UUIDString]) {
        //already discovered;
    }else
    {
        //this peripheral is discovered for the first time
        if ([TargetList containsObject:peripheral.identifier.UUIDString]) {
            [self.centerManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES}];
        }
        [UUID_Pool addObject:peripheral.identifier.UUIDString];
        VKPeripheral *item=[[VKPeripheral alloc] initWithCoreBluetoothPeripheral:peripheral AndRSSI:RSSI.integerValue];
        [PrivatePeripheralList addObject:item];
        if ([self.delegate respondsToSelector:@selector(VKBluetoothPeripheralDidDiscover:)]) {
            [self.delegate VKBluetoothPeripheralDidDiscover:item];
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    VKPeripheral *item=ConnectedDictionary[peripheral.identifier.UUIDString];
    if (item==nil) {
        item=[[VKPeripheral alloc]initWithCoreBluetoothPeripheral:peripheral AndRSSI:0];
        [ConnectedDictionary setObject:item forKey:peripheral.identifier.UUIDString];
    }
    
    [peripheral discoverServices:peripheral.services];
    
    if ([TargetList containsObject:peripheral.identifier.UUIDString]) {
        TargetConnectedCount++;
    }else
    {
        if ([self.delegate respondsToSelector:@selector(VKBluetoothPeripheralDidConnect:)]) {
            [self.delegate VKBluetoothPeripheralDidConnect:item];
        }
        
    }
    
}


-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    VKPeripheral *item=ConnectedDictionary[peripheral.identifier.UUIDString];
    if (item==nil) {
        item=[[VKPeripheral alloc]initWithCoreBluetoothPeripheral:peripheral AndRSSI:0];
        [ConnectedDictionary setObject:item forKey:peripheral.identifier.UUIDString];
    }
    
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{

}

#pragma Private Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.centerManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
        ConnectedList=[NSMutableArray array];
        timerCount=0.f;
        timeoutValue=0.f;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginTimer) name:vk_StartScanningPeripheralWithTimeout object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)clearData
{
    if (PrivatePeripheralList==nil) {
        PrivatePeripheralList=[NSMutableArray array];
        UUID_Pool=[NSMutableArray array];
    
    }else
    {
        [PrivatePeripheralList removeAllObjects];
        [UUID_Pool removeAllObjects];
    }
    
    TargetConnectedCount=0;
    
    if (TargetList==nil) {
        TargetList=[NSMutableArray array];
    }else
    {
        [TargetList removeAllObjects];
    }
}

-(void)beginTimer
{
    if (TimeoutTimer) {
        [TimeoutTimer setFireDate:[NSDate date]];
    }
}


-(void)start_timer
{
    NSRunLoop *runloop=[NSRunLoop currentRunLoop];
    if (TimeoutTimer==nil) {
        TimeoutTimer=[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(timeoutAction) userInfo:nil repeats:YES];
    }else
    {
        
    }
    [TimeoutTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:999999]];
    [runloop run];
}

-(void)timeoutAction
{
    timerCount+=0.2f;
    
    if (timerCount>=timeoutValue) {
        [self.centerManager stopScan];
        if (TargetList.count>0) {
            [TargetList removeAllObjects];
            if (StrongBlock) {
                StrongBlock(PrivatePeripheralList,ConnectedList);
            }
        }
        timeoutValue=0.f;
        timerCount=0.f;
        
    }
    else
    {
        return;
    }
}

+ (NSThread *)BluetoothRequestThread {
    static NSThread *_BluetoothRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _BluetoothRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(BluetoothThread:) object:nil];
        [_BluetoothRequestThread start];
    });
    
    return _BluetoothRequestThread;
}

+(void)BluetoothThread:(id)__unused object
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"VK_Bluetooth_Service"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
    
}


@end
