package com.polidea.blemulator.bridging;

import android.support.annotation.NonNull;
import android.util.Log;

import com.polidea.blemulator.SimulatedAdapter;
import com.polidea.blemulator.bridging.constants.ArgumentName;
import com.polidea.blemulator.bridging.constants.DownstreamMethodName;
import com.polidea.multiplatformbleadapter.AdvertisementData;
import com.polidea.multiplatformbleadapter.OnErrorCallback;
import com.polidea.multiplatformbleadapter.OnEventCallback;
import com.polidea.multiplatformbleadapter.ScanResult;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class DartValueHandler implements MethodChannel.MethodCallHandler {

    private SimulatedAdapter adapter;

    private OnEventCallback<ScanResult> scanResultPublisher;
    private OnErrorCallback scanResultErrorPublisher;

    public void setAdapter(SimulatedAdapter adapter) {
        this.adapter = adapter;
    }

    public void setScanResultPublisher(OnEventCallback<ScanResult> scanResultPublisher) {
        this.scanResultPublisher = scanResultPublisher;
    }

    public void setScanResultErrorPublisher(OnErrorCallback scanResultErrorPublisher) {
        this.scanResultErrorPublisher = scanResultErrorPublisher;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case DownstreamMethodName.ADD_SCAN_RESULT:
                addScanResult(call, result);
                return;
            default:
                result.notImplemented();
        }
    }

    private void addScanResult(MethodCall call, MethodChannel.Result result) {
        Log.d("BLEMULATOR", "new scan result");
        HashMap<UUID, byte[]> serviceData = null;
        HashMap<String, byte[]> stringServiceData = call.argument(ArgumentName.SERVICE_DATA);
        if (stringServiceData != null) {
            serviceData = new HashMap<>();
            for (Map.Entry<String, byte[]> entry
                    : stringServiceData.entrySet()) {
                serviceData.put(UUID.fromString(entry.getKey()), entry.getValue());
            }
        }


        ArrayList<UUID> serviceUuids = null;
        List<String> stringServiceUuids = call.argument(ArgumentName.SERVICE_UUIDS);
        if (stringServiceUuids != null) {
            serviceUuids = new ArrayList<>();
            for (String uuid : stringServiceUuids) {
                serviceUuids.add(UUID.fromString(uuid));
            }
        }


        ArrayList<UUID> solicitedServiceUuids = null;
        List<String> stringSolicitedServiceUuids = call.argument(ArgumentName.SOLICITED_SERVICE_UUIDS);
        if (stringSolicitedServiceUuids != null) {
            solicitedServiceUuids = new ArrayList<>();
            for (String uuid : stringSolicitedServiceUuids) {
                solicitedServiceUuids.add(UUID.fromString(uuid));
            }
        }


        AdvertisementData advertisementData = new AdvertisementData(
                call.<byte[]>argument(ArgumentName.MANUFACTURER_DATA),
                serviceData,
                serviceUuids,
                call.<String>argument(ArgumentName.LOCAL_NAME),
                call.<Integer>argument(ArgumentName.TX_POWER_LEVEL),
                solicitedServiceUuids
        );

        ArrayList<UUID> overflowServiceUuids;
        UUID[] overflowServiceUuidsArray = null;
        List<String> stringOverflowServiceUuids = call.argument(ArgumentName.OVERFLOW_SERVICE_UUIDS);
        if (stringOverflowServiceUuids != null) {
            overflowServiceUuids = new ArrayList<>();
            for (String uuid : stringOverflowServiceUuids) {
                overflowServiceUuids.add(UUID.fromString(uuid));
            }
            overflowServiceUuidsArray = overflowServiceUuids.toArray(new UUID[0]);
        }

        ScanResult scanResult = new ScanResult(
                call.<String>argument(ArgumentName.DEVICE_ID),
                call.<String>argument(ArgumentName.DEVICE_NAME),
                call.<Integer>argument(ArgumentName.RSSI),
                call.<Integer>argument(ArgumentName.MTU),
                call.<Boolean>argument(ArgumentName.IS_CONNECTABLE),
                overflowServiceUuidsArray,
                advertisementData
        );
        scanResultPublisher.onEvent(scanResult);
        result.success(null);
    }
}
