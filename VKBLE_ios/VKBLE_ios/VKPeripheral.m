//
//  VKPeripheral.m
//  VKBLE_ios
//
//  Created by viking warlock on 3/25/15.
//  Copyright (c) 2015 viking warlock. All rights reserved.
//

#import "VKPeripheral.h"

@interface VKPeripheral()
{
    NSInteger rssi;
    CBPeripheral *CorebluetoothPeripheral;
    NSMutableArray *PrivateCharactisticList;
    NSMutableArray *PrivateServicesList;
    NSMutableDictionary *CharactisticDictionary;
}

@end

@implementation VKPeripheral


-(id)initWithCoreBluetoothPeripheral:(CBPeripheral *)peripheral AndRSSI:(NSInteger)RSSI
{
    self=[super init];
    if (self) {
        rssi=RSSI;
        CorebluetoothPeripheral=peripheral;
        PrivateCharactisticList=[NSMutableArray array];
        PrivateServicesList=[NSMutableArray array];
        CharactisticDictionary=[NSMutableDictionary dictionary];
        CorebluetoothPeripheral.delegate=self;
    }
    return self;
}

-(void)writeData:(NSData *)data WithCharactisticUUID:(NSString *)uuid
{
    if ([[CharactisticDictionary allKeys]containsObject:uuid]) {
        CBCharacteristic *charactistic = CharactisticDictionary[uuid];
        [CorebluetoothPeripheral writeValue:data forCharacteristic:charactistic type:CBCharacteristicWriteWithoutResponse];
    }
    else
    {
        NSLog(@"\n\nCharacteristic not found!!\n\n");
    }
}

-(void)writeData:(NSData *)data WithCharactistic:(CBCharacteristic *)charactistic
{
        [CorebluetoothPeripheral writeValue:data forCharacteristic:charactistic type:CBCharacteristicWriteWithoutResponse];
}

-(void)readDataWithCharactistic:(CBCharacteristic *)charactistic
{
    [CorebluetoothPeripheral readValueForCharacteristic:charactistic];
}

-(void)readDataWithCharactisticUUID:(NSString *)uuid
{
    if ([[CharactisticDictionary allKeys]containsObject:uuid]) {
        CBCharacteristic *charactistic = CharactisticDictionary[uuid];
        [CorebluetoothPeripheral readValueForCharacteristic:charactistic];
    }
    else
    {
        NSLog(@"\n\nCharacteristic not found!!\n\n");
    }

}

#pragma Delegate
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for(CBService *service in peripheral.services){
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for(CBCharacteristic *characteristic in service.characteristics)
    {
        [PrivateCharactisticList addObject:characteristic];
        [CharactisticDictionary setObject:characteristic forKey:characteristic.UUID.UUIDString];
    }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

    if ([self.delegate respondsToSelector:@selector(VKBluetoothPeripheralGotNotify:AndNotifyData:FromCharactistic:AndBelongToService:)]) {
        [self.delegate VKBluetoothPeripheralGotNotify:self AndNotifyData:characteristic.value FromCharactistic:characteristic AndBelongToService:characteristic.service];
    }else
        if ([self.delegate respondsToSelector:@selector(VKBluetoothPeripheralGotNotify:AndNotifyData:FromCharactistic:)]) {
            [self.delegate VKBluetoothPeripheralGotNotify:self AndNotifyData:characteristic.value FromCharactistic:characteristic];
        }else
            if ([self.delegate respondsToSelector:@selector(VKBluetoothPeripheralGotNotify:AndNotifyData:)]) {
                [self.delegate VKBluetoothPeripheralGotNotify:self AndNotifyData:characteristic.value];
            }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

}



@end
