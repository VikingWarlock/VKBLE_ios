//
//  VKPeripheral.h
//  VKBLE_ios
//
//  Created by viking warlock on 3/25/15.
//  Copyright (c) 2015 viking warlock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class VKPeripheral;

typedef void(^VKBluetoothWriteResponse )(NSError *error , VKPeripheral* peripheral) ;


@interface VKPeripheral : NSObject
/**
 *Also provide the original peripheral if you want to do some operation directly
 */
@property (nonatomic,strong,readonly)CBPeripheral *Peripheral;
/**
 *List of CBCharactistic that this peripheral have
 */
@property (nonatomic,strong,readonly)NSArray *CharactisticList;
/**
 *List of CBService that this peripheral have
 */
@property (nonatomic,strong,readonly)NSArray *ServicesList;
/**
 *Name of this peripheral
 */
@property (nonatomic,strong,readonly)NSString *PeripheralName;
/**
 *UUID of this peripheral
 */
@property (nonatomic,strong,readonly)NSString *UUID_String;
/**
 *Strength of this peripheral
 */
@property (nonatomic,readonly) NSInteger SignalStrength;

/**
 *Write Data Without Response
 *If you know the UUID of the charactistic you want to use
 *This is a convenient way
 */
-(void)writeData:(NSData*)data WithCharactisticUUID:(NSString*)string;

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
-(void)writeData:(NSData *)data WithCharactisticUUID:(NSString *)string WithResponse:(VKBluetoothWriteResponse)response;

/**
 *Write Data With Response
 *If you don't know the UUID of the charactistic you want to use
 *You can fetch a charactistic from <code>CharactisticList</code>
 *With Response will take more time in order to wait for the response
 */
-(void)writeData:(NSData *)data WithCharactistic:(CBCharacteristic *)charactistic WithResponse:(VKBluetoothWriteResponse)response;



@end
