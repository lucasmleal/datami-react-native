#import "AppDelegate+Datami.h"
#import "SmiSdk.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

@implementation AppDelegate (notification)

@dynamic smiResult;
@dynamic datamiEvt;



+ (void)load
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
    
}

- (AppDelegate *)swizzled_init
{
    
    // This actually calls the original init method over in AppDelegate. Equivilent to calling super
    // on an overrided method, this is not recursive, although it appears that way. neat huh?
    return [self init];
}

+ (void)finishLaunching:(NSNotification *)notification
{
    // Call the Datami API at the beginning of didFinishLaunchingWithOptions, before other initializations.
    // IMPORTANT: If Datami API is not the first API called in the application then any network
    // connection made before Datami SDK initialization will be non-sponsored and will be
    // charged to the user.
    
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
}
//
+(void)handleNotification:(NSNotification *)notif {
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
