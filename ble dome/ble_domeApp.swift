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

struct Peripheral_characteristics: Identifiable{
    let id : Int
    let name : String
    let Services_UUID : CBUUID
    let Characteristic_UUID : CBUUID
    var value : UInt8?
}

class BLE: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    var centralManager:CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var connectedPeripheral_record: String?
    @Published var isInit : Bool = false
    @Published var isBluetoothON : Bool = false
    @Published var peripherals = [Peripheral]()
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
//                if let UUID = advertisementData["kCBAdvDataServiceUUIDs"] as? Array<Any> {
//                    let newPeripheral = Peripheral(id: peripherals.count, name: name, rssi: RSSI.intValue, Serive: "\(UUID)", Peripherasl: discoveredPeripheral, State: 0)
//                    print("\(name) \(UUID) \(RSSI.intValue)")
//                    peripherals.append(newPeripheral)
//                }
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
        print("Connect to Peripheral:\(peripheral)")
        centralManager.connect(peripheral, options: nil)
        stopscan_device()
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 1
        }
     }
    
    func disconnect(peripheral: CBPeripheral){
        print("*****************************")
        print("\(peripheral) Disconnect")
        centralManager.cancelPeripheralConnection(peripheral)
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 3
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("\(peripheral) Connected")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
            peripherals[index].State = 2
        }
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil{
            print("*****************************")
            print("\(peripheral) Failed to Connect")
            if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
                peripherals[index].State = 0
            }
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("*****************************")
            print("\(peripheral) Failed to  Disconnect")
            if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
                peripherals[index].State = 2
            }
            return
        }
        else{
            print("*****************************")
            print("\(peripheral) Device Disconnected")
            if let index = peripherals.firstIndex(where: {$0.name == peripheral.name}){
                peripherals[index].State = 0
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("********\(peripheral.name!) Discover Services*******")
        if error != nil{
            print("Error discovering services \(error!.localizedDescription)")
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            print("Discovered Services: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("********\(peripheral.name!) Discover Characteristics********")
        if error != nil{
            print("Error discovering Characteristics \(error!.localizedDescription)")
        }
        guard let characteristics = service.characteristics else {
            return
        }
        print("Found \(characteristics.count) characteristics")
        for characteristic in characteristics {
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            print(characteristic)
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
//        if error != nil{
//            print("\(error.debugDescription) of \(peripheral.name)")
//        }
//        guard let descriptors = characteristic.descriptors else {
//            return
//
//        }
//        if let userDescriptionDescriptor = descriptors.first(where: {
//                return $0.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString
//            }) {
//                // Read user description for characteristic
//                peripheral.readValue(for: userDescriptionDescriptor)
//            }
//    }
//
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("********\(peripheral.name!) Update Notification State********")
        if error != nil{
            print("\(error!.localizedDescription) ")
        }
        print("\(characteristic.uuid) : \(characteristic.isNotifying)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("********\(peripheral.name!) Update Value********")
        if error != nil{
            print("\(error!.localizedDescription) ")
        }
        print("\(characteristic.uuid) : \(characteristic.value)")
    }
    
}
