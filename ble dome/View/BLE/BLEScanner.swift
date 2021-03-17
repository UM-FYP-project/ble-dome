//
//  BLEconnectsheet.swift
//  ble dome
//
//  Created by UM on 28/01/2021.
//

import SwiftUI

struct BLEScanner: View {
    @EnvironmentObject var ble:BLE
    var body: some View {
        NavigationView {
            BLEScannerList()
                .environmentObject(ble)
                .navigationTitle("Device Scanner")
                .navigationBarItems(
                    trailing:
                        Button(action: {scanButton()}) {
                            if !ble.isScanned{
                                Text("Scan")
                                    .font(.title2)
                                    .frame(width: 150,  alignment: .trailing)
                            }
                            else{
                                Text("Stop Scanning")
                                    .font(.title2)
                                    .frame(width: 150,  alignment: .trailing)
                            }
                        })
        }
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                if ble.isBluetoothON{
                    ble.scan_devices()
                }
            }
        })
    }
    
    func scanButton(){
        if ble.isScanned{
            ble.stopscan_device()
        }
        else{
            ble.scan_devices()
        }
    }
}

struct BLEScannerList: View {
    @EnvironmentObject var ble:BLE
    var body: some View {
        if ble.isBluetoothON && ble.wasScanned{
            List(ble.peripherals) {peripheral in
                peripheralrow(peripheral:peripheral)
            }
        }
        else if !ble.isBluetoothON{
            Spacer()
            Text("Please Turn On Bluetooth")
                .font(.largeTitle)
            Spacer()
        }
        else if !ble.wasScanned{
            Spacer()
            Text("Please Tap Scan Button")
                .font(.largeTitle)
            Spacer()
        }
    }
}

struct peripheralrow: View {
    var peripheral : Peripheral
    @EnvironmentObject var ble:BLE
    @State var connectButton_str:String = "Tap to Connect"
    @State var longpressed:Bool = false
    var body: some View {
        NavigationLink(
            destination:
                DetailTabView(peripheral: peripheral)
                .environmentObject(ble)
                .disabled(peripheral.State != 2)
                .navigationBarItems(
                    trailing:
                        Button(action: {connectButton(peripheral_name: peripheral.name, ble: ble)}) {
                            BLEConnect_button_text(peripheral_name: peripheral.name)
                                .frame(width: 180, height: 30, alignment: .trailing)
                        }
                ),
            isActive: $longpressed,
            label: {
                HStack{
                    VStack(alignment: .leading){
                        Text(peripheral.name)
                            .bold()
                            .font(.title2)
                        Text("Rssi: \(peripheral.rssi)")
                        Text("Serive: \(peripheral.Service)")
                    }
                    Spacer()
                    BLEConnect_button_text(peripheral_name: peripheral.name)
                }
            })
        .onAppear(perform: {
            longpressed = false
        })
            .onTapGesture {connectButton(peripheral_name: peripheral.name, ble: ble)}
        .onLongPressGesture(minimumDuration: 1.0) {
            if peripheral.State == 0{
                print("Connect to \(peripheral.name)")
                ble.connect(peripheral: peripheral.Peripheral)
            }
            longpressed = true
        }
    }
    
    func connectButton(peripheral_name:String, ble:BLE){
        if peripheral_name != ""{
            if let index = ble.peripherals.firstIndex(where: {$0.name == peripheral_name}){
                let peripheral = ble.peripherals[index]
                if peripheral.State == 0{
                    ble.connect(peripheral: peripheral.Peripheral)
                }
                else if peripheral.State == 1{
                    ble.cancelConnection(peripheral: peripheral.Peripheral)
                }
                else if peripheral.State == 2{
                    ble.disconnect(peripheral: peripheral.Peripheral)
                }
            }
        }
    }
    
}

struct BLEConnect_button_text: View {
    @EnvironmentObject var ble:BLE
    var peripheral_name : String = ""
    var body: some View {
        if peripheral_name != ""{
            if let index = ble.peripherals.firstIndex(where: {$0.name == peripheral_name}){
                let peripheral = ble.peripherals[index]
                if peripheral.State == 0{
                    Text("Tap to connect")
                        .font(.title2)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.trailing)
                }
                else if peripheral.State == 1{
                    Text("Connecting")
                        .font(.title2)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.trailing)
                }
                else if peripheral.State == 2{
                    Text("Tap to Disconnect")
                        .font(.title2)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.trailing)
                }
                else {
                    Text("Disconnecting")
                        .font(.title2)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}


struct BLEScanner_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BLEScanner().environmentObject(BLE())
            BLEScannerList().environmentObject(BLE())
        }
    }
}
