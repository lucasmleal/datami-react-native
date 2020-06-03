
#import <Foundation/Foundation.h>
#import "SmiAnalytics.h"



#define SDSTATE_CHANGE_NOTIF  @"SmiStateChange"


typedef NS_ENUM(NSInteger, SdState) {
    SD_WIFI = 1,
    SD_AVAILABLE = 2,
    SD_NOT_AVAILABLE = 3
};

typedef NS_ENUM(NSInteger, SdReason) {
    SD_REASON_NONE = 0,
    SD_REASON_DUPLICATE_API_CALL = 1,
    SD_NOT_AVAILABLE_FOR_OPERATOR = 2,
    SD_NOT_AVAILABLE_FOR_APPLICATION = 3,
    SD_NOT_AVAILABLE_FOR_URL = 4,
    SD_NOT_AVAILABLE_FOR_DEVICE_OR_USER = 5 ,
    SD_NOT_AVAILABLE_PROMOTION_EXPIRED = 6,
    SD_NOT_AVAILABLE_PROMOTION_SUSPENDED = 7,
    SD_NOT_AVAILABLE_PROMOTION_LIMIT_EXCEEDED = 8,
    SD_NOT_AVAILABLE_USER_LIMIT_EXCEEDED = 9,
    SD_NOT_AVAILABLE_PROMOTION_NOT_FOUND = 10,
    SD_NOT_AVAILABLE_SDK_INTERNAL_ERROR = 11,
    SD_NOT_AVAILABLE_SDK_VERSION_NOT_SUPPORTED = 12,
    SD_NOT_AVAILABLE_SDK_REGISTRATION_NOT_DONE = 13 ,
    SD_NOT_AVAILABLE_SDK_NOT_SUPPORTED_FOR_APP_OR_CARRIER = 14,
    SD_NOT_AVAILABLE_URAM_NO_HEADER_INJECTED = 15,
    SD_NOT_AVAILABLE_SD_NOT_SUPPORTED_IN_ROAMING = 16,
    SD_NOT_AVAILABLE_SD_TESTING = 17,
    SD_NOT_AVAILABLE_APP_API_ENABLED = 18,
    SD_NOT_AVAILABLE_GW_CONNECTION_FAILURE = 19,
    SD_NOT_AVAILABLE_NO_DATA_CONNECTION = 20,
    SD_NOT_AVAILABLE_CONNECTION_TIMEOUT = 21,
    SD_NOT_AVAILABLE_CONNECTION_LOST = 22,
    SD_NOT_AVAILABLE_DNS_ERROR = 23,
    SD_NOT_AVAILABLE_APP_TRANSPORT_SECURITY_ERROR =24,
    SD_NOT_AVAILABLE_SD_STOP_API_CALL = 25,
    SD_NOT_AVAILABLE_ZERO_BALANCE_CAMPAIGN = 26,
    SD_AVAILABLE_ONLY_FOR_ZERO_BALANCE_USERS = 27,
    SD_NOT_AVAILABLE_REASON_UNKNOWN = 100
};


@interface SmiResult : NSObject
{
}

@property (assign, nonatomic) SdState       sdState;
@property (assign, nonatomic) SdReason      sdReason;
@property (strong, nonatomic) NSString      * url;
@property (strong, nonatomic) NSString      *clientIp;
@property (strong, nonatomic) NSString      *carrierName;
@property (strong, nonatomic) NSString      *sdHost;
@property (assign, nonatomic) NSInteger     sdPort;
@property (strong, nonatomic) NSString      *userName;
@property (strong, nonatomic) NSString      *password;

@end

@interface SmiSdk : NSObject
{
}


+(void) initSponsoredData:(NSString*)sdkKey userId:(NSString*)userId showSDMessage: (Boolean) showSDMessage;

+(void)initSponsoredData:(NSString*)sdkKey userId:(NSString*)userId showSDMessage: (Boolean) showSDMessage exclusionDomains:(NSArray*) domains;

+(void)initSponsoredData:(NSString*)sdkKey userId:(NSString*)userId showSDMessage: (Boolean) showSDMessage exclusionDomains:(NSArray*) domains updateTag:(NSArray*)appTag;

+(void)initSponsoredData:(NSString*)sdkKey userId:(NSString*)userId showSDMessage: (Boolean) showSDMessage exclusionUrls:(NSArray*) exUrls;

+ (void)updateTag:(NSArray*)appTag;

+(void)updateUserId:(NSString*)userId;


/* API to sponsor url. Use this API only with initSponsorData */
+(SmiResult*)getSDAuth:(NSString*)sdkKey url:(NSString*)url userId:(NSString*)userId;


/*Its an asyncronous call, App has to register notification for SD_STATE_CHANGE*/
+(void)getAppSDAuth:(NSString*)sdkKey userId:(NSString*)userId showSDMessage: (Boolean) showSDMessage __deprecated __deprecated_msg("use initSponsoredData instead.");


+(void)getAppSDAuth:(NSString*)sdkKey userId:(NSString*)userId showSDMessage: (Boolean) showSDMessage exclusionDomains:(NSArray*) domains __deprecated __deprecated_msg("use initSponsoredData instead.");
;

+(void)registerEvent:(NSString*)evtName withProperties:(NSDictionary*)props;

/* App needs to register custom sessionConfigurations (default/ephemeral) with the sdk */
+(void)registerAppConfiguration:(NSURLSessionConfiguration*) aConfig;

/* call initSponsord data first. API starts sponsor data if not started already */
+(void) startSponsorData;

/* API stops sponsor data if started, no op otherwise */
+(void) stopSponsorData;

+(SmiAnalytics*) getAnalytics;

/* call this API to get username and password to use in VPN profile */
+(SmiResult*)getVpnSDAuth:(NSString*)sdkKey;
#ifdef VPN_API
/* VPN APIs */
+(void) initSponsoredVPN:(NSString*)sdkKey showSDMessage:(Boolean)showSDMessage startVPN:(Boolean) startVPN;
+(void) initSponsoredVPN:(NSString*)sdkKey showSDMessage:(Boolean)showSDMessage;
+(void) startSponsorVpn;
+(void) stopSponsorVpn;
+(SdState) getVpnSdState;

#endif
@end



