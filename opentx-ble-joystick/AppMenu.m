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
}

-(void)onBluetoothSearching:(NSNotification*)notification {
    [self.statusMenuItem setTitle:@"Searching..."];
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
    button.image = [NSImage imageNamed:@"status-icon"];
}

-(IBAction)onCalibrateClicked:(id)sender {
}

-(IBAction)onQuitClicked:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

@end
