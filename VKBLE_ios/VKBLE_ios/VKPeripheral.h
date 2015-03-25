// The MIT License (MIT)
//
//  Created by viking warlock on 3/25/15.
//  Copyright (c) 2015 viking warlock. All rights reserved.
//  Email:vikingwarlock@gmail.com
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

@class VKPeripheral;

@protocol VKPeripheralDelegate <NSObject>

@required
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


typedef void(^VKBluetoothWriteResponse )(NSError *error , VKPeripheral* peripheral) ;

NS_CLASS_AVAILABLE_IOS(7_0)
@interface VKPeripheral : NSObject<CBPeripheralDelegate>
/**
 *Also provide the original peripheral if you want to do some operation directly
 */
@property (nonatomic,strong,readonly)CBPeripheral *Peripheral;
/**
 *List of CBCharactistic that the peripheral have
 */
@property (nonatomic,strong,readonly)NSArray *CharactisticList;
/**
 *List of CBService that the peripheral have
 */
@property (nonatomic,strong,readonly)NSArray *ServicesList;
/**
 *Name of the peripheral
 */
@property (nonatomic,strong,readonly)NSString *PeripheralName;
/**
 *UUID of the peripheral
 */
@property (nonatomic,strong,readonly)NSString *UUID_String;
/**
 *Strength of the peripheral
 */
@property (nonatomic,readonly) NSInteger SignalStrength;

@property (nonatomic,weak) id<VKPeripheralDelegate> delegate;

/**
 *Write Data Without Response
 *If you know the UUID of the charactistic you want to use
 *This is a convenient way
 */
-(void)writeData:(NSData*)data WithCharactisticUUID:(NSString*)uuid;

/**
 *Write Data Without Response
 *If you don't know the UUID of the charactistic you want to use
 *You can fetch a charactistic from <code>CharactisticList</code>
 */
-(void)writeData:(NSData*)data WithCharactistic:(CBCharacteristic*)charactistic;

/**
 *Write Data With Response
 *If you know the UUID of the charactistic you want to use
 *This is a convenient way
 *With Response will take more time in order to wait for the response
 */
-(void)writeData:(NSData *)data WithCharactisticUUID:(NSString *)string WithResponse:(VKBluetoothWriteResponse)response NS_UNAVAILABLE;

/**
 *Write Data With Response
 *If you don't know the UUID of the charactistic you want to use
 *You can fetch a charactistic from <code>CharactisticList</code>
 *With Response will take more time in order to wait for the response
 */
-(void)writeData:(NSData *)data WithCharactistic:(CBCharacteristic *)charactistic WithResponse:(VKBluetoothWriteResponse)response NS_UNAVAILABLE;

/**
 *
 *
 *
 *
 */
-(void)readDataWithCharactistic:(CBCharacteristic*)charactistic;

/**
 *
 *
 *
 *
 */
-(void)readDataWithCharactisticUUID:(NSString *)uuid;


#pragma Private Method
-(id)initWithCoreBluetoothPeripheral:(CBPeripheral*)peripheral AndRSSI:(NSInteger)RSSI;

@end
