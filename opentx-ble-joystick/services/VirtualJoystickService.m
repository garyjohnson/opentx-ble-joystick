#import "VirtualJoystickService.h"
#import <IOKit/IOKitLib.h>

#define CHANNELS 8
#define CHANNELMAXIMUM 1022
#define CHANNELOFFSET (CHANNELMAXIMUM / 2)

#define FOOHID_NAME "it_unbit_foohid"
#define FOOHID_CREATE 0
#define FOOHID_DESTROY 1
#define FOOHID_SEND 2
#define FOOHID_LIST 3
#define VIRTUAL_DEVICE_NAME "Virtual Serial Transmitter"
#define VIRTUAL_DEVICE_SN "SN  123456"

struct gamepad_report_t {
    int16_t leftX;
    int16_t leftY;
    int16_t rightX;
    int16_t rightY;
    int16_t aux1;
    int16_t aux2;
    int16_t aux3;
    int16_t aux4;
    char button1;
    char button2;
    char button3;
    char button4;
    char button5;
    char button6;
    char button7;
    char button8;
};

static io_connect_t connector;
static uint64_t deviceName = 0;
static uint64_t deviceNameLength = 0;
static uint64_t deviceSN = 0;
static uint64_t deviceSNLength = 0;
static struct gamepad_report_t gamepad;

static char report_descriptor[58] = {
    0x05, 0x01, /* Usage Page (Generic Desktop) */
    0x09, 0x04, /* Usage (Joystick) */
    
    0xa1, 0x01, /* Collection (Application) */
    0x09, 0x01, /* Usage (Pointer) */
    
    /* 8 axes, signed 16 bit resolution, range -32768 to 32767 (16 bytes) */
    0xa1, 0x00, /* Collection (Physical) */
    0x05, 0x01, /* Usage Page (Generic Desktop) */
    0x09, 0x30, /* Usage (lX) */
    0x09, 0x31, /* Usage (lY) */
    0x09, 0x32, /* Usage (rX) */
    0x09, 0x33, /* Usage (rY) */
    0x09, 0x34, /* Usage (Analog1) */
    0x09, 0x35, /* Usage (Analog2) */
    0x09, 0x36, /* Usage (Analog3) */
    0x09, 0x37, /* Usage (Analog4) */
    0x16, 0x01, 0xfe,              //     LOGICAL_MINIMUM (-511)
    0x26, 0xff, 0x01,              //     LOGICAL_MAXIMUM (511)
    0x75, 16, /* Report Size (16) */
    0x95, 8, /* Report Count (8) */
    0x81, 0x82, /* Input (Data, Variable, Absolute, Volatile) */
    0xc0, /* End Collection */
    
    /* 10 buttons, value 0=off, 1=on (5 bytes) */
    0x05, 0x09, /* Usage Page (Button) */
    0x19, 1, /* Usage Minimum (Button 1) */
    0x29, 8, /* Usage Maximum (Button 8) */
    0x15, 0x00, /* Logical Minimum (0) */
    0x25, 0x01, /* Logical Maximum (1) */
    0x75, 1, /* Report Size (1) */
    0x95, 8, /* Report Count (8) */
    0x81, 0x02, /* Input (Data, Variable, Absolute) */
    0xc0 /* End Collection */
};

@implementation VirtualJoystickService

+ (BOOL)init {
    deviceName = (uint64_t)strdup(VIRTUAL_DEVICE_NAME);
    deviceNameLength = strlen((char *)deviceName);
    deviceSN = (uint64_t)strdup(VIRTUAL_DEVICE_SN);
    deviceSNLength = strlen((char *)deviceSN);
    
    DDLogDebug(@"Searching for foohid Kernel extension...");
    io_iterator_t iterator;
    kern_return_t ret = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(FOOHID_NAME), &iterator);
    if (ret != KERN_SUCCESS) {
        DDLogError(@"Unable to access foohid IOService");
        IOObjectRelease(iterator);
        return NO;
    }
    
    BOOL found = NO;
    io_service_t service;
    while ((service = IOIteratorNext(iterator)) != IO_OBJECT_NULL) {
        ret = IOServiceOpen(service, mach_task_self(), 0, &connector);
        if (ret == KERN_SUCCESS) {
            found = YES;
            break;
        }
    }
    IOObjectRelease(iterator);
    if (!found) {
        DDLogError(@"Unable to open foohid IOService");
        return NO;
    }
    
    NSString *name = @VIRTUAL_DEVICE_NAME;
    if([VirtualJoystickService deviceExists:name]) {
        DDLogDebug(@"Device exists!");
        return NO;
    } else {
        DDLogDebug(@"Device doesn't already exist");
    }
    
    DDLogDebug(@"Creating virtual HID device...");
    uint64_t input[8] = {
        deviceName,
        deviceNameLength,
        (uint64_t)report_descriptor,
        sizeof(report_descriptor),
        deviceSN,
        deviceSNLength,
        (uint64_t)2, // vendor ID
        (uint64_t)3, // device ID
    };

    ret = IOConnectCallScalarMethod(connector, FOOHID_CREATE, input, 8, NULL, 0);
    if (ret != KERN_SUCCESS) {
        DDLogError(@"Unable to create virtual HID device");
        return NO;
    }
    
    return YES;
}

+ (void)close {
    DDLogDebug(@"Destroying virtual HID device");
    
    uint64_t input[2] = {
        deviceName,
        deviceNameLength,
    };
    
    kern_return_t ret = IOConnectCallScalarMethod(connector, FOOHID_DESTROY, input, 2, NULL, 0);
    if (ret != KERN_SUCCESS) {
        DDLogError(@"Unable to destroy virtual HID device");
    }
}

+ (void)send:(NSArray *)data {
    if ([data count] < CHANNELS) {
        DDLogError(@"Not enough data values to send (%lu)!", (unsigned long)[data count]);
        return;
    }
    
    uint16_t buffer[CHANNELS];
    for (int i = 0; i < CHANNELS; i++) {
        buffer[i] = [((NSNumber *)[data objectAtIndex:i]) integerValue];
    }
    for (int i = 0; i < CHANNELS; i++) {
        if (buffer[i] > CHANNELMAXIMUM) {
            buffer[i] = CHANNELMAXIMUM;
        }
    }
    
    gamepad.leftX = buffer[3] - CHANNELOFFSET;
    gamepad.leftY = buffer[2] - CHANNELOFFSET;
    gamepad.rightX = buffer[0] - CHANNELOFFSET;
    gamepad.rightY = buffer[1] - CHANNELOFFSET;
    gamepad.aux1 = buffer[4] - CHANNELOFFSET;
    gamepad.aux2 = buffer[5] - CHANNELOFFSET;
    
    uint64_t input[4] = {
        deviceName,
        deviceNameLength,
        (uint64_t)&gamepad,
        sizeof(struct gamepad_report_t),
    };

    kern_return_t ret = IOConnectCallScalarMethod(connector, FOOHID_SEND, input, 4, NULL, 0);
    if (ret != KERN_SUCCESS) {
        DDLogError(@"Unable to send packet to virtual HID device");
    }
}

+ (BOOL)deviceExists:(NSString*)deviceName {
    const int inital_buffer_size = 512;
    NSMutableData *buffer = [NSMutableData dataWithCapacity:inital_buffer_size];
    [buffer setLength:inital_buffer_size];
    
    uint32_t input_count = 2;
    uint64_t input[input_count];
    input[0] = (uint64_t) [buffer mutableBytes]; // buffer pointer
    input[1] = [buffer length];
    
    uint32_t output_count = 2;
    uint64_t output[output_count];
    output[0] = 0;
    output[1] = 0;
    
    kern_return_t ret = IOConnectCallScalarMethod(connector, FOOHID_LIST, input, input_count, output, &output_count);
    if(ret == kIOReturnNoMemory) {
        DDLogError(@"No memory error while listing existing devices.");
        return NO;
    }
    
    if(output[0] > 0) {
        // We need more bytes in our buffer
        [buffer setLength:output[0]];
        input[0] = (uint64_t) [buffer mutableBytes]; // buffer pointer
        input[1] = [buffer length]; // buffer length
        ret = IOConnectCallScalarMethod(connector, FOOHID_LIST, input, input_count, output, &output_count);
        if(ret == kIOReturnNoMemory) {
            DDLogError(@"No memory error while listing existing devices.");
            return NO;
        }
    }
    
    // Loop through each name and check if this device is already listed
    const char *returnedDeviceNamePointer = [buffer bytes];
    long numberOfItemsReturned = output[1];
    for(int i = 0; i < numberOfItemsReturned; i++) {
        if(strcmp([deviceName UTF8String], returnedDeviceNamePointer) == 0) {
            return YES;
        }
        // Advance the pointer until we hit the next name
        while(*returnedDeviceNamePointer != '\0') returnedDeviceNamePointer++;
        returnedDeviceNamePointer++;
    }
    
    return NO;
}

@end
