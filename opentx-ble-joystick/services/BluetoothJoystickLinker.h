#import <Foundation/Foundation.h>
#import "BluetoothTrainerDelegate.h"

@interface BluetoothJoystickLinker : NSObject<BluetoothTrainerDelegate>

-(void)start;
-(void)stop;

@end
