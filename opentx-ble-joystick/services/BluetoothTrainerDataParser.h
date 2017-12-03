#import <Foundation/Foundation.h>

@interface BluetoothTrainerDataParser : NSObject

+ (NSArray*)parse:(NSData*)data;

@end
