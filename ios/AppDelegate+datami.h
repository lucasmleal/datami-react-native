#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SmiSdk.h"
#import "RNDatamiEventManager.h"

@interface DatamiAppDelegate : NSObject
@property (strong, nonatomic) SmiResult *smiResult;
@property (strong, nonatomic) RNDatamiEventManager *datamiEvt;

-(void)handleNotification:(NSNotification *)notif;
-(BOOL)application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions;
-(BOOL)_original_saved_by_Override_application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions;

@end
