//
//  peripheralrow.swift
//  ble dome
//
//  Created by UM on 28/01/2021.
//

import SwiftUI

struct peripheralrow: View {
    var peripheral : Peripheral
    @ObservedObject var ble = BLE()
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                        Text(peripheral.name)
                            .bold()
                            .font(.title2)
                        Text("Rssi: \(peripheral.rssi)")
                if peripheral.SerivceID != "N/A"{
                    Text("Serivce: \(peripheral.SerivceID)")
                }
            }
            Spacer()
            if ble.bleconnection == 0{
                Text("Tap to connect")
                    .font(.title2)
                    .multilineTextAlignment(.trailing)
                    
            }
            else if ble.bleconnection == 1{
                Text("Connecting")
                    .font(.title2)
                    .multilineTextAlignment(.trailing)
            }
            else if ble.bleconnection == 2{
                Text("Tap to Disconnect")
                    .font(.title2)
                    .multilineTextAlignment(.trailing)
            }
            else{
                Text("Disconnecting")
                    .font(.title2)
                
            }
        }
        .onTapGesture {
            if ble.bleconnection == 0{
                print("Connect to \(peripheral.name)")
                ble.connect(peripheral: peripheral.Peripherasl)
            }
            else if ble.bleconnection == 2{
                print("Disconnect to \(peripheral.name)")
                ble.disconnect(peripheral: peripheral.Peripherasl)
            }
    }
    }
}

