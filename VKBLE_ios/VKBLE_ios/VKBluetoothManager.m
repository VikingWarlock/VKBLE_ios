//
//  VKBluetoothManager.m
//  VKBLE_ios
//
//  Created by viking warlock on 3/25/15.
//  Copyright (c) 2015 viking warlock. All rights reserved.
//

#import "VKBluetoothManager.h"

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


@end
