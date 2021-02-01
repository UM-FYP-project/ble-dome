//
//  BLEScanner.swift
//  ble dome
//
//  Created by UM on 01/02/2021.
//

import SwiftUI

struct BLEScanner: View {
    @ObservedObject var ble = BLE()
    @State var Scanbutton = true
    var body: some View {
        NavigationView {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                if !Scanbutton || !ble.isBluetoothON {
                    Button(action: {
                        ble.scan_devices()
                        Scanbutton = true
                    }) {
                        Text("Scan Device")
                            .font(.title2)
                            
                    }.frame(width: UIScreen.main.bounds.width - 20, alignment: .trailing)
                }
                else {
                    Button(action: {
                        ble.stopscan_device()
                        Scanbutton = false
                    }) {
                        Text("Stop Scanning")
                            .font(.title2)
                    }.frame(width: UIScreen.main.bounds.width - 20, alignment: .trailing)
                }
                    if ble.isBluetoothON && Scanbutton {
                        BLEconnectlist()
                            .frame(width: UIScreen.main.bounds.width)
                    }
                    else if !ble.isBluetoothON{
                        Spacer()
                        Text("Please Turn Your Bluetooth")
                            .font(.title)
                        Spacer()
                    }
                    else{
                        Spacer()
                        Text("Please Tap Scan")
                            .font(.title)
                        Spacer()
                    }
            }.navigationTitle("Device Scanner")
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
    }
}

struct BLEScanner_Previews: PreviewProvider {
    static var previews: some View {
        BLEScanner()
    }
}
