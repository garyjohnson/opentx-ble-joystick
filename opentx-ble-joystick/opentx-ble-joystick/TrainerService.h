#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TrainerDelegate.h"


@interface TrainerService : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

-(instancetype)initWithDelegate:(id<TrainerDelegate>)delegate;
-(void)startScan;
-(void)stopScan;
-(void)disconnect;

@end
