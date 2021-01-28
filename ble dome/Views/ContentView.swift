//
//  ContentView.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var ble = BLE()
    @State var connect_button_state = false
    var body: some View {
        NavigationView {
            if ble.isBluetoothON{
                Button(action: {
                            self.connect_button_state = true
                        }) {
                            Text("Connect BLE Device")
                                .font(.title)
                        }.frame(width: UIScreen.main.bounds.width - 20, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .navigationTitle("Deivce Connection")
            }
            else{
                Text("Please Turn on Bluetooth")
                    .font(.title)
                    .navigationTitle("Deivce Connection")
            }
        }
        .sheet(isPresented: $connect_button_state) {
            BLEconnectsheet()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}


