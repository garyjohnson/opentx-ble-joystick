#import "AppMenu.h"
#import <AppKit/AppKit.h>
#import "Notifications.h"

@interface AppMenu()

@property (nonatomic, strong) NSStatusItem *statusBarItem;

@property (nonatomic, strong) IBOutlet NSMenu *menu;
@property (nonatomic, strong) IBOutlet NSMenuItem *statusMenuItem;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@implementation AppMenu

-(instancetype)init {
    if(self = [super init]) {
        self.notificationCenter = [NSNotificationCenter defaultCenter];
        [self.notificationCenter addObserver:self selector:@selector(onBluetoothConnected:) name:BLUETOOTH_CONNECTED object:nil];
        [self.notificationCenter addObserver:self selector:@selector(onBluetoothSearching:) name:BLUETOOTH_SEARCHING object:nil];
        
        __weak AppMenu *weakSelf = self;
        [self.notificationCenter addObserverForName:FOOHID_MISSING object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) {
            [weakSelf handleMissingFoohid];
        }];
    }
    
    return self;
}

-(void)onBluetoothConnected:(NSNotification*)notification {
    NSString *status = @"Connected";
    NSString *identifier = [notification.userInfo objectForKey:@"id"];
    if(identifier) {
        status = [NSString stringWithFormat:@"Connected to %@", identifier];
    }
    [self.statusMenuItem setTitle:status];
    NSStatusBarButton *button = self.statusBarItem.button;
    button.image = [NSImage imageNamed:@"status-icon-connected"];
}

-(void)onBluetoothSearching:(NSNotification*)notification {
    [self.statusMenuItem setTitle:@"Searching..."];
    NSStatusBarButton *button = self.statusBarItem.button;
    button.image = [NSImage imageNamed:@"status-icon-searching"];
}

-(void)showInStatusBar {
    NSMutableArray *topLevelObjects = nil;
    if(![[NSBundle mainBundle] loadNibNamed:@"AppMenu" owner:self topLevelObjects:&topLevelObjects]) {
        DDLogError(@"Failed to load AppMenu nib!");
        return;
    }
    
    self.statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusBarItem.menu = self.menu;
    self.statusBarItem.target = self;
    NSStatusBarButton *button = self.statusBarItem.button;
    button.image = [NSImage imageNamed:@"status-icon-searching"];
}

-(IBAction)onConfigureClicked:(id)sender {
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *windowController = [storyboard instantiateControllerWithIdentifier:@"ConfigureWindow"];
    [windowController showWindow:nil];
}

-(IBAction)onQuitClicked:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

-(void)handleMissingFoohid {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Missing requirement: foohid"];
    [alert setInformativeText:@"foohid must be installed to use OpenTX BLE Joystick.\nDownload foohid at https://github.com/unbit/foohid/releases/latest.\n\nThe application will now exit."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
    [[NSApplication sharedApplication] terminate:nil];
}

@end
