//
//  peripheralrow.swift
//  ble dome
//
//  Created by UM on 28/01/2021.
//

import SwiftUI

struct peripheralrow: View {
    var peripheral : Peripheral
    @EnvironmentObject var ble:BLE
    @State var connectButton_str:String = "Tap to Connect"
    @State var longpressed:Bool = false
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(peripheral.name)
                    .bold()
                    .font(.title2)
                Text("Rssi: \(peripheral.rssi)")
                Text("Serive: \(peripheral.Service)")
            }
            Spacer()
            BLEConnect_button_text(peripheral: peripheral)
        }
        .onAppear(perform: {
            longpressed = false
        })
        .onTapGesture {
            if peripheral.State == 0{
                print("Connect to \(peripheral.name)")
                ble.connect(peripheral: peripheral.Peripheral)
            }
            else if peripheral.State == 2{
                print("Disconnect to \(peripheral.name)")
                ble.disconnect(peripheral: peripheral.Peripheral)
            }
        }
        .onLongPressGesture(minimumDuration: 1.0) {
            if peripheral.State == 0{
                print("Connect to \(peripheral.name)")
                ble.connect(peripheral: peripheral.Peripheral)
            }
            longpressed = true
        }
        .sheet(isPresented: $longpressed, content: {
            NavigationView {
                List{
                    PeripheralDetail(peripheral: peripheral).environmentObject(ble)
                }
                .navigationTitle(Text("Peripheral Detail"))
            }
        })
    }
}

struct BLEConnect_button_text: View {
    @EnvironmentObject var ble:BLE
    var peripheral : Peripheral
    var body: some View {
        if peripheral.State == 0{
            Text("Tap to connect")
                .font(.title2)
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .multilineTextAlignment(.trailing)
        }
        else if peripheral.State == 1{
            Text("Connecting")
                .font(.title2)
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

