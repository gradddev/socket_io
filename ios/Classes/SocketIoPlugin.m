#import "SocketIoPlugin.h"
#import <socket_io/socket_io-Swift.h>

@implementation SocketIoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSocketIoPlugin registerWithRegistrar:registrar];
}
@end
