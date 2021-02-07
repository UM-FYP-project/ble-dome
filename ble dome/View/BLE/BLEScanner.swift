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
            BLEScannerList().environmentObject(ble)
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

struct BLEScanner_Previews: PreviewProvider {
    static var previews: some View {
        BLEScanner()
    }
}
