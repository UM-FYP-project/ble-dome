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
            VStack{
                Text("Scanner")
                    .bold()
                    .font(.title2)
                Text("Scan and Connect Device")
            }
            .padding()
            .clipped()
            PeripheralList
            Divider()
            Button(action: {
                self.Enable = false
                ble.stopscan_device()
            }) {
                Text("Close")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
//            .padding()
            .frame(width: geometry.size.width - 60, height: 50)
        }
        .background(RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(UIColor.systemGray6)).shadow(radius: 1))
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
                ScrollView{
                    ForEach(0..<ble.peripherals.count, id: \.self) { index in
                        let peripheral = ble.peripherals[index]
//                        HStack{
//                            VStack(alignment: .leading){
//                                Text(peripheral.name)
//                                    .bold()
//                                Text("Rssi: \(peripheral.rssi)")
//                            }
//                            Spacer()
//                            BLEConnect_button(name: peripheral.name)
//                                .frame(alignment: .trailing)
//                        }
                        ConnectButton(peripheral: peripheral, Enable: $Enable)
                            .environmentObject(ble)
                            .padding()
                            .frame(height: 50)
                        Divider()
                    }
                }
                .background(RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color(UIColor.systemGray5)).shadow(radius: 1))
            }
            else {
                Text("Please Turn On  Device")
//                    .font(.title2)
                    .bold()
                    .frame(height: 60)
            }
        }
        .frame(maxWidth: geometry.size.width - 100)
    }
}

struct ConnectButton: View {
    @EnvironmentObject var ble:BLE
    var peripheral : Peripheral
    @State var State = ""
    @Binding var Enable : Bool
    var body : some View {
        Button(action: {
            if peripheral.State == 0 && ble.peripherals.filter({$0.State != 0}).count < 1 {
                ble.connect(peripheral: peripheral.Peripheral)
            }
            else if peripheral.State == 1{
                ble.cancelConnection(peripheral: peripheral.Peripheral)
            }
            else if peripheral.State == 2{
                ble.disconnect(peripheral: peripheral.Peripheral)
                rememberConntion.removeObject(forKey:"PreviousName")
                ble.scan_devices()
            }
        }){
            HStack{
                VStack(alignment: .leading){
                    Text(peripheral.name)
                        .foregroundColor(Color(UIColor.label))
                        .bold()
                        .accessibility(label: Text("Device \(peripheral.name)"))
//                    Text("Rssi: \(peripheral.rssi)")
//                        .foregroundColor(Color(UIColor.label))
                }
                Spacer()
                ButtonStr
            }
        }
    }
    
    var ButtonStr : some View{
        VStack{
            if peripheral.State == 0{
                Text("Connect")
                    .accessibility(label: Text("Tap to Connect"))
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
                    .accessibility(label: Text("Tap to Disconnect"))
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

//struct BLEConnect_button: View {
//    @EnvironmentObject var ble:BLE
//    var name : String
//    var body : some View {
//        Button(action: {
//            if name != ""{
//                if let index = ble.peripherals.firstIndex(where: {$0.name == name}){
//                    let peripheral = ble.peripherals[index]
//                    if peripheral.State == 0 && ble.peripherals.filter({$0.State != 0}).count < 1{
//                        ble.connect(peripheral: peripheral.Peripheral)
//                    }
//                    else if peripheral.State == 1{
//                        ble.cancelConnection(peripheral: peripheral.Peripheral)
//                    }
//                    else if peripheral.State == 2{
//                        ble.disconnect(peripheral: peripheral.Peripheral)
//                        rememberConntion.removeObject(forKey:"PreviousName")
//                        ble.scan_devices()
//                    }
//                }
//            }
//        }) {
//            if name != "" {
//                if let index = ble.peripherals.firstIndex(where: {$0.name == name}){
//                    let peripheral = ble.peripherals[index]
//                    if peripheral.State == 0{
//                        Text("Connect")
//                            .font(.title2)
//                            .foregroundColor(ble.peripherals.filter({$0.State != 0}).count < 1 ? .blue : Color(UIColor.lightGray))
//                            .multilineTextAlignment(.trailing)
//                    }
//                    else if peripheral.State == 1{
//                        Text("Connecting")
//                            .font(.title2)
//                            .foregroundColor(.blue)
//                            .multilineTextAlignment(.trailing)
//                    }
//                    else if peripheral.State == 2{
//                        Text("Disconnect")
//                            .font(.title2)
//                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
//                            .multilineTextAlignment(.trailing)
//                    }
//                    else {
//                        Text("Disconnecting")
//                            .font(.title2)
//                            .multilineTextAlignment(.trailing)
//                    }
//                }
//            }
//        }
//    }
//}

struct BLEScanner_Alert_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            BLEScanner_Alert(Enable: .constant(true), geometry: geometry).environmentObject(BLE())
        }
    }
}
