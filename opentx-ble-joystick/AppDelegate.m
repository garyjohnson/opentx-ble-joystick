#import "AppDelegate.h"
#import <AppKit/AppKit.h>

#import "AppMenu.h"
#import "BluetoothJoystickLinker.h"

@interface AppDelegate ()

@property (nonatomic, strong) AppMenu *appMenu;
@property (nonatomic, strong) BluetoothJoystickLinker *joystickLinker;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self initializeLogging];
    
    self.appMenu = [[AppMenu alloc] init];
    [self.appMenu showInStatusBar];

    self.joystickLinker = [[BluetoothJoystickLinker alloc] init];
    [self.joystickLinker start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.joystickLinker stop];
}

- (void) initializeLogging {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}



@end
