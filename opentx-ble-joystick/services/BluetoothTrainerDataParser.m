#import "BluetoothTrainerDataParser.h"

const NSUInteger CHANNEL_COUNT = 8;
const NSUInteger PPM_MIN = 980;
const NSUInteger PPM_MAX = 2020;
const NSUInteger PPM_RANGE = PPM_MAX - PPM_MIN;
const NSUInteger HID_RANGE = 1022;

@implementation BluetoothTrainerDataParser

+ (NSArray*)parse:(NSData*)data {
    if(![self hasBoundaryMarkers:data]) {
        DDLogError(@"Bluetooth data frame did not have boundary markers.");
        return nil;
    }
    if(![self isCorrectFrameType:data]) {
        DDLogError(@"Failed check for frame type!");
        return nil;
    }
    
    NSData *unescapedData = [self unescape:data];
    
    uint8_t checksum = [self getChecksum:data];
    if(![self passesChecksum:checksum data:unescapedData]) {
        DDLogError(@"Failed checksum!");
        return nil;
    }
    
    return [self parsePPMChannelData:unescapedData];
}

+ (NSArray*)parsePPMChannelData:(NSData*)data {
    uint8_t *buffer = (uint8_t *)data.bytes;
    // parse channel data as PPM values
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    for(int channel = 0, i = 1; channel < CHANNEL_COUNT; channel++) {
        uint16_t byte1 = buffer[i];
        uint16_t byte2 = buffer[i + 1];
        uint16_t channelValue = 0;
        
        // channel data is packed into 12-byte blocks (aka 1.5 bytes),
        // which means every other byte needs to be split
        // packing order is strange? given ch1=0xABC and ch2=0xDEF,
        // data would be packed in order 0xBCAEFD,
        // hence the weird unpacking going on below
        if(channel % 2 == 0) {
            channelValue += byte1 & 0x00f0;
            channelValue += byte1 & 0x000f;
            channelValue += (byte2 & 0x00f0) << 4;
            i++;
        } else {
            channelValue += (byte1 & 0x000f) << 4;
            channelValue += (byte2 & 0x00f0) >> 4;
            channelValue += (byte2 & 0x000f) << 8;
            i+=2;
        }
        // incoming data is little endian
        channelValue = CFSwapInt16LittleToHost(channelValue);
        float value = ((float)channelValue - (float)PPM_MIN) / (float)PPM_RANGE;
        // convert to relative value (later, do this somewhere else. should not be responsibility of parser)
        NSUInteger hidValue = (NSUInteger)(value * HID_RANGE);
        channels[channel] = [NSNumber numberWithUnsignedInteger:hidValue];
    }
    
    return [channels copy];
}

+ (uint8_t)getChecksum:(NSData*)data {
    uint8_t *buffer = (uint8_t *)data.bytes;
    return buffer[data.length-2];
}

+ (BOOL)passesChecksum:(uint8_t)checksum data:(NSData*)data {
    uint8_t *buffer = (uint8_t *)data.bytes;
    uint8_t calculatedChecksum = 0;
    for(int i = 0; i < data.length; i++) {
        calculatedChecksum ^= buffer[i];
    }
    
    return calculatedChecksum == checksum;
}

+ (BOOL)hasBoundaryMarkers:(NSData*)data {
    uint8_t *buffer = (uint8_t *)data.bytes;
    return buffer[0] == 0x7e && buffer[data.length-1] == 0x7e;
}

+ (BOOL)isCorrectFrameType:(NSData*)data {
    uint8_t *buffer = (uint8_t *)data.bytes;
    return buffer[1] == 0x80;
}

+(NSData*)unescape:(NSData*)escapedData {
    uint8_t *buffer = (uint8_t *)escapedData.bytes;
    NSUInteger length = escapedData.length;
    
    NSMutableData *unescapedData = [[NSMutableData alloc] init];
 
    for(int i = 1; i < length-2; i++) {
        uint8_t byte = buffer[i];
        
        if(byte != 0x7d) {
            [unescapedData appendBytes:&byte length:1];
            continue;
        }
        
        if(buffer[i+1] == 0x5e) {
            uint8_t newByte = 0x7e;
            [unescapedData appendBytes:&newByte length:1];
        } else if(buffer[i+1] == 0x5d) {
            uint8_t newByte = 0x7d;
            [unescapedData appendBytes:&newByte length:1];
        } else {
            DDLogError(@"Unexpected escape sequence!");
            return nil;
        }
        
        i++;
    }
    return [unescapedData copy];
}

@end
