//
//  BLEconnectsheet.swift
//  ble dome
//
//  Created by UM on 28/01/2021.
//

import SwiftUI

struct BLEScanner: View {
    @EnvironmentObject var ble:BLE
    @State var scanButton_str: String = "Scan"
    var body: some View {
        GeometryReader{ geometry in
            NavigationView {
                BLEScannerList().environmentObject(ble)
                    .navigationTitle("Device Scanner")
                    .navigationBarItems(trailing:
                                            Button(action: {scanButton()}) {
                                                Text(scanButton_str)
                                                    .font(.title2)
                                                    .frame(width: 150,  alignment: .trailing)
                                            }
                    )
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                if ble.isBluetoothON{
                    scanButton_str = "Stop Scanning"
                    ble.scan_devices()
                }
            }
        })
    }
    
    func scanButton(){
        if ble.isScanned{
            ble.stopscan_device()
            scanButton_str = "Scan"
        }
        else{
            ble.scan_devices()
            scanButton_str = "Stop Scanning"
        }
    }
}

struct BLEScanner_Previews: PreviewProvider {
    static var previews: some View {
        BLEScanner()
    }
}
