// The MIT License (MIT)
//
//  Created by viking warlock on 3/25/15.
//  Copyright (c) 2015 viking warlock. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "VKPeripheral.h"


@protocol VKBluetoothDelegate <NSObject>

@optional
/*
 *The bluetooth service of your device change its state
 *手机蓝牙状态变更
 */
-(void)VKBluetoothStateChange:(CBCentralManagerState)BluetoothState;

/*
 *A peripheral has connected with device
 *一个外设已经与手机连接
 */
-(void)VKBluetoothPeripheralDidConnect:(VKPeripheral*)peripheral;

/*
 *A peripheral has disconnected with device
 *一个外设已经与手机断开连接
 */
-(void)VKBluetoothPeripheralDidDisconnect:(VKPeripheral *)peripheral AndErrorInformation:(NSError*)error;

/*
 *Receive a notify message from a peripheral
 *从一个外设中收到通知的信息
 */
-(void)VKBluetoothPeripheralGotNotify:(VKPeripheral *)peripheral AndNotifyData:(NSData*)data;

/*
 *Receive a notify message from a peripheral
 *从一个外设中收到通知的信息
 */
-(void)VKBluetoothPeripheralGotNotify:(VKPeripheral *)peripheral AndNotifyData:(NSData *)data FromCharactistic:(CBCharacteristic*)charactistic;

/*
 *Receive a notify message from a peripheral
 *从一个外设中收到通知的信息
 */
-(void)VKBluetoothPeripheralGotNotify:(VKPeripheral *)peripheral AndNotifyData:(NSData *)data FromCharactistic:(CBCharacteristic *)charactistic AndBelongToService:(CBService*)service;


@end

@interface VKBluetoothManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>


/*
 *
 *
 *
 */
+(void)setup;

+(VKBluetoothManager*)sharedObject;

+ (NSThread *)BluetoothRequestThread;




@end
