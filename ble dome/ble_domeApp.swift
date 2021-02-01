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
    let rssi : Int
    let Peripherasl : CBPeripheral
    let SerivceID : String
}

class BLE: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    var centralManager:CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var connectedPeripheral_record: String?
    @Published var isBluetoothON : Bool = false
    @Published var isBluetoothOFF : Bool = false
    @Published var isunauthorized : Bool = false
    @Published var bleconnection : Int = 0
    @Published var peripherals = [Peripheral]()
    //@Published var peripherals = [CBPeripheral]()
    @Published var peripheral_count : Int = 0
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        print("BLE init")
    }
    // Bluetooth State
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            isBluetoothOFF = false
            isBluetoothON = true
            print("BLE powered on")
            scan_devices()
        }
        else if central.state == .unauthorized{
            isunauthorized = true
            print("BLE is unauthorized")
        }
        else {
            isBluetoothON = false
            isBluetoothOFF = true
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
        print("Scan Stopped")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName : String!
        var discoveredPeripheral : CBPeripheral!
        var peripheraluuid : String!
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
           peripheralName = name
        }
        else{
            peripheralName = "Unkown"
        }
        if let uuid = advertisementData[CBAdvertisementDataServiceDataKey] as? String {
            peripheraluuid = uuid
        }
        else{
            peripheraluuid = "N/A"
        }
        discoveredPeripheral = peripheral
        if !(peripheralName == "Unkown"){
            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, Peripherasl: discoveredPeripheral, SerivceID: peripheraluuid)
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
        bleconnection = 3
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("Device Connected")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        bleconnection = 2
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil{
            print("*****************************")
            print("Failed to  Connect")
            bleconnection = 0
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("*****************************")
            print("Failed to  Disconnect")
            bleconnection = 1
            return
        }
        else{
            print("*****************************")
            print("Device Disconnected")
            bleconnection = 0
        }
    }
}
