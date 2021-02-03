//
//  BLEScanner.swift
//  ble dome
//
//  Created by UM on 28/01/2021.
//

import SwiftUI

struct BLEScannerList: View {
    @EnvironmentObject var ble:BLE
    var body: some View {
        if ble.isBluetoothON && ble.wasScanned{
            List(ble.peripherals) {peripheral in
                peripheralrow(peripheral:peripheral)
            }
        }
        else if !ble.isBluetoothON{
            Spacer()
            Text("Please Turn On Bluetooth")
                .font(.largeTitle)
            Spacer()
        }
        else if !ble.wasScanned{
            Spacer()
            Text("Please Tap Scan Button")
                .font(.largeTitle)
            Spacer()
        }
    }
}

struct BLEScannerList_Previews: PreviewProvider {
    static var previews: some View {
        BLEScannerList()
    }
}
