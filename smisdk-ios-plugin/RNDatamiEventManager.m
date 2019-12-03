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
        NSLog(@"receivedStateChage, sdState: %ld sr.clientIp:%@ sr.carrierName:%@ sdReason: %ld ", (long)sr.sdState, sr.clientIp, sr.carrierName, sr.sdReason);
        if(hasListeners) {
          if(sr.clientIp != nil){
            [self sendEventWithName:@"DATAMI_EVENT" body:@{@"state": [NSNumber numberWithInteger:sr.sdState],@"sdReason": [NSNumber numberWithInt:sr.sdReason],
         @"clientIp": sr.clientIp, @"carrierName": sr.carrierName}];
          }else{
            [self sendEventWithName:@"DATAMI_EVENT" body:@{@"state": [NSNumber numberWithInteger:sr.sdState],@"sdReason": [NSNumber numberWithInt:sr.sdReason],
         @"carrierName": sr.carrierName}];
          }
        }
    }
    else
    {
        NSLog(@"Not a datami event");
        
    }
}

@end
