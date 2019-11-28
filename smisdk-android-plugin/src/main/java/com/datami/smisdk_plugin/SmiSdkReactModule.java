package com.datami.smisdk_plugin;

import android.content.Context;
import android.util.Log;

import com.datami.smi.Analytics;
import com.datami.smi.SmiResult;
import com.datami.smi.SmiSdk;
import com.datami.smi.SmiVpnSdk;
import com.datami.smi.SdState;
import com.datami.smi.internal.MessagingType;
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
    public void getCurrentSdState(Callback stateCB){
        Log.d(TAG, "getCurrentSdState()");
        SdState st = SmiVpnSdk.getCurrentSdState();
        if(stateCB!=null){
            WritableMap payload = Arguments.createMap();
            payload.putString("sd_state", st.toString());
            stateCB.invoke(payload);
        }        
    }

    @ReactMethod
    public void startSponsoredData(){
        Log.d(TAG, "startSponsoredData()");
        
        SmiVpnSdk.startSponsoredData();
    }

    @ReactMethod
    public void stopSponsoredData(){
        Log.d(TAG, "stopSponsoredData()");
        
        SmiVpnSdk.stopSponsoredData();
    }

    @ReactMethod
    public void initSponsoredData(String sdkKey, int iconId, MessagingType messagingType, boolean startVpn){
        Log.d(TAG, "initSponsoredData()");
        if(mContext){
            Log.e(TAG, "App context is null!");
            return;
        }
        SmiVpnSdk.initSponsoredData(sdkKey, mContext, iconId, messagingType, startVpn);
    }

    public static void setSmiResultToModule(SmiResult result){
        Log.d(TAG, "setSmiResultToModule.");
        sSmiResult = result;
        // Get EventEmitter from context and send event to it
        if(mReactContext!=null){
            if (mReactContext.hasActiveCatalystInstance()){
                mReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit("onSdStateChange", getMappings());
            }
        }
    }

    @ReactMethod
    public void registerSdStateChangeListner(){
        // Get EventEmitter from context and send event to it
        Log.d(TAG, "registerSdStateChangeListner.");
        if(mReactContext!=null){
            if (mReactContext.hasActiveCatalystInstance()){
                mReactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit("onSdStateChange", getMappings());
            }
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
