#import "TrainerDataParser.h"

@implementation TrainerDataParser

+ (NSArray*)parse:(NSData*)data {
    uint8_t *buffer = (uint8_t *)[data bytes];
    NSUInteger length = [data length];
    
    // check for start and end markers, else throw away
    if(buffer[0] != 0x7e || buffer[length-1] != 0x7e) {
        NSLog(@"Failed check for start stop!");
        return nil;
    }
    
    // check for frame type 80, else throw away
    if(buffer[1] != 0x80) {
        NSLog(@"Failed check for frame type!");
        return nil;
    }
    
    // unescape bytes and unpack into channel values
    uint8_t escapedBuffer[13] = {};
    NSUInteger escapedIndex = 0;
    for(int i = 1; i < length-2; i++, escapedIndex++) {
        uint8_t byte = buffer[i];
        
        //unescape
        if(byte == 0x7d) {
            if(buffer[i+1] == 0x5e) {
                escapedBuffer[escapedIndex] = 0x7e;
                i++;
            } else if(buffer[i+1] == 0x5d) {
                escapedBuffer[escapedIndex] = 0x7d;
                i++;
            } else {
                NSLog(@"Unexpected escape sequence!");
                return nil;
            }
        } else {
            escapedBuffer[escapedIndex] = byte;
        }
    }
    
    // validate checksum, else throw away
    uint8_t calculatedChecksum = 0;
    for(int i = 0; i < 13; i++) {
        calculatedChecksum ^= escapedBuffer[i];
    }
    if(calculatedChecksum != buffer[length-2]) {
        NSLog(@"Failed checksum!");
        return nil;
    }
    
    // parse channel data as PPM values (on my tx, 988-2012ish)
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    for(int channel = 0, i = 1; channel < 8; channel++) {

        uint16_t byte1 = escapedBuffer[i];
        uint16_t byte2 = escapedBuffer[i + 1];
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
        
        // convert to relative value (later, do this somewhere else. should not be responsibility of parser)
        NSUInteger min = 980;
        NSUInteger max = 2020;
        float range = (float)(max - min); // 1040
        float value = (float)(CFSwapInt16LittleToHost(channelValue) - min);
        value = value / range;
        NSUInteger v = (NSUInteger)(value * 1022);
        channels[channel] = [NSNumber numberWithUnsignedInteger:v];
    }
    
    return [channels copy];
}

@end
