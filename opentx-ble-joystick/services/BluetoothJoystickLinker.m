#import "BluetoothJoystickLinker.h"
#import "VirtualJoystickService.h"
#import "BluetoothTrainerService.h"
#import "BluetoothTrainerDataParser.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Notifications.h"

@interface BluetoothJoystickLinker()

@property (nonatomic, strong) BluetoothTrainerService *trainerService;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@implementation BluetoothJoystickLinker

-(instancetype)init {
    if(self = [super init]) {
        self.notificationCenter = [NSNotificationCenter defaultCenter];
        self.dispatchQueue = dispatch_queue_create("io.usefulbits.opentx-ble-joystick.BluetoothJoystickLinker", NULL);
    }
    
    return self;
}

-(void)start {
    dispatch_async(self.dispatchQueue, ^{
        if(![VirtualJoystickService init]) {
            DDLogError(@"Failed to initialize virtual joystick");
            [self.notificationCenter postNotificationName:FOOHID_MISSING object:nil];
            return;
        }
        
        DDLogInfo(@"Initializing bluetooth...");
        self.trainerService = [[BluetoothTrainerService alloc] initWithDelegate:self];
        [self.trainerService startScan];
    });
}

-(void)stop {
    dispatch_async(self.dispatchQueue, ^{
        [self.trainerService disconnect];
        [VirtualJoystickService close];
    });
}

-(void)onTrainerConnected:(NSString*)identifier {
    DDLogInfo(@"Bluetooth connected");
    [self.notificationCenter postNotificationName:BLUETOOTH_CONNECTED object:nil userInfo:@{ @"id" : identifier }];
}

-(void)onTrainerDisconnected {
    DDLogInfo(@"Bluetooth disconnected");
    [self.notificationCenter postNotificationName:BLUETOOTH_SEARCHING object:nil];
    [self.trainerService startScan];
}

-(void)onError:(NSString*)error {
    DDLogError(@"Bluetooth Error! %@", error);
    [self.notificationCenter postNotificationName:BLUETOOTH_SEARCHING object:nil];
    [self.trainerService startScan];
}

-(void)onLoading:(NSString*)error {
    DDLogInfo(@"Searching...");
    [self.notificationCenter postNotificationName:BLUETOOTH_SEARCHING object:nil];
}

-(void)onUpdated:(NSData*)data {
    NSArray *channelData = [BluetoothTrainerDataParser parse:data];
    if(channelData == nil) {
        return;
    }
    
    [VirtualJoystickService send:channelData];
}
@end
