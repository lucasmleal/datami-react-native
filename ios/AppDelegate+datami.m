#import "AppDelegate+datami.h"
#import "SmiSdk.h"
#import <objc/runtime.h>

@implementation DatamiAppDelegate

@dynamic smiResult;
@dynamic datamiEvt;





-(BOOL)application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions
{
    NSLog(@"[OverrideAppDelegate application:%@ didFinishLaunchingWithOptions:%@]", application, launchOptions);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SDSTATE_CHANGE_NOTIF object:nil];
    NSString* apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DATAMI_API_KEY"];
    NSDictionary *infoDict =  [[NSBundle mainBundle] infoDictionary];
    BOOL bMessaging = NO;
    if([infoDict objectForKey:@"DATAMI_MESSAGING"]){
        bMessaging  = [[infoDict objectForKey:@"DATAMI_MESSAGING"] boolValue];
    }
    else {
        NSLog(@"DATAMI_MESSAGING key not found in plist, using default value");
    }
    
    NSString* userId;
    if([infoDict objectForKey:@"DATAMI_USERID"]) {
        userId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DATAMI_USERID"];
    }
    else {
        userId = @"";
        NSLog(@"DATAMI_USERID key not found in plist, using default value");
    }
    
    if([apiKey length]) {
        [SmiSdk initSponsoredData:apiKey userId: userId showSDMessage:bMessaging];
        NSLog(@"Datami sdk initialized with :%@",apiKey );
    }
    else{
        NSLog(@"Datami plugin installed but DATAMI_API_KEY is not added to plist");
    }
    return [self _original_saved_by_Override_application:application didFinishLaunchingWithOptions:launchOptions];
}
-(BOOL)_original_saved_by_Override_application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions
{
    // Yet empty (original Unity implementation will be copied here).
    return YES;
}


-(void)handleNotification:(NSNotification *)notif {
    if([notif.name isEqualToString:SDSTATE_CHANGE_NOTIF])
    {
        SmiResult* sr =  notif.object;
        NSLog(@"receivedStateChage, sdState: %ld", (long)sr.sdState);
        if(sr.sdState == SD_NOT_AVAILABLE) {
            NSLog(@"receivedStateChage, sdState: SD_NOT_AVAILABLE with Reason %ld:", (long)sr.sdReason);
        }
        // [self.datamiEvt sendEventWithName:@"DATAMI_EVENT" body:@{@"state": [NSNumber numberWithInteger:sr.sdState]}];
    }
    else
    {
        NSLog(@"Not a datami event");
        
    }
}


@end
