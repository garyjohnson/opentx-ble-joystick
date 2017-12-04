#import "BluetoothTrainerService.h"

NSString *const TRAINER_SERVICE_UUID = @"FFF0";
NSString *const DATA_UUID = @"FFF6";

@interface BluetoothTrainerService()

@property (nonatomic, strong) id<BluetoothTrainerDelegate> delegate;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (nonatomic, strong) CBPeripheral *trainerPeripheral;

@property (nonatomic, strong) CBService *trainerService;
@property (nonatomic, strong) CBCharacteristic *dataStreamCharacteristic;

@property (nonatomic) BOOL shouldConnect;

@end

@implementation BluetoothTrainerService

-(instancetype)initWithDelegate:(id<BluetoothTrainerDelegate>)delegate {
    if(self = [super init]) {
        self.delegate = delegate;
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

-(void)startScan {
    self.shouldConnect = YES;
    [self startScanningIfEnabled];
}

-(void)stopScan {
    self.shouldConnect = NO;
    [self.bluetoothManager stopScan];
}

-(void)disconnect {
    [self stopScan];
    if(self.trainerPeripheral) {
        [self.bluetoothManager cancelPeripheralConnection:self.trainerPeripheral];
        self.dataStreamCharacteristic = nil;
        self.trainerPeripheral = nil;
        self.trainerService = nil;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([central state] == CBCentralManagerStatePoweredOn) {
        [self startScanningIfEnabled];
    } else {
        [self.delegate onError:@"Could not access Bluetooth. Ensure it is enabled."];
    }
}

- (void)startScanningIfEnabled {
    if(self.shouldConnect && self.bluetoothManager.state == CBCentralManagerStatePoweredOn) {
        [self.delegate onLoading:@"Searching for trainer..."];
        NSArray *services = @[[CBUUID UUIDWithString:TRAINER_SERVICE_UUID]];
        [self.bluetoothManager scanForPeripheralsWithServices:services options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)trainerPeripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    self.trainerPeripheral = trainerPeripheral;
    self.trainerPeripheral.delegate = self;
    [self.bluetoothManager connectPeripheral:self.trainerPeripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)trainerPeripheral {
    NSLog(@"Peripheral connected");
    [self.delegate onLoading:@"Found trainer! Reading..."];
    trainerPeripheral.delegate = self;
    if(trainerPeripheral.services.count > 0) {
        for (CBService *service in trainerPeripheral.services) {
            if([service.UUID isEqual:[CBUUID UUIDWithString:TRAINER_SERVICE_UUID]]) {
                self.trainerService = service;
            }
        }
        
        if(self.trainerService != nil) {
            [trainerPeripheral discoverCharacteristics:nil forService:self.trainerService];
        }
    } else {
        [trainerPeripheral discoverServices:@[[CBUUID UUIDWithString:TRAINER_SERVICE_UUID]]];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)trainerPeripheral error:(NSError *)error {
    [self.delegate onTrainerDisconnected];
    [self.delegate onLoading:@"Disconnected! Searching..."];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)lampPeripheral error:(NSError *)error {
    [self.delegate onLoading:@"Failed to connect! Searching..."];
}

- (void)peripheral:(CBPeripheral *)trainerPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in trainerPeripheral.services) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:TRAINER_SERVICE_UUID]]) {
            self.trainerService = service;
        }
    }
    
    if(self.trainerService != nil) {
        [trainerPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:DATA_UUID]] forService:self.trainerService];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for(CBCharacteristic *characteristic in service.characteristics) {
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:DATA_UUID]]) {
            self.dataStreamCharacteristic = characteristic;
            [self.trainerPeripheral readValueForCharacteristic:self.dataStreamCharacteristic];
            [self.trainerPeripheral setNotifyValue:YES forCharacteristic:self.dataStreamCharacteristic];
        }
    }
    
    if(self.dataStreamCharacteristic != nil) {
        NSString *peripheralId = nil;
        if (@available(macOS 10.13, *)) {
            peripheralId = [[peripheral identifier] UUIDString];
        }
        
        [self.delegate onTrainerConnected:peripheralId];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if(characteristic.value == nil) {
        return;
    }
    
    if(characteristic == self.dataStreamCharacteristic) {
        NSData *data = self.dataStreamCharacteristic.value;
        [self.delegate onUpdated:data];
    }
}

@end
