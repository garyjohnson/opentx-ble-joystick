#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothTrainerDelegate.h"


@interface BluetoothTrainerService : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

-(instancetype)initWithDelegate:(id<BluetoothTrainerDelegate>)delegate;
-(void)startScan;
-(void)stopScan;
-(void)disconnect;

@end
