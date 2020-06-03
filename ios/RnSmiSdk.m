#import "RnSmiSdk.h"
#import "SmiSdk.h"

@implementation RnSmiSdk

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
{
    // TODO: Implement some actually useful functionality
    callback(@[[NSString stringWithFormat: @"numberArgument: %@ stringArgument: %@", numberArgument, stringArgument]]);
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(getSDURL:(NSString *)url:(RCTResponseSenderBlock)callback) {
    NSString* apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DATAMI_API_KEY"];
    if([apiKey length]) {
        SmiResult *sr = [SmiSdk getSDAuth:apiKey url:url userId:nil];
        NSLog(@"sr.url:%@ sr.state:%ld",sr.url,(long)sr.sdState);
        callback(@[sr.url, [NSNumber numberWithInt:sr.sdState], [NSNumber numberWithInt:sr.sdReason]]);
    }
    else{
        callback(@[[NSNull null], [NSNull null], [NSNull null]]);
    }
}

RCT_EXPORT_METHOD(getAnalytics:(RCTResponseSenderBlock)callback) {
    SmiAnalytics *analytics = [SmiSdk getAnalytics];
    NSTimeInterval wifiTm = analytics.fgWifiSessionTime;
    NSTimeInterval cellTm = analytics.fgCellularSessionTime;
    int64_t sdUsage = analytics.sdDataUsage;
    NSLog(@"Analytics:%f %f %lld",wifiTm,cellTm,sdUsage);
    callback(@[[NSNumber numberWithDouble:wifiTm],[NSNumber numberWithDouble:cellTm],[NSNumber numberWithLongLong:sdUsage]]);
    
}

RCT_EXPORT_METHOD(startSponsoredData) {
    [SmiSdk startSponsorData];
}

RCT_EXPORT_METHOD(stopSponsoredData) {
    [SmiSdk stopSponsorData];
}

RCT_EXPORT_METHOD(registerAppConfiguration:(NSURLSessionConfiguration*) aConfig) {
    [SmiSdk registerAppConfiguration:aConfig];
}

RCT_EXPORT_METHOD(updateUserId:(NSString*)userId) {
    [SmiSdk updateUserId:userId];
}

RCT_EXPORT_METHOD(updateTags:(NSArray *)tags) {
    [SmiSdk updateTag:tags];
}

@end
