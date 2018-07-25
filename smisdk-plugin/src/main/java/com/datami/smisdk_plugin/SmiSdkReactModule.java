package com.datami.smisdk_plugin;

import android.content.Context;
import android.util.Log;

import com.datami.smi.Analytics;
import com.datami.smi.SmiResult;
import com.datami.smi.SmiSdk;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.ArrayList;
import java.util.List;

public class SmiSdkReactModule extends ReactContextBaseJavaModule {

    private Context mContext;
    private static String TAG = "SmiSdkReactModule";
    private static ReactApplicationContext mReactContext;
    private static SmiResult sSmiResult = null;

    public SmiSdkReactModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
        mReactContext = reactContext;
    }

    @Override
    public String getName() {
        return "SmiSdkReactModule";
    }

    @ReactMethod
    public void getSDAuth(String sdkKey, String url, String userId, Callback smiResultCB){
        Log.d(TAG, "getSDAuth()");
        try {
            SmiResult result = SmiSdk.getSDAuth(sdkKey, mContext, url, userId);
            if(smiResultCB!=null){
                Log.d(TAG, "smiResultCB not null");
                String state = "sd_state: " + result.getSdState().name();
                String reason = "sd_reason: " + result.getSdReason().name();
                String carrier = "carrier_name: " + result.getCarrierName();
                String clientIp = "client_ip: " + result.getClientIp();
                String sdUrl = "url: " + result.getUrl();
                smiResultCB.invoke(state, reason, carrier, clientIp, sdUrl);
            }
        } catch (Exception e) {
            Log.e(TAG, "Exception: ", e);
        }
    }

    @ReactMethod
    public void getAnalytics(Callback smiAnalyticsCB)
    {
        if(mContext==null){
            Log.i(TAG, "Null app context");
            return;
        }
        Analytics smiAnalytics = SmiSdk.getAnalytics();
        if(smiAnalyticsCB!=null){
            String cst = "cellular_session_time: " + smiAnalytics.getCellularSessionTime();
            String dataUsage = "sd_data_usage: " + smiAnalytics.getSdDataUsage();
            String wst = "wifi_session_time: " + smiAnalytics.getWifiSessionTime();
            smiAnalyticsCB.invoke(cst, dataUsage, wst);
        }
    }

    @ReactMethod
    public void updateUserId(String id)
    {
        SmiSdk.updateUserId(id);
    }

    @ReactMethod
    public void updateUserTag(ReadableArray userTags)
    {
        List<String> userTagsJava = null;
        if( (userTags!=null) && (userTags.size()>0))
        {
            userTagsJava = new ArrayList<String>();
            Log.d(TAG, "userTags length: "+userTags.size());
            for(int i=0; i<userTags.size(); i++)
            {
                userTagsJava.add(userTags.getString(i));
            }
            SmiSdk.updateUserTag(userTagsJava);
        }
        else
        {
            Log.d(TAG, "userTags not available.");
        }
    }

    public static void setSmiResultToModule(SmiResult result){
        Log.d(TAG, "setSmiResultToModule.");
        sSmiResult = result;
        // Get EventEmitter from context and send event to it
        if(mReactContext!=null){
            mReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("onSdStateChange", getMappings());
        }
    }

    @ReactMethod
    public void registerSdStateChangeListner(){
        // Get EventEmitter from context and send event to it
        Log.d(TAG, "registerSdStateChangeListner.");
        if(mReactContext!=null){
            mReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("onSdStateChange", getMappings());
        }
    }

    private static WritableMap getMappings(){
        // Create map for params
        Log.d(TAG, "getMappings.");
        WritableMap payload = Arguments.createMap();
        // Put data to map
        if(sSmiResult!=null){
            payload.putString("sd_state", sSmiResult.getSdState().name());
            payload.putString("sd_reason", sSmiResult.getSdReason().name());
            payload.putString("carrier_name", sSmiResult.getCarrierName());
            payload.putString("client_ip", sSmiResult.getClientIp());
        }

        return payload;
    }
}
