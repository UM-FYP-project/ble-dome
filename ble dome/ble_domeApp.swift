//
//  ble_domeApp.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI
import CoreBluetooth

@main
struct ble_domeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
}

struct Peripheral: Identifiable {
    let id : Int
    let name : String
    var rssi : Int
    let Service : String
    let Peripherasl : CBPeripheral
    var State : Int
}

struct Peripheral_characteristic: Identifiable{
    let id : Int
    let name : String
    let Services_UUID : CBUUID
    let Characteristic_UUID : CBUUID?
    let properties : String
    var iswritable : Bool
    var value = [UInt8]()
    var valueStr : String
}

class BLE: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    var centralManager:CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var connectedPeripheral_record: String?
    @Published var isInit : Bool = false
    @Published var isBluetoothON : Bool = false
    @Published var peripherals = [Peripheral]()
    @Published var Peripheral_characteristics = [Peripheral_characteristic]()
    @Published var Peripheral_Services = [CBUUID]()
    @Published var isScanned : Bool = false
    @Published var wasScanned : Bool = false
    
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//        centralManager.delegate = self
//        print("BLE init")
//    }
    
    //Bluetooth init
    func initBLE(){
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        print("BLE init")
        isInit = true
        wasScanned = false
        peripherals.removeAll()
    }
    
    // Bluetooth State
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            isBluetoothON = true
            print("BLE powered on")
        }
        else {
            isBluetoothON = false
            isScanned = false
            wasScanned = false
            isInit = false
        }
        
    }
    //Discover device
    func scan_devices(){
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        isScanned = true
        wasScanned = true
        print("Scanning")
    }
    
    // Stop discoving device
    func stopscan_device() {
        self.centralManager.stopScan()
        isScanned = false
        print("Scan Stopped")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var discoveredPeripheral : CBPeripheral!
        //var peripheraluuid : String!
        discoveredPeripheral = peripheral
        if let name = peripheral.name{
            if peripherals.filter({$0.name == name}).count < 1 {
                guard let UUID =  advertisementData["kCBAdvDataServiceUUIDs"] as? Array<Any> else {
                    return
                }
                let newPeripheral = Peripheral(id: peripherals.count, name: name, rssi: RSSI.intValue, Service: "\(UUID)", Peripherasl: discoveredPeripheral, State: 0)
                print("\(name) \(UUID) \(RSSI.intValue)")
                peripherals.append(newPeripheral)
            }
            else {
                if let index = peripherals.firstIndex(where: {$0.name == name}){
                    peripherals[index].rssi = RSSI.intValue
                }
            }
        }
    }
    
    func connect(peripheral: CBPeripheral) {
        print("*****************************")
        print("Connect to Peripheral:\(peripheral.name!)")
        centralManager.connect(peripheral, options: nil)
        stopscan_device()
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 1
        }
     }
    
    func disconnect(peripheral: CBPeripheral){
        print("*****************************")
        print("\(peripheral.name!) Disconnect")
        centralManager.cancelPeripheralConnection(peripheral)
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 3
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("\(peripheral.name!) Connected")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 2
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil{
            print("*****************************")
            print("\(peripheral.name!) Failed to Connect")
            if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
                peripherals[index].State = 0
            }
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("*****************************")
        print("\(peripheral.name!) Device Disconnected")
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 0
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("********\(peripheral.name!) Discover Services*******")
        if error != nil{
            print("\(peripheral.name!): Error discovering services \(error!.localizedDescription)")
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            print("Discovered Services: \(service.uuid)")
            Peripheral_Services.append(service.uuid)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("********\(peripheral.name!) Discover Characteristics********")
        if error != nil{
            print("\(service.uuid): Error discovering Characteristics \(error!.localizedDescription)")
        }
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            let properties = Characteristic_Properties(properties: characteristic.properties)
            print("\(peripheral.name!) : \(service.uuid): \(characteristic.uuid) | \(characteristic.value) | \(properties.0) | isWritable: \(properties.1) | isNotifying: \(characteristic.isNotifying)")
//            guard let value = characteristic.value else {
//                return
//            }
            if let value = characteristic.value{
                if let name = peripheral.name{
                    let byteValue = [UInt8](value)
                    let newCharacteristic = Peripheral_characteristic(id: Peripheral_characteristics.count, name: name, Services_UUID: service.uuid, Characteristic_UUID: characteristic.uuid, properties: properties.0, iswritable: properties.1, value: byteValue, valueStr: value.hexEncodedString())
                    print(newCharacteristic)
                    Peripheral_characteristics.append(newCharacteristic)
                }
            }
            else{
                if let name = peripheral.name{
                    let newCharacteristic = Peripheral_characteristic(id: Peripheral_characteristics.count, name: name, Services_UUID: service.uuid, Characteristic_UUID: characteristic.uuid, properties: properties.0, iswritable: properties.1, value: [], valueStr: "nil")
                    print(newCharacteristic)
                    Peripheral_characteristics.append(newCharacteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("********\(peripheral.name!) Update Notification State********")
        if error != nil{
            print("\(characteristic.uuid) : \(error!.localizedDescription) ")
        }
        print("\(peripheral.name!): \(characteristic.uuid) | isNotifying: \(characteristic.isNotifying)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("********\(peripheral.name!) Update Value********")
        if error != nil{
            print("\(characteristic.uuid): \(error!.localizedDescription) ")
        }
        guard let value = characteristic.value else {
            return
        }
        //let byteValue = [UInt8](value)
        //print("\(peripheral.name!) : \(characteristic.uuid) | \(value.hexEncodedString())")
    }
    
    func Characteristic_Properties (properties: CBCharacteristicProperties) -> (String, Bool) {
        var Properties_str = [String]()
        let properties_digis:UInt8 = UInt8(properties.rawValue) % 0x10
        let properties_tens:UInt8 = UInt8(properties.rawValue) / 0x10
        var iswritable = false
        switch properties_digis{
        case 0x01:
            Properties_str.append("Broadcast")
        case 0x02:
            Properties_str.append("Read")
        case 0x04:
            Properties_str.append("WriteWithoutResponse")
            iswritable = true
        case 0x08:
            Properties_str.append("Write")
            iswritable = true
        default:
            break
        }
        switch properties_tens{
        case 0x01:
            Properties_str.append("Notify")
        case 0x02:
            Properties_str.append("Indicate")
        case 0x04:
            Properties_str.append("AuthenticatedSignedWrites")
        case 0x08:
            Properties_str.append("ExtendedProperties")
        default:
            break
        }
        let joined = Properties_str.joined(separator: ", ")
        return (joined, iswritable)
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
