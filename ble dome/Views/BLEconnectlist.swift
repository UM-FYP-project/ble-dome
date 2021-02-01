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
//        List(ble.peripherals) { peripheral in NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
//                peripheralrow(peripheral: peripheral)
//                    .onTapGesture {
//                        print("List\(peripheral.name)")
//                        ble.connect(peripheral: peripheral.Peripherasl)
//                    }
//            }.frame(width: UIScreen.main.bounds.width, height: 40)
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
