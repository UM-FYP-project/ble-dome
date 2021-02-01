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
            //BLEScanner()
            ContentView()
        }
    }
    
}

struct Peripheral: Identifiable {
    let id : Int
    let name : String
    let rssi : Int
    let Peripherasl : CBPeripheral
    //let SerivceID : String
}

class BLE: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    private var centralManager:CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var connectedPeripheral_record: String?
    //var Service_UUID = CBUUID(string: kBLEService_UUID)
    @Published var isBluetoothON : Bool = false
    @Published var isBluetoothOFF : Bool = false
    @Published var isDisconnected : Bool = true
    @Published var bleconnection : Int = 0
    @Published var peripherals = [Peripheral]()
    @Published var peripheral_count : Int = 0
    
     override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        print("BLE init")
        isDisconnected = true
        bleconnection = 0
    }
    // Bluetooth State
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            isBluetoothOFF = false
            isBluetoothON = true
            print("BLE powered on")
            scan_devices()
        }
        else {
            isBluetoothON = false
            isBluetoothOFF = true
            isDisconnected = true
            bleconnection = 0
        }
        
    }
    //Discover device
    func scan_devices(){
        peripherals.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Scanning")
    }
    
    // Stop discoving device
    func stopscan_device() {
        self.centralManager.stopScan()
        print("*****************************")
        print("Scan Stopped")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName : String!
        var discoveredPeripheral : CBPeripheral!
        //var peripheraluuid : String!
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
           peripheralName = name
        }
        else{
            peripheralName = "Unkown"
        }
        discoveredPeripheral = peripheral
        if !(peripheralName == "Unkown"){
            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, Peripherasl:
                                            discoveredPeripheral)
            print(newPeripheral)
            peripherals.append(newPeripheral)
        }
    }
    
    func connect(peripheral: CBPeripheral) {
        print("*****************************")
        print("Connect to Peripheral:\(peripheral)")
        centralManager.connect(peripheral, options: nil)
        bleconnection = 1
        centralManager.stopScan()
     }
    
    func disconnect(peripheral: CBPeripheral){
        print("*****************************")
        print("\(peripheral) Disconnect")
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("Device Connected")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        stopscan_device()
        bleconnection = 2
        isDisconnected = false
        centralManager.stopScan()
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil{
            print("*****************************")
            print("Failed to  Connect")
            bleconnection = 0
            isDisconnected = true
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("*****************************")
            print("Failed to  Disconnect")
            bleconnection = 2
            isDisconnected = false
            return
        }
        else{
            print("*****************************")
            print("Device Disconnected")
            bleconnection = 0
            isDisconnected = true
        }
    }
    
    // Call after connecting to peripheral
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    // Call after discovering services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil{
            print("Error Service \(error!.localizedDescription)! ")
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil{
            print("Error Service \(error!.localizedDescription)! ")
        }
        guard let characteristics = service.characteristics else {
               return
        }
        for characteristic in characteristics {
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil{
            print("Error debugDescription \(error.debugDescription)!")
        }
        if characteristic.descriptors != nil{
            for descript in characteristic.descriptors!{
                let mDescript = descript as CBDescriptor?
                print("DidDiscoverDescriptorCharacterisitic \(mDescript?.description ?? "")")
            }
            
        }
    }
}
