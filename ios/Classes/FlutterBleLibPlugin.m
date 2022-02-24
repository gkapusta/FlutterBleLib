#import "FlutterBleLibPlugin.h"
#import "ArgumentKey.h"
#import "ChannelName.h"
#import "MethodName.h"
#import "AdapterStateStreamHandler.h"
#import "RestoreStateStreamHandler.h"
#import "ScanningStreamHandler.h"
#import "ConnectionStateStreamHandler.h"
#import "MonitorCharacteristicStreamHandler.h"
#import "ArgumentHandler.h"
#import "FlutterErrorFactory.h"
#import "CommonTypes.h"
#import "CharacteristicResponseConverter.h"
#import "PeripheralResponseConverter.h"
#import "DescriptorResponseConverter.h"
#import "ServiceResponseConverter.h"

@import MultiplatformBleAdapter;

@interface FlutterBleLibPlugin () <BleClientManagerDelegate>

@property (nonatomic) id <BleAdapter> adapter;
@property (nonatomic) AdapterStateStreamHandler *adapterStateStreamHandler;
@property (nonatomic) RestoreStateStreamHandler *restoreStateStreamHandler;
@property (nonatomic) ScanningStreamHandler *scanningStreamHandler;
@property (nonatomic) ConnectionStateStreamHandler *connectionStateStreamHandler;
@property (nonatomic) MonitorCharacteristicStreamHandler *monitorCharacteristicStreamHandler;

@end

@implementation FlutterBleLibPlugin

// MARK: - Initializers

- (instancetype)init {
    self = [super init];
    if (self) {
        self.adapterStateStreamHandler = [AdapterStateStreamHandler new];
        self.restoreStateStreamHandler = [RestoreStateStreamHandler new];
        self.scanningStreamHandler = [ScanningStreamHandler new];
        self.connectionStateStreamHandler = [ConnectionStateStreamHandler new];
        self.monitorCharacteristicStreamHandler = [MonitorCharacteristicStreamHandler new];
    }
    return self;
}

// MARK: - FlutterPlugin implementation

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME_FLUTTER_BLE_LIB binaryMessenger:[registrar messenger]];

    FlutterEventChannel *adapterStateChannel = [FlutterEventChannel eventChannelWithName:CHANNEL_NAME_ADAPTER_STATE_CHANGES binaryMessenger:[registrar messenger]];
    FlutterEventChannel *restoreStateChannel = [FlutterEventChannel eventChannelWithName:CHANNEL_NAME_STATE_RESTORE_EVENTS binaryMessenger:[registrar messenger]];
    FlutterEventChannel *scanningChannel = [FlutterEventChannel eventChannelWithName:CHANNEL_NAME_SCANNING_EVENTS binaryMessenger:[registrar messenger]];
    FlutterEventChannel *connectionStateChannel = [FlutterEventChannel eventChannelWithName:CHANNEL_NAME_CONNECTION_STATE_CHANGE_EVENTS binaryMessenger:[registrar messenger]];
    FlutterEventChannel *monitorCharacteristicChannel = [FlutterEventChannel eventChannelWithName:CHANNEL_NAME_MONITOR_CHARACTERISTIC binaryMessenger:[registrar messenger]];

    FlutterBleLibPlugin *instance = [[FlutterBleLibPlugin alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channel];

    [adapterStateChannel setStreamHandler:instance.adapterStateStreamHandler];
    [restoreStateChannel setStreamHandler:instance.restoreStateStreamHandler];
    [scanningChannel setStreamHandler:instance.scanningStreamHandler];
    [connectionStateChannel setStreamHandler:instance.connectionStateStreamHandler];
    [monitorCharacteristicChannel setStreamHandler:instance.monitorCharacteristicStreamHandler];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([METHOD_NAME_CREATE_CLIENT isEqualToString:call.method]) {
        [self createClient:call result:result];
    } else if ([METHOD_NAME_DESTROY_CLIENT isEqualToString:call.method]) {
        [self destroyClient];
    } else if ([METHOD_NAME_IS_CLIENT_CREATED isEqualToString:call.method]) {
        [self isClientCreated:call result:result];
    } else if ([METHOD_NAME_ENABLE_RADIO isEqualToString:call.method]) {
        [self enable:call result:result];
    } else if ([METHOD_NAME_DISABLE_RADIO isEqualToString:call.method]) {
        [self disable:call result:result];
    } else if ([METHOD_NAME_GET_STATE isEqualToString:call.method]) {
        [self state:call result:result];
    } else if ([METHOD_NAME_START_DEVICE_SCAN isEqualToString:call.method]) {
        [self startDeviceScan:call result:result];
    } else if ([METHOD_NAME_STOP_DEVICE_SCAN isEqualToString:call.method]) {
        [self stopDeviceScan:result];
    } else if ([METHOD_NAME_CONNECT_TO_DEVICE isEqualToString:call.method]) {
        [self connectToDevice:call result:result];
    } else if ([METHOD_NAME_CANCEL_CONNECTION isEqualToString:call.method]) {
        [self cancelDeviceConnection:call result:result];
    } else if ([METHOD_NAME_IS_DEVICE_CONNECTED isEqualToString:call.method]) {
        [self isDeviceConnected:call result:result];
    } else if ([METHOD_NAME_OBSERVE_CONNECTION_STATE isEqualToString:call.method]) {
        [self observeConnectionState:call result:result];
    } else if ([METHOD_NAME_SET_LOG_LEVEL isEqualToString:call.method]) {
        [self setLogLevel:call result:result];
    } else if ([METHOD_NAME_LOG_LEVEL isEqualToString:call.method]) {
        [self logLevel:call result:result];
    } else if ([METHOD_NAME_GET_SERVICES isEqualToString:call.method]) {
        [self servicesForDevice:call result:result];
    } else if ([METHOD_NAME_DISCOVER_ALL_SERVICES_AND_CHARACTERISTICS isEqualToString:call.method]) {
        [self discoverAllServicesAndCharacteristicsForDevice:call result:result];
    } else if ([METHOD_NAME_GET_CHARACTERISTICS_FOR_SERVICE isEqualToString:call.method]) {
        [self characteristicsForService:call result:result];
    } else if ([METHOD_NAME_GET_CHARACTERISTICS isEqualToString:call.method]) {
        [self characteristics:call result:result];
    } else if ([METHOD_NAME_GET_DESCRIPTORS_FOR_DEVICE isEqualToString:call.method]) {
        [self descriptorsForDevice:call result:result];
    } else if ([METHOD_NAME_GET_DESCRIPTORS_FOR_SERVICE isEqualToString:call.method]) {
        [self descriptorsForService:call result:result];
    } else if ([METHOD_NAME_GET_DESCRIPTORS_FOR_CHARACTERISTIC isEqualToString:call.method]) {
        [self descriptorsForCharacteristic:call result:result];
    } else if ([METHOD_NAME_READ_CHARACTERISTIC_FOR_DEVICE isEqualToString:call.method]) {
        [self readCharacteristicForDevice:call result:result];
    } else if ([METHOD_NAME_READ_CHARACTERISTIC_FOR_SERVICE isEqualToString:call.method]) {
        [self readCharacteristicForService:call result:result];
    } else if ([METHOD_NAME_READ_CHARACTERISTIC_FOR_IDENTIFIER isEqualToString:call.method]) {
        [self readCharacteristic:call result:result];
    } else if ([METHOD_NAME_WRITE_CHARACTERISTIC_FOR_DEVICE isEqualToString:call.method]) {
        [self writeCharacteristicForDevice:call result:result];
    } else if ([METHOD_NAME_WRITE_CHARACTERISTIC_FOR_SERVICE isEqualToString:call.method]) {
        [self writeCharacteristicForService:call result:result];
    } else if ([METHOD_NAME_WRITE_CHARACTERISTIC_FOR_IDENTIFIER isEqualToString:call.method]) {
        [self writeCharacteristic:call result:result];
    } else if ([METHOD_NAME_MONITOR_CHARACTERISTIC_FOR_DEVICE isEqualToString:call.method]) {
        [self monitorCharacteristicForDevice:call result:result];
    } else if ([METHOD_NAME_MONITOR_CHARACTERISTIC_FOR_SERVICE isEqualToString:call.method]) {
        [self monitorCharacteristicForService:call result:result];
    } else if ([METHOD_NAME_MONITOR_CHARACTERISTIC_FOR_IDENTIFIER isEqualToString:call.method]) {
        [self monitorCharacteristic:call result:result];
    } else if ([METHOD_NAME_READ_DESCRIPTOR_FOR_DEVICE isEqualToString:call.method]) {
        [self readDescriptorForDevice:call result:result];
    } else if ([METHOD_NAME_READ_DESCRIPTOR_FOR_SERVICE isEqualToString:call.method]) {
        [self readDescriptorForService:call result:result];
    } else if ([METHOD_NAME_READ_DESCRIPTOR_FOR_CHARACTERISTIC isEqualToString:call.method]) {
        [self readDescriptorForCharacteristic:call result:result];
    } else if ([METHOD_NAME_READ_DESCRIPTOR_FOR_IDENTIFIER isEqualToString:call.method]) {
        [self readDescriptorForIdentifier:call result:result];
    } else if ([METHOD_NAME_WRITE_DESCRIPTOR_FOR_DEVICE isEqualToString:call.method]) {
        [self writeDescriptorForDevice:call result:result];
    } else if ([METHOD_NAME_WRITE_DESCRIPTOR_FOR_SERVICE isEqualToString:call.method]) {
        [self writeDescriptorForService:call result:result];
    } else if ([METHOD_NAME_WRITE_DESCRIPTOR_FOR_CHARACTERISTIC isEqualToString:call.method]) {
        [self writeDescriptorForCharacteristic:call result:result];
    } else if ([METHOD_NAME_WRITE_DESCRIPTOR_FOR_IDENTIFIER isEqualToString:call.method]) {
        [self writeDescriptorForIdentifier:call result:result];
    } else if ([METHOD_NAME_GET_KNOWN_DEVICES isEqualToString:call.method]) {
        [self devices:call result:result];
    } else if ([METHOD_NAME_GET_CONNECTED_DEVICES isEqualToString:call.method]) {
        [self connectedDevices:call result:result];
    } else if ([METHOD_NAME_REQUEST_MTU isEqualToString:call.method]) {
        [self requestMTUForDevice:call result:result];
    } else if ([METHOD_NAME_RSSI isEqualToString:call.method]) {
        [self readRSSIForDevice:call result:result];
    } else if ([METHOD_NAME_CANCEL_TRANSACTION isEqualToString:call.method]) {
        [self cancelTransaction:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// MARK: - MBA Methods - BleClient lifecycle

- (void)isClientCreated:(FlutterMethodCall *)call result:(FlutterResult)result {
    result([NSNumber numberWithBool:_adapter != nil]);
}

- (void)createClient:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (_adapter != nil) {
        NSLog(@"Overwriting existing native client. Use BleManager#isClientCreated to check whether a client already exists.");
    }
    _adapter = [BleAdapterFactory getNewAdapterWithQueue:dispatch_get_main_queue()
                                    restoreIdentifierKey:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_RESTORE_STATE_IDENTIFIER]]];
    _adapter.delegate = self;
    result(nil);
}

- (void)destroyClient {
    [_adapter invalidate];
    _adapter = nil;
}

- (void)invalidate {
    [self destroyClient];
}

// MARK: - MBA Methods - BT state monitoring

- (void)enable:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter enable:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
             resolve:result
              reject:[self rejectForFlutterResult:result]];
}

- (void)disable:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter disable:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
              resolve:result
               reject:[self rejectForFlutterResult:result]];
}

- (void)state:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter state:result
             reject:[self rejectForFlutterResult:result]];
}

// MARK: - MBA Methods - Scanning

- (void)startDeviceScan:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray* expectedArguments = [NSArray arrayWithObjects:ARGUMENT_KEY_ALLOW_DUPLICATES, nil];
    [_adapter startDeviceScan:[ArgumentHandler stringArrayOrNil:call.arguments[ARGUMENT_KEY_UUIDS]]
                      options:[ArgumentHandler dictionaryOrNil:expectedArguments in:call.arguments]];
    result(nil);
}

- (void)stopDeviceScan:(FlutterResult)result {
    [_adapter stopDeviceScan];
    [self.scanningStreamHandler onComplete];
    result(nil);
}

// MARK: - MBA Methods - Connection

- (void)connectToDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray* expectedArguments = [NSArray arrayWithObjects:ARGUMENT_KEY_TIMEOUT_MILLIS, nil];
    [_adapter connectToDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                      options:[ArgumentHandler dictionaryOrNil:expectedArguments in:call.arguments]
                      resolve:result
                       reject:[self rejectForFlutterResult:result]];
}

- (void)cancelDeviceConnection:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter cancelDeviceConnection:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                             resolve:[self resolveForCancelConnection:result]
                              reject:[self rejectForFlutterResult:result]];
}

- (void)isDeviceConnected:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter isDeviceConnected:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                        resolve:result
                         reject:[self rejectForFlutterResult:result]];

}

- (void)observeConnectionState:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL emitCurrentValue = ((NSNumber *)call.arguments[ARGUMENT_KEY_EMIT_CURRENT_VALUE]).boolValue;
    if (emitCurrentValue == YES) {
        Resolve resolve = ^(id isConnected) {
            if ([isConnected boolValue] == YES) {
                [self.connectionStateStreamHandler onConnectedEvent:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]];
            } else {
                [self.connectionStateStreamHandler emitDisconnectedEvent:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]];
            }
            result(nil);
        };
        [self isDeviceConnected:call result:resolve];
    } else {
        result(nil);
    }

}

// MARK: - MBA Methods - Log Level

- (void)setLogLevel:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *logLevel = call.arguments[ARGUMENT_KEY_LOG_LEVEL];
    [_adapter setLogLevel:[logLevel capitalizedString]];
    result(nil);
}

- (void)logLevel:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter logLevel:result
                reject:[self rejectForFlutterResult:result]];
}

// MARK: - MBA Methods - Discovery

- (void)servicesForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter servicesForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                        resolve:[self resolveForServicesForDevice:result]
                         reject:[self rejectForFlutterResult:result]];
}

- (void)discoverAllServicesAndCharacteristicsForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter discoverAllServicesAndCharacteristicsForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                                               transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                                     resolve:result
                                                      reject:[self rejectForFlutterResult:result]];
}

- (void)characteristicsForService:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter characteristicsForService:[call.arguments[ARGUMENT_KEY_SERVICE_ID] doubleValue]
                                resolve:[self resolveForCharacteristicsForService:result]
                                 reject:[self rejectForFlutterResult:result]];
}

- (void)characteristics:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter characteristicsForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                       serviceUUID:call.arguments[ARGUMENT_KEY_SERVICE_UUID]
                           resolve:[self resolveForCharacteristics:result]
                            reject:[self rejectForFlutterResult:result]];
}

- (void)descriptorsForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter descriptorsForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                       serviceUUID:call.arguments[ARGUMENT_KEY_SERVICE_UUID]
                characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                           resolve:[self resolveForDescriptors:result]
                            reject:[self rejectForFlutterResult:result]];
}

- (void)descriptorsForService:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter descriptorsForService:[call.arguments[ARGUMENT_KEY_SERVICE_ID] doubleValue]
                 characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                            resolve:[self resolveForDescriptors:result]
                             reject:[self rejectForFlutterResult:result]];
}

- (void)descriptorsForCharacteristic:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter descriptorsForCharacteristic:[call.arguments[ARGUMENT_KEY_CHARACTERISTIC_IDENTIFIER] doubleValue]
                                   resolve:[self resolveForDescriptors:result]
                                    reject:[self rejectForFlutterResult:result]];
}

// MARK: - MBA Methods - Characteristics operations

- (void)readCharacteristicForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter readCharacteristicForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                              serviceUUID:call.arguments[ARGUMENT_KEY_SERVICE_UUID]
                       characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                            transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                  resolve:[self resolveForReadWriteCharacteristic:result
                                                                    transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]]
                                   reject:[self rejectForFlutterResult:result]];
}

- (void)readCharacteristicForService:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter readCharacteristicForService:[call.arguments[ARGUMENT_KEY_SERVICE_ID] doubleValue]
                        characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                             transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                   resolve:[self resolveForReadWriteCharacteristic:result
                                                                     transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]]
                                    reject:[self rejectForFlutterResult:result]];
}

- (void)readCharacteristic:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter readCharacteristic:[call.arguments[ARGUMENT_KEY_CHARACTERISTIC_IDENTIFIER] doubleValue]
                   transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                         resolve:[self resolveForReadWriteCharacteristic:result
                                                           transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]]
                          reject:[self rejectForFlutterResult:result]];
}

- (void)writeCharacteristicForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter writeCharacteristicForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                               serviceUUID:call.arguments[ARGUMENT_KEY_SERVICE_UUID]
                        characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                               valueBase64:[self base64encodedStringFromBytes:call.arguments[ARGUMENT_KEY_VALUE]]
                                  response:((NSNumber *)call.arguments[ARGUMENT_KEY_WITH_RESPONSE]).boolValue
                             transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                   resolve:[self resolveForReadWriteCharacteristic:result
                                                                     transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]]
                                    reject:[self rejectForFlutterResult:result]];
}

- (void)writeCharacteristicForService:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter writeCharacteristicForService:[call.arguments[ARGUMENT_KEY_SERVICE_ID] doubleValue]
                         characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                                valueBase64:[self base64encodedStringFromBytes:call.arguments[ARGUMENT_KEY_VALUE]]
                                   response:((NSNumber *)call.arguments[ARGUMENT_KEY_WITH_RESPONSE]).boolValue
                              transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                    resolve:[self resolveForReadWriteCharacteristic:result
                                                                      transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]]
                                     reject:[self rejectForFlutterResult:result]];
}

- (void)writeCharacteristic:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter writeCharacteristic:[call.arguments[ARGUMENT_KEY_CHARACTERISTIC_IDENTIFIER] doubleValue]
                      valueBase64:[self base64encodedStringFromBytes:call.arguments[ARGUMENT_KEY_VALUE]]
                         response:((NSNumber *)call.arguments[ARGUMENT_KEY_WITH_RESPONSE]).boolValue
                    transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                          resolve:[self resolveForReadWriteCharacteristic:result
                                                            transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]]
                           reject:[self rejectForFlutterResult:result]];
}

- (void)monitorCharacteristicForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter monitorCharacteristicForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                                 serviceUUID:call.arguments[ARGUMENT_KEY_SERVICE_UUID]
                          characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                               transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                     resolve:[self resolveForMonitorCharacteristic:result]
                                      reject:[self rejectForFlutterResult:result]];
}

- (void)monitorCharacteristicForService:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter monitorCharacteristicForService:[call.arguments[ARGUMENT_KEY_SERVICE_ID] doubleValue]
                           characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                                transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                      resolve:[self resolveForMonitorCharacteristic:result]
                                       reject:[self rejectForFlutterResult:result]];

}

- (void)monitorCharacteristic:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter monitorCharacteristic:[call.arguments[ARGUMENT_KEY_CHARACTERISTIC_IDENTIFIER] doubleValue]
                      transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                            resolve:[self resolveForMonitorCharacteristic:result]
                             reject:[self rejectForFlutterResult:result]];
}

// MARK: - MBA Method - Descriptor operations

- (void)readDescriptorForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter readDescriptorForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                          serviceUUID:call.arguments[ARGUMENT_KEY_SERVICE_UUID]
                   characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                       descriptorUUID:call.arguments[ARGUMENT_KEY_DESCRIPTOR_UUID]
                        transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                              resolve:[self resolveForReadWriteDescriptor:result]
                               reject:[self rejectForFlutterResult:result]];
}

- (void)readDescriptorForService:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter readDescriptorForService:[call.arguments[ARGUMENT_KEY_SERVICE_ID] doubleValue]
                    characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                        descriptorUUID:call.arguments[ARGUMENT_KEY_DESCRIPTOR_UUID]
                         transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                               resolve:[self resolveForReadWriteDescriptor:result]
                                reject:[self rejectForFlutterResult:result]];
}

- (void)readDescriptorForCharacteristic:(FlutterMethodCall *) call result:(FlutterResult) result {
    [_adapter readDescriptorForCharacteristic:[call.arguments[ARGUMENT_KEY_CHARACTERISTIC_IDENTIFIER] doubleValue]
                               descriptorUUID:call.arguments[ARGUMENT_KEY_DESCRIPTOR_UUID]
                                transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                      resolve:[self resolveForReadWriteDescriptor:result]
                                       reject:[self rejectForFlutterResult:result]];
}

- (void)readDescriptorForIdentifier:(FlutterMethodCall *) call result:(FlutterResult) result {
    [_adapter readDescriptor:[call.arguments[ARGUMENT_KEY_DESCRIPTOR_IDENTIFIER] doubleValue]
               transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                     resolve:[self resolveForReadWriteDescriptor:result]
                      reject:[self rejectForFlutterResult:result]];
}

- (void)writeDescriptorForDevice:(FlutterMethodCall *) call result:(FlutterResult) result {
    [_adapter writeDescriptorForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                           serviceUUID:call.arguments[ARGUMENT_KEY_SERVICE_UUID]
                    characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                        descriptorUUID:call.arguments[ARGUMENT_KEY_DESCRIPTOR_UUID]
                           valueBase64:[self base64encodedStringFromBytes:call.arguments[ARGUMENT_KEY_VALUE]]
                         transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                               resolve:[self resolveForReadWriteDescriptor:result]
                                reject:[self rejectForFlutterResult:result]];
}

- (void)writeDescriptorForService:(FlutterMethodCall *) call result:(FlutterResult) result {
    [_adapter writeDescriptorForService:[call.arguments[ARGUMENT_KEY_SERVICE_ID] doubleValue]
                     characteristicUUID:call.arguments[ARGUMENT_KEY_CHARACTERISTIC_UUID]
                         descriptorUUID:call.arguments[ARGUMENT_KEY_DESCRIPTOR_UUID]
                            valueBase64:[self base64encodedStringFromBytes:call.arguments[ARGUMENT_KEY_VALUE]]
                          transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                resolve:[self resolveForReadWriteDescriptor:result]
                                 reject:[self rejectForFlutterResult:result]];
}

- (void)writeDescriptorForCharacteristic:(FlutterMethodCall *) call result:(FlutterResult) result {
    [_adapter writeDescriptorForCharacteristic:[call.arguments[ARGUMENT_KEY_CHARACTERISTIC_IDENTIFIER] doubleValue]
                                descriptorUUID:call.arguments[ARGUMENT_KEY_DESCRIPTOR_UUID]
                                   valueBase64:[self base64encodedStringFromBytes:call.arguments[ARGUMENT_KEY_VALUE]]
                                 transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                                       resolve:[self resolveForReadWriteDescriptor:result]
                                        reject:[self rejectForFlutterResult:result]];
}

- (void)writeDescriptorForIdentifier:(FlutterMethodCall *) call result:(FlutterResult) result {
    [_adapter writeDescriptor:[call.arguments[ARGUMENT_KEY_DESCRIPTOR_IDENTIFIER] doubleValue]
                  valueBase64:[self base64encodedStringFromBytes:call.arguments[ARGUMENT_KEY_VALUE]]
                transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                      resolve:[self resolveForReadWriteDescriptor:result]
                       reject:[self rejectForFlutterResult:result]];
}

// MARK: - MBA Methods - Known / Connected devices

- (void)devices:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter devices:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIERS]
              resolve:[self resolveForKnownConnectedDevices:result]
               reject:[self rejectForFlutterResult:result]];
}

- (void)connectedDevices:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter connectedDevices:call.arguments[ARGUMENT_KEY_UUIDS]
                       resolve:[self resolveForKnownConnectedDevices:result]
                        reject:[self rejectForFlutterResult:result]];
}

// MARK: - MBA Methods - MTU

- (void)requestMTUForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter requestMTUForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                              mtu:[call.arguments[ARGUMENT_KEY_MTU] integerValue]
                    transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                          resolve:[self resolveForRequestMTUForDevice:result]
                           reject:[self rejectForFlutterResult:result]];
}

// MARK: - MBA Methods - RSSI

- (void)readRSSIForDevice:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter readRSSIForDevice:call.arguments[ARGUMENT_KEY_DEVICE_IDENTIFIER]
                  transactionId:[ArgumentHandler stringOrNil:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]]
                        resolve:[self resolveForReadRSSIForDevice:result]
                         reject:[self rejectForFlutterResult:result]];
}

// MARK: - MBA Methods - Cancel transaction

- (void)cancelTransaction:(FlutterMethodCall *)call result:(FlutterResult)result {
    [_adapter cancelTransaction:call.arguments[ARGUMENT_KEY_TRANSACTION_ID]];
    result(nil);
}

// MARK: - MBA Methods - BleClientManagerDelegate implementation

- (void)dispatchEvent:(NSString * _Nonnull)name value:(id _Nonnull)value {
    if ([BleEvent.restoreStateEvent isEqualToString:name]) {
        [self.restoreStateStreamHandler onRestoreEvent:value];
    } else if ([BleEvent.stateChangeEvent isEqualToString:name]) {
        [self.adapterStateStreamHandler onNewAdapterState:value];
    } else if ([BleEvent.scanEvent isEqualToString:name]) {
        [self.scanningStreamHandler onScanResult:(NSArray*)value];
    } else if ([BleEvent.connectingEvent isEqualToString:name]) {
        [self.connectionStateStreamHandler onConnectingEvent:(NSString *)value];
    } else if ([BleEvent.connectedEvent isEqualToString:name]) {
        [self.connectionStateStreamHandler onConnectedEvent:(NSString *)value];
    } else if ([BleEvent.disconnectionEvent isEqualToString:name]) {
        [self.connectionStateStreamHandler onDisconnectedEvent:(NSArray *)value];
    } else if ([BleEvent.readEvent isEqualToString:name]) {
        [self.monitorCharacteristicStreamHandler onReadEvent:value];
    }
}

// MARK: - Utility methods

- (Resolve)resolveForReadWriteDescriptor:(FlutterResult)result {
    return ^(NSDictionary *descriptorResponse) {
        result([DescriptorResponseConverter jsonStringFromDescriptorResponse:descriptorResponse]);
    };
}

- (Resolve)resolveForCancelConnection:(FlutterResult)result {
    return ^(id response) {
        result(nil);
    };
}

- (Resolve)resolveForServicesForDevice:(FlutterResult)result {
    return ^(NSArray *servicesArray) {
        result([ServiceResponseConverter jsonStringFromServicesResponse:servicesArray]);
    };
}

- (Resolve)resolveForCharacteristicsForService:(FlutterResult)result {
    return ^(NSArray *characteristicsArray) {
        result([CharacteristicResponseConverter jsonStringFromCharacteristicsResponse:characteristicsArray]);
    };
}

- (Resolve)resolveForCharacteristics:(FlutterResult)result {
    return ^(NSArray* characteristicsArray) {
        result([CharacteristicResponseConverter jsonStringWithServiceFromCharacteristicsResponse:characteristicsArray]);
    };
}

- (Resolve)resolveForDescriptors:(FlutterResult)result {
    return ^(NSArray *descriptorsArray) {
        result([DescriptorResponseConverter jsonStringFromMultipleDescriptorsResponse:descriptorsArray]);
    };
}

- (Resolve)resolveForReadWriteCharacteristic:(FlutterResult)result
                               transactionId:(NSString *)transactionId {
    return ^(NSDictionary *characteristicResponse) {
        result([CharacteristicResponseConverter jsonStringFromCharacteristicResponse:characteristicResponse
                                                                       transactionId:transactionId]);
    };
}

- (Resolve)resolveForMonitorCharacteristic:(FlutterResult)result {
    return ^(id response) {
        result(nil);
    };
}

- (Resolve)resolveForKnownConnectedDevices:(FlutterResult)result {
    return ^(NSArray *peripheralsResponse) {
        result([PeripheralResponseConverter jsonStringFromPeripheralResponse:peripheralsResponse]);
    };
}

- (Resolve)resolveForRequestMTUForDevice:(FlutterResult)result {
    return ^(NSDictionary *peripheral) {
        result([peripheral objectForKey:@"mtu"]);
    };
}

- (Resolve)resolveForReadRSSIForDevice:(FlutterResult)result {
    return ^(NSDictionary *peripheral) {
        result([peripheral objectForKey:@"rssi"]);
    };
}

- (Reject)rejectForFlutterResult:(FlutterResult)result {
    return ^(NSString *code, NSString *message, NSError *error) {
        result([FlutterErrorFactory flutterErrorFromJSONString:message]);
    };
}

- (NSString *)base64encodedStringFromBytes:(FlutterStandardTypedData *)bytes {
    return [bytes.data base64EncodedStringWithOptions:0];
}

@end
