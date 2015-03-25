//
//  VKBluetoothManager.m
//  VKBLE_ios
//
//  Created by viking warlock on 3/25/15.
//  Copyright (c) 2015 viking warlock. All rights reserved.
//

#import "VKBluetoothManager.h"

static VKBluetoothManager *shared;

@interface VKBluetoothManager()<CBCentralManagerDelegate>
{
    NSMutableArray *PrivatePeripheralList;
    NSMutableArray *UUID_Pool;
    NSMutableArray *TargetList;
    NSMutableArray *ConnectedList;
    
    NSTimer *TimeoutTimer;
}

-(void)clearData;

@end

@implementation VKBluetoothManager


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


+(void)setup
{
    [[VKBluetoothManager sharedObject]clearData];
}

-(NSArray *)peripheralList
{
    return PrivatePeripheralList;
}


+(VKBluetoothManager*)sharedObject
{
    if (!shared) {
        shared=[[VKBluetoothManager alloc]init];
    }
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.centerManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return self;
}

+(void)startScanPeripheralOneByOneWithServices:(NSArray *)services
{
    [[VKBluetoothManager sharedObject].centerManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

+(void)stopScanningPeripheral
{
    [[VKBluetoothManager sharedObject].centerManager stopScan];
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

    
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{

}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{

}

#pragma Private Method
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
    
    
}

@end
