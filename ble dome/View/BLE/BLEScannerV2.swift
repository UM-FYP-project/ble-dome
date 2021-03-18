//
//  BLEScannerV2.swift
//  ble dome
//
//  Created by UM on 17/03/2021.
//

import SwiftUI

struct BLEScanner_Alert: View {
    @EnvironmentObject var ble:BLE
    @Binding var Enable : Bool
    var geometry : GeometryProxy
    var body: some View {
        VStack(alignment:.center){
            Text("Scanner")
                .bold()
                .font(.title)
            Text("Scan and Connect Deivce")
            PeripheralList(geometry: geometry)
                .environmentObject(ble)
            Divider()
                .padding()
            Button(action: {
                self.Enable = false
                ble.stopscan_device()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.blue)
                
            }
            .frame(width: geometry.size.width - 60)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 1))
        .frame(maxWidth: geometry.size.width - 60, maxHeight: geometry.size.height - 300)
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        .onAppear(perform: {
            if ble.isBluetoothON{
                ble.scan_devices()
            }
        })
    }
}

struct PeripheralList: View {
    @EnvironmentObject var ble:BLE
    var geometry : GeometryProxy
    var body: some View {
        List(ble.peripherals) {peripheral in
            HStack{
                VStack(alignment: .leading){
                    Text(peripheral.name)
                        .bold()
                    Text("Rssi: \(peripheral.rssi)")
                }
                Spacer()
                BLEConnect_button(name: peripheral.name)
                    .frame(alignment: .trailing)
            }
        }
    }
}

struct BLEConnect_button: View {
    @EnvironmentObject var ble:BLE
    var name : String
    var body: some View {
        Button(action: {
            if name != ""{
                if let index = ble.peripherals.firstIndex(where: {$0.name == name}){
                    let peripheral = ble.peripherals[index]
                    if peripheral.State == 0 && ble.Connected_Peripheral == nil{
                        ble.connect(peripheral: peripheral.Peripheral)
                    }
                    else if peripheral.State == 1 && ble.Connected_Peripheral == nil{
                        ble.cancelConnection(peripheral: peripheral.Peripheral)
                    }
                    else if peripheral.State == 2{
                        ble.disconnect(peripheral: peripheral.Peripheral)
                    }
                }
            }
        }) {
            if name != "" {
                if let index = ble.peripherals.firstIndex(where: {$0.name == name}){
                    let peripheral = ble.peripherals[index]
                    if peripheral.State == 0{
                        Text("Tap to connect")
                            .font(.title2)
                            .foregroundColor(ble.Connected_Peripheral == nil ? .blue : Color(UIColor.lightGray))
                            .multilineTextAlignment(.trailing)
                    }
                    else if peripheral.State == 1{
                        Text("Connecting")
                            .font(.title2)
                            .foregroundColor(ble.Connected_Peripheral == nil ? .blue : Color(UIColor.lightGray))
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
}

struct BLEScanner_Alert_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            BLEScanner_Alert(Enable: .constant(true), geometry: geometry).environmentObject(BLE())
        }
    }
}
