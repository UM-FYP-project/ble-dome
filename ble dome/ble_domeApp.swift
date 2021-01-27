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

class BLE: NSObject, ObservableObject, CBCentralManagerDelegate{
    var centralManager:CBCentralManager!
    @Published var  isBluetoothON : Bool = false
    //initialize BLE
//    func initi_BLE(){
//        print("initiBLE")
//        centralManager  = CBCentralManager.init(delegate: self, queue: nil)
//        centralManager.delegate = self
//    }
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
    
}

