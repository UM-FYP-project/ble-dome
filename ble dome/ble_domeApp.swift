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
    var id : Int
    let name : String
    var rssi : Int
    let Service : String
    let Peripheral : CBPeripheral
    var State : Int
}

struct Peripheral_characteristic: Identifiable{
    let id : Int
    let name : String
    let Services_UUID : CBUUID
    let Characteristic_UUID : CBUUID
    let properties : String
    var isNotify : Bool
    var iswritable : Bool
    var value = [UInt8]()
    var valueStr : String
    var WritevalueStr : String
    var Characteristic: CBCharacteristic
}

struct Peripheral_Service: Identifiable{
    let id : Int
    let name : String
    let Services_UUID : CBUUID
    var Services : CBService
}


class BLE: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    var centralManager:CBCentralManager!
    @Published var isInit : Bool = false
    @Published var isBluetoothON : Bool = false
//    @Published var isConnected : Bool = false
    @Published var peripherals = [Peripheral]()
    @Published var Peripheral_characteristics = [Peripheral_characteristic]()
    @Published var Peripheral_Services = [Peripheral_Service]()
    @Published var ValueUpated_2A68 : Bool = false
//    @Published var isScanned : Bool = false
//    @Published var wasScanned : Bool = false
//    @Published var Connected_Peripheral :Peripheral?
    
    //Bluetooth init
    func initBLE(){
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        print("BLE init")
        isInit = true
//        wasScanned = false
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
//            isScanned = false
//            wasScanned = false
            isInit = false
        }
        
    }
    //Discover device
    func scan_devices(){
//        if Connected_Peripheral != nil {
//            if Connected_Peripheral!.State == 2 {
//                peripherals.removeAll()
//                peripherals.append(Connected_Peripheral!)
//                peripherals[0].id = 0
//            }
//            else {
//                Connected_Peripheral = nil
//                peripherals.removeAll()
//            }
//        }
        if let index = peripherals.firstIndex(where: {$0.State != 0}){
            let peripheral : Peripheral = peripherals[index]
            peripherals.removeAll()
            peripherals.append(peripheral)
            peripherals[0].id = 0
        }
        else{
            peripherals.removeAll()
        }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
//        isScanned = true
//        wasScanned = true
        print("Scanning")
    }
    
    // Stop discoving device
    func stopscan_device() {
        self.centralManager.stopScan()
//        isScanned = false
        print("Scan Stopped")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var discoveredPeripheral : CBPeripheral!
        discoveredPeripheral = peripheral
        if let name = peripheral.name{
            if peripherals.filter({$0.name == name}).count < 1 {
                guard let UUID =  advertisementData["kCBAdvDataServiceUUIDs"] as? Array<Any> else {
                    return
                }
                let newPeripheral = Peripheral(id: peripherals.count, name: name, rssi: RSSI.intValue, Service: "\(UUID)", Peripheral: discoveredPeripheral, State: 0)
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
        print("Connect to Peripheral:\(peripheral.name!)")
        centralManager.connect(peripheral, options: nil)
        stopscan_device()
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 1
//            peripherals[index].isConnected = false
//            isConnected = false
        }
     }
    
    func disconnect(peripheral: CBPeripheral){
        print("\(peripheral.name!) Disconnect")
        centralManager.cancelPeripheralConnection(peripheral)
//        isConnected = false
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 3
//            peripherals[index].isConnected = false
        }
    }
    
    func cancelConnection(peripheral: CBPeripheral){
        print("Cancel Connect to Peripheral:\(peripheral.name!)")
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\(peripheral.name!) Connected")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
//        isConnected = true
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 2
//            peripherals[index].isConnected = true
//            Connected_Peripheral = peripherals[index]
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil{
            print("\(peripheral.name!) Failed to Connect")
//            isConnected = false
            if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
                peripherals[index].State = 0
//                peripherals[index].isConnected = false
            }
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\(peripheral.name!) Device Disconnected")
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 0
//            Connected_Peripheral!.State = 0
//            peripherals[index].isConnected = false
//            isConnected = false
        }
        Peripheral_characteristics.removeAll()
        Peripheral_Services.removeAll()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("********\(peripheral.name!) Discover Services*******")
        if error != nil{
            print("\(peripheral.name!): Error discovering services \(error!.localizedDescription)")
        }
        guard let services = peripheral.services else {
            return
        }
        print("\(peripheral.name!) Found \(services.count) Serivce")
        for service in services {
            print("Discovered Services: \(service.uuid) | \(service.description)")
            let newSerivce = Peripheral_Service(id: Peripheral_Services.count, name: peripheral.name!, Services_UUID: service.uuid, Services: service)
            Peripheral_Services.append(newSerivce)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("********\(peripheral.name!) Discover Characteristics********")
        if error != nil{
            print("\(peripheral.name!) : \(service.uuid): Error discovering Characteristics \(error!.localizedDescription)")
        }
        guard let characteristics = service.characteristics else {
            return
        }
       print("\(peripheral.name!) Found \(characteristics.count) characteristics in \(service.uuid)")
        for characteristic in characteristics {
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            let properties = Characteristic_Properties(properties: characteristic.properties)
            print("\(peripheral.name!) : \(service.uuid): \(characteristic.uuid) | \(String(describing: characteristic.value)) | \(properties.0) | isWritable: \(properties.1) | isNotifying: \(characteristic.isNotifying)")
            if let value = characteristic.value{
                if let name = peripheral.name{
                    let byteValue = [UInt8](value)
                    let newCharacteristic = Peripheral_characteristic(id: Peripheral_characteristics.count, name: name, Services_UUID: service.uuid, Characteristic_UUID: characteristic.uuid, properties: properties.0, isNotify: characteristic.isNotifying, iswritable: properties.1, value: byteValue, valueStr: value.hexEncodedString(), WritevalueStr: "", Characteristic: characteristic)
                    //print(newCharacteristic)
                    Peripheral_characteristics.append(newCharacteristic)
                }
            }
            else{
                if let name = peripheral.name{
                    let newCharacteristic = Peripheral_characteristic(id: Peripheral_characteristics.count, name: name, Services_UUID: service.uuid, Characteristic_UUID: characteristic.uuid, properties: properties.0, isNotify: characteristic.isNotifying, iswritable: properties.1, value: [], valueStr: "", WritevalueStr: "", Characteristic: characteristic)
                    //print(newCharacteristic)
                    Peripheral_characteristics.append(newCharacteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("********\(peripheral.name!) Update Notification State********")
        if error != nil{
            print("\(peripheral.name!) : \(characteristic.service.uuid) : \(characteristic.uuid) : \(error!.localizedDescription) ")
        }
        if let index = Peripheral_characteristics.firstIndex(where: {$0.Services_UUID == characteristic.service.uuid && $0.Characteristic_UUID == characteristic.uuid}){
            Peripheral_characteristics[index].isNotify = characteristic.isNotifying
        }
        print("\(peripheral.name!): \(characteristic.service.uuid) : \(characteristic.uuid) | isNotifying: \(characteristic.isNotifying)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("********\(peripheral.name!) Update Value********")
        if error != nil{
            print("\(peripheral.name!) : \(characteristic.service.uuid) : \(characteristic.uuid): \(error!.localizedDescription) ")
        }
        guard let value = characteristic.value else {
            return
        }
        let byteValue = [UInt8](value)
        if let index = Peripheral_characteristics.firstIndex(where: {$0.Services_UUID == characteristic.service.uuid && $0.Characteristic_UUID == characteristic.uuid}){
            if characteristic.uuid == CBUUID(string: "726F"){
                ValueUpated_2A68 = true
            }
            Peripheral_characteristics[index].value = byteValue
            Peripheral_characteristics[index].valueStr = value.hexEncodedString()
        }
        print("\(peripheral.name!) : \(characteristic.service.uuid) : \(characteristic.uuid) | \(value.hexEncodedString())")
//        ValueUpated_2A68 = false
//        print("ValueUpated_2A68: \(ValueUpated_2A68)")
    }
    
    func readValue(characteristic: CBCharacteristic, peripheral: CBPeripheral){
        peripheral.readValue(for:characteristic)
        print("********\(peripheral.name!) Read Value********")
        guard let value = characteristic.value else {
            return
        }
        print("\(peripheral.name!) : \(characteristic.service.uuid) : \(characteristic.uuid) | \(value.hexEncodedString())")
    }
    
    func writeValue(value: Data, characteristic: CBCharacteristic, peripheral: CBPeripheral){
        peripheral.writeValue(value, for: characteristic, type: .withResponse)
        if let index = Peripheral_characteristics.firstIndex(where: {$0.name == peripheral.name! && $0.Services_UUID == characteristic.service.uuid && $0.Characteristic_UUID == characteristic.uuid}){
            Peripheral_characteristics[index].WritevalueStr = value.hexEncodedString()
        }
        print("\(peripheral.name!) : Serivce: \(characteristic.service.uuid) : Characteristic :\(characteristic.uuid) wrote Value: \(value.hexEncodedString()) ")
    }
    
    func writeValue_withoutResponse(value: Data, characteristic: CBCharacteristic, peripheral: CBPeripheral){
        peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        if let index = Peripheral_characteristics.firstIndex(where: {$0.name == peripheral.name! && $0.Services_UUID == characteristic.service.uuid && $0.Characteristic_UUID == characteristic.uuid}){
            Peripheral_characteristics[index].WritevalueStr = value.hexEncodedString()
        }
        print("\(peripheral.name!) : Serivce: \(characteristic.service.uuid) : Characteristic :\(characteristic.uuid) wrote_withoutResponse Value: \(value.hexEncodedString()) ")
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil{
            print("\(peripheral.name!) : \(characteristic.service.uuid) : \(characteristic.uuid): \(error!.localizedDescription) ")
        }

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
        return map { String(format: "%02hhx", $0) }
            .joined(separator: ",")
            .uppercased()
    }
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

