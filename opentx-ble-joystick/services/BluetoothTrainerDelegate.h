@protocol BluetoothTrainerDelegate

-(void)onTrainerConnected:(NSString*)identifier;
-(void)onTrainerDisconnected;
-(void)onError:(NSString*)error;
-(void)onLoading:(NSString*)error;
-(void)onUpdated:(NSData*)data;

@end
