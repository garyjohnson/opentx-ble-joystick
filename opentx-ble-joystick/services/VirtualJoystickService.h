#import <Foundation/Foundation.h>

@interface VirtualJoystickService : NSObject

+ (BOOL)init;
+ (void)close;
+ (void)send:(NSArray *)data;

@end
