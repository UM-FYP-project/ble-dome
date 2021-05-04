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
//            PeripheralList(geometry: geometry)
//                .environmentObject(ble)
            PeripheralList
            Divider()
                .frame(width: geometry.size.width - 60)
            Button(action: {
                self.Enable = false
                ble.stopscan_device()
            }) {
                Text("Close")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .frame(width: geometry.size.width - 60, height: 40)
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
    
    var PeripheralList: some View {
        VStack{
            if !ble.peripherals.isEmpty {
                List{
                    ForEach(0..<ble.peripherals.count, id: \.self) { index in
                        let peripheral = ble.peripherals[index]
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
                        .listRowBackground(RoundedRectangle(cornerRadius: 0)
                                            .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 1))
                    }
                }
                .colorMultiply(Color.white.opacity(0.8))
                .shadow(radius: 1)
            }
        }
    }
}

struct BLEConnect_button: View {
    @EnvironmentObject var ble:BLE
    var name : String
    var body : some View {
        Button(action: {
            if name != ""{
                if let index = ble.peripherals.firstIndex(where: {$0.name == name}){
                    let peripheral = ble.peripherals[index]
                    if peripheral.State == 0 && ble.peripherals.filter({$0.State != 0}).count < 1{
                        ble.connect(peripheral: peripheral.Peripheral)
                    }
                    else if peripheral.State == 1{
                        ble.cancelConnection(peripheral: peripheral.Peripheral)
                    }
                    else if peripheral.State == 2{
                        ble.disconnect(peripheral: peripheral.Peripheral)
                        ble.scan_devices()
                    }
                }
            }
        }) {
            if name != "" {
                if let index = ble.peripherals.firstIndex(where: {$0.name == name}){
                    let peripheral = ble.peripherals[index]
                    if peripheral.State == 0{
                        Text("Connect")
                            .font(.title2)
                            .foregroundColor(ble.peripherals.filter({$0.State != 0}).count < 1 ? .blue : Color(UIColor.lightGray))
                            .multilineTextAlignment(.trailing)
                    }
                    else if peripheral.State == 1{
                        Text("Connecting")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.trailing)
                    }
                    else if peripheral.State == 2{
                        Text("Disconnect")
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

//struct BLEScanner_Alert_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader{ geometry in
//            BLEScanner_Alert(Enable: .constant(true), geometry: geometry).environmentObject(BLE())
//        }
//    }
//}
