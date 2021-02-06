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
        .onAppear(perform: {
            longpressed = false
        })
        .onTapGesture {
            if peripheral.State == 0{
                print("Connect to \(peripheral.name)")
                ble.connect(peripheral: peripheral.Peripherasl)
            }
            else if peripheral.State == 2{
                print("Disconnect to \(peripheral.name)")
                ble.disconnect(peripheral: peripheral.Peripherasl)
            }
        }
        .onLongPressGesture(minimumDuration: 1.0) {
            if peripheral.State == 0{
                print("Connect to \(peripheral.name)")
                ble.connect(peripheral: peripheral.Peripherasl)
            }
            longpressed = true
        }
        .sheet(isPresented: $longpressed, content: {
            if peripheral.State == 2 {
                PeripheralDetail()
            }
        })
    }
}

