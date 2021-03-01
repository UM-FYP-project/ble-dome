//
//  DetailTabView.swift
//  ble dome
//
//  Created by UM on 07/02/2021.
//

import SwiftUI

struct DetailTabView: View {
    @EnvironmentObject var ble:BLE
    @State var Reader_disable : Bool = false
    var peripheral : Peripheral
    @Binding var peripheral_connected : [String:Bool]
    var body: some View {
        TabView() {
                PeripheralDetail(peripheral: peripheral).environmentObject(ble)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Detail")
                }
            if peripheral.Service.contains("2A68"){
                ReaderTab()
                    .disabled(peripheral_connected[peripheral.name] ?? true)
                    .tabItem {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("Reader")
                    }
            }
        }
        .navigationBarTitle("\(peripheral.name) Detail")
    }
}

