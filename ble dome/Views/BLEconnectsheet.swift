//
//  BLEconnectsheet.swift
//  ble dome
//
//  Created by UM on 28/01/2021.
//

import SwiftUI

struct BLEconnectsheet: View {
    @ObservedObject var ble = BLE()
    @State var scan_button_state = false
    var body: some View {
        VStack{
            Text("Scanner")
                .bold()
                .font(.largeTitle)
                .frame(width: UIScreen.main.bounds.width - 20, height: 50, alignment: .leading)
            Spacer()
            if ble.isBluetoothON && scan_button_state{
                List {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Content")/*@END_MENU_TOKEN@*/
                }
            }
            else if !scan_button_state{
                Text("Please Tap Scan Device")
                    .font(.title)
            }
            else{
                Text("Please Turn on Bluetooth")
                    .font(.title)
            }
            Spacer()
            Button(action: {
                if scan_button_state {
                    scan_button_state = false
                    ble.stopscan_device()
                }
                else{
                    scan_button_state = true
                    ble.scan_devices()
                }
            }) {
                if scan_button_state{
                    Text("Stop Scanning")
                        .font(.title)
                }
                else{
                    Text("Scan")
                        .font(.title)
                }
            }
        }
    }
}

struct BLEconnectsheet_Previews: PreviewProvider {
    static var previews: some View {
        BLEconnectsheet()
    }
}
