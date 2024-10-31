package com.polidea.flutter_ble_lib.delegate;

import android.os.Handler;
import android.os.Looper;

import com.polidea.flutter_ble_lib.BleErrorFactory;
import com.polidea.flutter_ble_lib.SafeMainThreadResolver;
import com.polidea.flutter_ble_lib.SingleCharacteristicResponse;
import com.polidea.flutter_ble_lib.constant.ArgumentKey;
import com.polidea.flutter_ble_lib.constant.MethodName;
import com.polidea.flutter_ble_lib.converter.BleErrorJsonConverter;
import com.polidea.flutter_ble_lib.converter.SingleCharacteristicResponseJsonConverter;
import com.polidea.flutter_ble_lib.event.CharacteristicsMonitorStreamHandler;
import com.polidea.multiplatformbleadapter.BleAdapter;
import com.polidea.multiplatformbleadapter.Characteristic;
import com.polidea.multiplatformbleadapter.OnErrorCallback;
import com.polidea.multiplatformbleadapter.OnEventCallback;
import com.polidea.multiplatformbleadapter.OnSuccessCallback;
import com.polidea.multiplatformbleadapter.errors.BleError;
import com.polidea.multiplatformbleadapter.utils.Base64Converter;

import org.json.JSONException;

import java.util.Arrays;
import java.util.List;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CharacteristicsDelegate extends CallDelegate {

    private static List<String> supportedMethods = Arrays.asList(
            MethodName.READ_CHARACTERISTIC_FOR_IDENTIFIER,
            MethodName.READ_CHARACTERISTIC_FOR_DEVICE,
            MethodName.READ_CHARACTERISTIC_FOR_SERVICE,
            MethodName.WRITE_CHARACTERISTIC_FOR_IDENTIFIER,
            MethodName.WRITE_CHARACTERISTIC_FOR_DEVICE,
            MethodName.WRITE_CHARACTERISTIC_FOR_SERVICE,
            MethodName.MONITOR_CHARACTERISTIC_FOR_IDENTIFIER,
            MethodName.MONITOR_CHARACTERISTIC_FOR_DEVICE,
            MethodName.MONITOR_CHARACTERISTIC_FOR_SERVICE
    );

    private BleAdapter bleAdapter;
    private SingleCharacteristicResponseJsonConverter characteristicsResponseJsonConverter =
            new SingleCharacteristicResponseJsonConverter();
    private CharacteristicsMonitorStreamHandler characteristicsMonitorStreamHandler;
    private BleErrorJsonConverter bleErrorJsonConverter = new BleErrorJsonConverter();
    private Handler mainThreadHandler = new Handler(Looper.getMainLooper());

    public CharacteristicsDelegate(BleAdapter bleAdapter, CharacteristicsMonitorStreamHandler characteristicsMonitorStreamHandler) {
        super(supportedMethods);
        this.bleAdapter = bleAdapter;
        this.characteristicsMonitorStreamHandler = characteristicsMonitorStreamHandler;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case MethodName.READ_CHARACTERISTIC_FOR_IDENTIFIER:
                readCharacteristicForIdentifier(
                        call.<Integer>argument(ArgumentKey.CHARACTERISTIC_IDENTIFIER),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            case MethodName.READ_CHARACTERISTIC_FOR_DEVICE:
                readCharacteristicForDevice(
                        call.<String>argument(ArgumentKey.DEVICE_IDENTIFIER),
                        call.<String>argument(ArgumentKey.SERVICE_UUID),
                        call.<String>argument(ArgumentKey.CHARACTERISTIC_UUID),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            case MethodName.READ_CHARACTERISTIC_FOR_SERVICE:
                readCharacteristicForService(
                        call.<Integer>argument(ArgumentKey.SERVICE_IDENTIFIER),
                        call.<String>argument(ArgumentKey.CHARACTERISTIC_UUID),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            case MethodName.WRITE_CHARACTERISTIC_FOR_IDENTIFIER:
                writeCharacteristicForIdentifier(
                        call.<Integer>argument(ArgumentKey.CHARACTERISTIC_IDENTIFIER),
                        call.<byte[]>argument(ArgumentKey.VALUE),
                        call.<Boolean>argument(ArgumentKey.WITH_RESPONSE),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            case MethodName.WRITE_CHARACTERISTIC_FOR_DEVICE:
                writeCharacteristicForDevice(
                        call.<String>argument(ArgumentKey.DEVICE_IDENTIFIER),
                        call.<String>argument(ArgumentKey.SERVICE_UUID),
                        call.<String>argument(ArgumentKey.CHARACTERISTIC_UUID),
                        call.<byte[]>argument(ArgumentKey.VALUE),
                        call.<Boolean>argument(ArgumentKey.WITH_RESPONSE),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            case MethodName.WRITE_CHARACTERISTIC_FOR_SERVICE:
                writeCharacteristicForService(
                        call.<Integer>argument(ArgumentKey.SERVICE_IDENTIFIER),
                        call.<String>argument(ArgumentKey.CHARACTERISTIC_UUID),
                        call.<byte[]>argument(ArgumentKey.VALUE),
                        call.<Boolean>argument(ArgumentKey.WITH_RESPONSE),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            case MethodName.MONITOR_CHARACTERISTIC_FOR_IDENTIFIER:
                monitorCharacteristicForIdentifier(
                        call.<Integer>argument(ArgumentKey.CHARACTERISTIC_IDENTIFIER),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            case MethodName.MONITOR_CHARACTERISTIC_FOR_DEVICE:
                monitorCharacteristicForDevice(
                        call.<String>argument(ArgumentKey.DEVICE_IDENTIFIER),
                        call.<String>argument(ArgumentKey.SERVICE_UUID),
                        call.<String>argument(ArgumentKey.CHARACTERISTIC_UUID),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            case MethodName.MONITOR_CHARACTERISTIC_FOR_SERVICE:
                monitorCharacteristicForService(
                        call.<Integer>argument(ArgumentKey.SERVICE_IDENTIFIER),
                        call.<String>argument(ArgumentKey.CHARACTERISTIC_UUID),
                        call.<String>argument(ArgumentKey.TRANSACTION_ID),
                        result);
                return;
            default:
                throw new IllegalArgumentException(call.method + " cannot be handled by this delegate");
        }
    }

    private void readCharacteristicForIdentifier(
            int characteristicIdentifier,
            final String transactionId,
            final MethodChannel.Result result) {
        final SafeMainThreadResolver<Characteristic> safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        try {
                            result.success(characteristicsResponseJsonConverter.toJson(createCharacteristicResponse(data, transactionId)));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            result.error(null, e.getMessage(), null);
                        }
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                }
        );
        bleAdapter.readCharacteristic(characteristicIdentifier, transactionId,
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        safeMainThreadResolver.onSuccess(data);
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }

    private void readCharacteristicForDevice(
            String deviceIdentifier,
            String serviceUuid,
            String characteristicUuid,
            final String transactionId,
            final MethodChannel.Result result) {

        final SafeMainThreadResolver<Characteristic> safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        try {
                            result.success(characteristicsResponseJsonConverter.toJson(createCharacteristicResponse(data, transactionId)));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            result.error(null, e.getMessage(), null);
                        }
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                }
        );
        bleAdapter.readCharacteristicForDevice(deviceIdentifier, serviceUuid, characteristicUuid, transactionId,
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        safeMainThreadResolver.onSuccess(data);
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }

    private void readCharacteristicForService(int serviceIdentifier, String characteristicUuid, final String transactionId, final MethodChannel.Result result) {
        final SafeMainThreadResolver<Characteristic> safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        try {
                            result.success(characteristicsResponseJsonConverter.toJson(createCharacteristicResponse(data, transactionId)));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            result.error(null, e.getMessage(), null);
                        }
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                }
        );

        bleAdapter.readCharacteristicForService(
                serviceIdentifier,
                characteristicUuid,
                transactionId,
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        safeMainThreadResolver.onSuccess(data);
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }

    private void writeCharacteristicForIdentifier(int characteristicIdentifier,
                                                  byte[] bytesToWrite,
                                                  boolean withResponse,
                                                  final String transactionId,
                                                  final MethodChannel.Result result) {
        final SafeMainThreadResolver<Characteristic> safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        try {
                            result.success(characteristicsResponseJsonConverter.toJson(createCharacteristicResponse(data, transactionId)));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            result.error(null, e.getMessage(), null);
                        }
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                }
        );
        bleAdapter.writeCharacteristic(
                characteristicIdentifier,
                Base64Converter.encode(bytesToWrite),
                withResponse,
                transactionId,
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        safeMainThreadResolver.onSuccess(data);
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }

    private void writeCharacteristicForDevice(String deviceIdentifier,
                                              String serviceUuid,
                                              String characteristicUuid,
                                              byte[] bytesToWrite,
                                              boolean withResponse,
                                              final String transactionId,
                                              final MethodChannel.Result result) {
        final SafeMainThreadResolver<Characteristic> safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        try {
                            result.success(characteristicsResponseJsonConverter.toJson(createCharacteristicResponse(data, transactionId)));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            result.error(null, e.getMessage(), null);
                        }
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                }
        );

        bleAdapter.writeCharacteristicForDevice(
                deviceIdentifier,
                serviceUuid, characteristicUuid,
                Base64Converter.encode(bytesToWrite),
                withResponse,
                transactionId,
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        safeMainThreadResolver.onSuccess(data);
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }

    private void writeCharacteristicForService(int serviceIdentifier,
                                               String characteristicUuid,
                                               byte[] bytesToWrite,
                                               boolean withResponse,
                                               final String transactionId,
                                               final MethodChannel.Result result) {
        final SafeMainThreadResolver<Characteristic> safeMainThreadResolver = new SafeMainThreadResolver<>(
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        try {
                            result.success(characteristicsResponseJsonConverter.toJson(createCharacteristicResponse(data, transactionId)));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            result.error(null, e.getMessage(), null);
                        }
                    }
                },
                new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        result.error(String.valueOf(error.errorCode.code), error.reason, bleErrorJsonConverter.toJson(error));
                    }
                }
        );
        bleAdapter.writeCharacteristicForService(
                serviceIdentifier,
                characteristicUuid,
                Base64Converter.encode(bytesToWrite),
                withResponse,
                transactionId,
                new OnSuccessCallback<Characteristic>() {
                    @Override
                    public void onSuccess(Characteristic data) {
                        safeMainThreadResolver.onSuccess(data);
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(BleError error) {
                        safeMainThreadResolver.onError(error);
                    }
                });
    }

    private void monitorCharacteristicForIdentifier(final int characteristicIdentifier,
                                                    final String transactionId,
                                                    final MethodChannel.Result result) {
        bleAdapter.monitorCharacteristic(
                characteristicIdentifier,
                transactionId, new OnEventCallback<Characteristic>() {
                    @Override
                    public void onEvent(final Characteristic data) {
                        mainThreadHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                try {
                                    characteristicsMonitorStreamHandler.onCharacteristicsUpdate(
                                            createCharacteristicResponse(data, transactionId)
                                    );
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                    characteristicsMonitorStreamHandler.onError(BleErrorFactory.fromThrowable(e), transactionId);
                                }
                            }
                        });
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(final BleError error) {
                        mainThreadHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                characteristicsMonitorStreamHandler.onError(error, transactionId);
                            }
                        });
                    }
                });
        result.success(null);
    }

    private void monitorCharacteristicForDevice(String deviceIdentifier,
                                                String serviceUuid,
                                                String characteristicUuid,
                                                final String transactionId,
                                                final MethodChannel.Result result) {
        bleAdapter.monitorCharacteristicForDevice(
                deviceIdentifier,
                serviceUuid,
                characteristicUuid,
                transactionId,
                new OnEventCallback<Characteristic>() {
                    @Override
                    public void onEvent(final Characteristic data) {
                        mainThreadHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                try {
                                    characteristicsMonitorStreamHandler.onCharacteristicsUpdate(
                                            createCharacteristicResponse(data, transactionId)
                                    );
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                    characteristicsMonitorStreamHandler.onError(BleErrorFactory.fromThrowable(e), transactionId);
                                }
                            }
                        });
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(final BleError error) {
                        mainThreadHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                characteristicsMonitorStreamHandler.onError(error, transactionId);
                            }
                        });
                    }
                });
        result.success(null);
    }

    private void monitorCharacteristicForService(int serviceIdentifier,
                                                 String characteristicUuid,
                                                 final String transactionId,
                                                 final MethodChannel.Result result) {
        bleAdapter.monitorCharacteristicForService(
                serviceIdentifier,
                characteristicUuid,
                transactionId,
                new OnEventCallback<Characteristic>() {
                    @Override
                    public void onEvent(final Characteristic data) {
                        mainThreadHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                try {
                                    characteristicsMonitorStreamHandler.onCharacteristicsUpdate(
                                            createCharacteristicResponse(data, transactionId)
                                    );
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                    characteristicsMonitorStreamHandler.onError(BleErrorFactory.fromThrowable(e), transactionId);
                                }
                            }
                        });
                    }
                }, new OnErrorCallback() {
                    @Override
                    public void onError(final BleError error) {
                        mainThreadHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                characteristicsMonitorStreamHandler.onError(error, transactionId);
                            }
                        });
                    }
                });
        result.success(null);
    }

    private SingleCharacteristicResponse createCharacteristicResponse(Characteristic characteristic, String transactionId) {
        return new SingleCharacteristicResponse(
                characteristic,
                characteristic.getServiceID(),
                characteristic.getServiceUUID(),
                transactionId);
    }
}
