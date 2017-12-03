#import "AppMenu.h"
#import <AppKit/AppKit.h>

@interface AppMenu()

@property (nonatomic, strong) NSStatusItem *statusBarItem;

@property (nonatomic, strong) IBOutlet NSMenu *menu;
@property (nonatomic, strong) IBOutlet NSMenuItem *statusMenuItem;

@end

@implementation AppMenu

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

-(IBAction)onAboutClicked:(id)sender {
}

-(IBAction)onQuitClicked:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

@end
