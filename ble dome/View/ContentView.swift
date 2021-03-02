//
//  ContentView.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var ble = BLE()
    var body: some View {
        BLEScanner()
            .environmentObject(ble)
            .onAppear(perform: {
                if !ble.isInit{
                    ble.initBLE()
                }
            })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
