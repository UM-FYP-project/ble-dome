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
}

class BLE: NSObject, ObservableObject, CBCentralManagerDelegate{
    var centralManager:CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var connectedPeripheral_record: String?
    @Published var isBluetoothON : Bool = false
    @Published var peripherals = [Peripheral]()
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
            isBluetoothON = true
            print("BLE powered on")
        }
        else {
            isBluetoothON = false
        }
        
    }
    //Discover device
    func scan_devices(){
        print("Scanning")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    // Stop discoving device
    func stopscan_device() {
        self.centralManager.stopScan()
        print("Scan Stopped")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName : String!
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
           peripheralName = name
        }
        else{
            peripheralName = "Unkown"
        }
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
        print(newPeripheral)
        peripherals.append(newPeripheral)
    }
    
}

