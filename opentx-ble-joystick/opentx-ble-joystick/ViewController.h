#import <Cocoa/Cocoa.h>
#import "TrainerDelegate.h"

@interface ViewController : NSViewController<TrainerDelegate, NSWindowDelegate>

-(void)onTrainerConnected;
-(void)onTrainerDisconnected;
-(void)onError:(NSString*)error;
-(void)onLoading:(NSString*)error;
-(void)onUpdated:(NSData*)data;

@end

