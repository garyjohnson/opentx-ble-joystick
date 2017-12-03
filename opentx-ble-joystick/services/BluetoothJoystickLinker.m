#import "BluetoothJoystickLinker.h"

#import "VirtualJoystickService.h"
#import "BluetoothTrainerService.h"
#import "BluetoothTrainerDataParser.h"

@interface BluetoothJoystickLinker()

@property (nonatomic, strong) BluetoothTrainerService *trainerService;

@end

@implementation BluetoothJoystickLinker

-(void)start {
    
    if([VirtualJoystickService init] == 0) {
        self.trainerService = [[BluetoothTrainerService alloc] initWithDelegate:self];
        [self.trainerService startScan];
    } else {
        DDLogError(@"failed to open!");
    }
}

-(void)stop {
    [self.trainerService disconnect];
    [VirtualJoystickService close];
}

-(void)onTrainerConnected {
    DDLogInfo(@"Bluetooth connected");
}

-(void)onTrainerDisconnected {
    DDLogInfo(@"Bluetooth disconnected");
}

-(void)onError:(NSString*)error {
    DDLogError(@"Bluetooth Error! %@", error);
}

-(void)onLoading:(NSString*)error {
    DDLogInfo(@"Searching...");
}

-(void)onUpdated:(NSData*)data {
    NSArray *channelData = [BluetoothTrainerDataParser parse:data];
    if(channelData == nil) {
        return;
    }
    
    [VirtualJoystickService send:channelData];
}
@end
