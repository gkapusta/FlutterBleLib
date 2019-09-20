package com.polidea.flutter_ble_lib.delegate;

import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;

import com.polidea.flutter_ble_lib.ConnectionStateChange;
import com.polidea.flutter_ble_lib.SafeMainThreadResolver;
import com.polidea.flutter_ble_lib.constant.ArgumentKey;
import com.polidea.flutter_ble_lib.constant.MethodName;
import com.polidea.flutter_ble_lib.converter.BleErrorJsonConverter;
import com.polidea.flutter_ble_lib.converter.ConnectionStateChangeJsonConverter;
import com.polidea.flutter_ble_lib.event.ConnectionStateStreamHandler;
import com.polidea.multiplatformbleadapter.BleAdapter;
import com.polidea.multiplatformbleadapter.ConnectionOptions;
import com.polidea.multiplatformbleadapter.ConnectionState;
import com.polidea.multiplatformbleadapter.Device;
import com.polidea.multiplatformbleadapter.OnErrorCallback;
import com.polidea.multiplatformbleadapter.OnEventCallback;
import com.polidea.multiplatformbleadapter.OnSuccessCallback;
import com.polidea.multiplatformbleadapter.RefreshGattMoment;
import com.polidea.multiplatformbleadapter.errors.BleError;

import java.util.Arrays;
import java.util.List;

import org.json.JSONException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class DeviceConnectionDelegate extends CallDelegate {

    private static  List<String> supportedMethods = Arrays.asList(
            MethodName.CONNECT_TO_DEVICE,
            MethodName.IS_DEVICE_CONNECTED,
            MethodName.OBSERVE_CONNECTION_STATE,
            MethodName.CANCEL_CONNECTION
    );

    private BleAdapter bleAdapter;
    private ConnectionStateStreamHandler streamHandler;
    private BleErrorJsonConverter bleErrorJsonConverter = new BleErrorJsonConverter();

    public DeviceConnectionDelegate(BleAdapter bleAdapter, ConnectionStateStreamHandler streamHandler) {
        super(supportedMethods);
        this.bleAdapter = bleAdapter;
        this.streamHandler = streamHandler;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String deviceId = call.argument(ArgumentKey.DEVICE_IDENTIFIER);
        switch (call.method) {
            case MethodName.CONNECT_TO_DEVICE:
                connectToDevice(deviceId,
                        call.<Boolean>argument(ArgumentKey.IS_AUTO_CONNECT),
                        call.<Integer>argument(ArgumentKey.REQUEST_MTU),
                        call.<Boolean>argument(ArgumentKey.REFRESH_GATT),
                        call.<Long>argument(ArgumentKey.TIMEOUT_MILLIS),
                        result);
                return;
            case MethodName.IS_DEVICE_CONNECTED:
                isDeviceConnected(deviceId, result);
                return;
            case MethodName.OBSERVE_CONNECTION_STATE:
                observeConnectionState(deviceId, call.<Boolean>argument(ArgumentKey.EMIT_CURRENT_VALUE), result);
                return;
            case MethodName.CANCEL_CONNECTION:
                cancelConnection(deviceId, result);
                return;
            default:
                throw new IllegalArgumentException(call.method + " cannot be handled by this delegate");
        }
    }

    private void connectToDevice(final String deviceId, Boolean isAutoConnect, Integer requestMtu, Boolean refreshGatt, Long timeoutMillis, @NonNull final MethodChannel.Result result) {
        RefreshGattMoment refreshGattMoment = null;
        if (refreshGatt) refreshGattMoment = RefreshGattMoment.ON_CONNECTED;

        final SafeMainThreadResolver safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Object>() {
                    @Override
                    public void onSuccess(Object data) {
                        result.success(null);
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                });

        int connectionPriorityBalanced = 0; //BluetoothGatt.CONNECTION_PRIORITY_BALANCED
        bleAdapter.connectToDevice(deviceId,
                new ConnectionOptions(isAutoConnect, requestMtu, refreshGattMoment, timeoutMillis, connectionPriorityBalanced),
                new OnSuccessCallback<Device>() {
                    @Override
                    public void onSuccess(Device data) {
                        safeMainThreadResolver.onSuccess(null);
                    }
                },
                new OnEventCallback<ConnectionState>() {
                    @Override
                    public void onEvent(final ConnectionState data) {
                        String temp;
                        try {
                            temp = new ConnectionStateChangeJsonConverter().toJson(new ConnectionStateChange(deviceId, data));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            return;
                        }

                        final String newData = temp;

                        new Handler(Looper.getMainLooper()).post(new Runnable() {
                            @Override
                            public void run() {

                                streamHandler.onNewConnectionState(newData);
                            }
                        });
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(final BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }

    private void observeConnectionState(final String deviceId, boolean emitCurrentValue, @NonNull final MethodChannel.Result result) {
        //emit current value if needed; rest is published automatically through connectToDevice()

        final SafeMainThreadResolver safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean data) {
                        String newData;

                        ConnectionState state;
                        if (data)
                            state = ConnectionState.CONNECTED;
                        else
                            state = ConnectionState.DISCONNECTED;

                        try {
                            newData = new ConnectionStateChangeJsonConverter().toJson(new ConnectionStateChange(deviceId, state));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            return;
                        }
                        streamHandler.onNewConnectionState(newData);
                        result.success(data);
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                });

        if (emitCurrentValue)
            bleAdapter.isDeviceConnected(deviceId,
                    new OnSuccessCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean data) {
                            safeMainThreadResolver.onSuccess(data);
                        }
                    }, new OnErrorCallback() {
                        @Override
                        public void onError(BleError error) {
                            safeMainThreadResolver.onError(error);
                        }
                    });
    }

    private void isDeviceConnected(String deviceId, @NonNull final MethodChannel.Result result) {
        final SafeMainThreadResolver safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean data) {
                        result.success(data);
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                });

        bleAdapter.isDeviceConnected(deviceId,
                new OnSuccessCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean data) {
                        safeMainThreadResolver.onSuccess(data);
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }

    private void cancelConnection(String deviceId, @NonNull final MethodChannel.Result result) {
        final SafeMainThreadResolver safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Object>() {
                    @Override
                    public void onSuccess(Object data) {
                        result.success(null);
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                });

        bleAdapter.cancelDeviceConnection(deviceId,
                new OnSuccessCallback<Device>() {
                    @Override
                    public void onSuccess(Device data) {
                        safeMainThreadResolver.onSuccess(null);
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }
}
