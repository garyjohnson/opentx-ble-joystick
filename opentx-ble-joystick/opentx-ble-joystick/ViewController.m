#import "ViewController.h"
#import "TrainerService.h"
#import "TrainerDataParser.h"
#import "fooHID.h"

@interface ViewController ()

@property (nonatomic, strong) TrainerService *trainerService;

@end

@implementation ViewController

-(IBAction)onConnect:(id)sender {
    if([fooHID init] == 0) {
        self.trainerService = [[TrainerService alloc] initWithDelegate:self];
        [self.trainerService startScan];
    } else {
        NSLog(@"failed to open!");
    }
}

-(IBAction)onDisconnect:(id)sender {
    
    [self.trainerService disconnect];
    [fooHID close];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.window.delegate = self;

}

-(void)windowWillClose:(NSNotification *)notification {
    [fooHID close];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

-(void)onTrainerConnected {
    
}

-(void)onTrainerDisconnected {
    
}

-(void)onError:(NSString*)error {
    NSLog(@"Error! %@", error);
}

-(void)onLoading:(NSString*)error {
    
}

-(void)onUpdated:(NSData*)data {
    NSArray *channelData = [TrainerDataParser parse:data];
    if(channelData == nil) {
        return;
    }
    
    
    [fooHID send:channelData];
}

@end
