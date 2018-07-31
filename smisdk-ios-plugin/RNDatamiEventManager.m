//
//  RNDatamiEventManager.m
//  RNDatamiSdk
//
//  Created by Sonali Sagar on 30/07/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNDatamiEventManager.h"
#import "SmiSdk.h"

@implementation RNDatamiEventManager
{
    bool hasListeners;
    SmiResult* sr;
}


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+(BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE()

-(id)init {
  if(self = [super init]){
      hasListeners = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SDSTATE_CHANGE_NOTIF
                                               object:nil];
  }

  return self;
}

-(void)startObserving {
    hasListeners = YES;
    if(sr != nil) {
        [self sendEventWithName:@"DATAMI_EVENT" body:@{@"state": [NSNumber numberWithInteger:sr.sdState]}];
    }
}

-(void)stopObserving {
    hasListeners = NO;
}

-(NSArray<NSString *> *)supportedEvents
{
        return @[@"DATAMI_EVENT"];
}

- (void)handleNotification:(NSNotification *)notif {
    if([notif.name isEqualToString:SDSTATE_CHANGE_NOTIF])
    {   
        sr =  notif.object;
        NSLog(@"receivedStateChage, sdState: %ld", (long)sr.sdState);
        if(hasListeners) {
            [self sendEventWithName:@"DATAMI_EVENT" body:@{@"state": [NSNumber numberWithInteger:sr.sdState]}];
        }
    }
    else
    {
        NSLog(@"Not a datami event");
        
    }
}

@end
