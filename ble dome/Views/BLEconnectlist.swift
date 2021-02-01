//
//  BLEconnectlist.swift
//  ble dome
//
//  Created by UM on 28/01/2021.
//

import SwiftUI

struct BLEconnectlist: View {
    @ObservedObject var ble = BLE()
    var body: some View {
//        List(ble.peripherals) { peripheral in NavigationLink(destination: PeripheralDetail(peripheral: peripheral)) {
//                peripheralrow(peripheral: peripheral)
//            }.frame(width: UIScreen.main.bounds.width, height: 40)
//        }
        List(ble.peripherals) {peripheral in
            peripheralrow(peripheral:peripheral)
        }
    }
}

struct BLEconnectlist_Previews: PreviewProvider {
    static var previews: some View {
        BLEconnectlist()
    }
}
