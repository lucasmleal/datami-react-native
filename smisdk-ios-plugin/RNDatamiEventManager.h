//
//  RNDatamiEventManager.h
//  RNDatamiSdk
//
//  Created by Sonali Sagar on 30/07/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include("RCTEventEmitter.h")
#import "RCTEventEmitter.h"
#else
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>
#endif

@interface RNDatamiEventManager : RCTEventEmitter <RCTBridgeModule>

@end
