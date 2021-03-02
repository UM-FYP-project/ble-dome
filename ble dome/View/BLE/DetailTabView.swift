//
//  DetailTabView.swift
//  ble dome
//
//  Created by UM on 07/02/2021.
//

import SwiftUI

struct DetailTabView: View {
    @EnvironmentObject var ble:BLE
    @ObservedObject var reader = Reader()
    var peripheral : Peripheral
    var body: some View {
        TabView() {
                PeripheralDetail(peripheral: peripheral).environmentObject(ble)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Detail")
                }
            if peripheral.Service.contains("2A68"){
                ReaderTab()
                    .environmentObject(reader)
                    .tabItem {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("Reader")
                    }
            }
        }
        .navigationBarTitle("\(peripheral.name) Detail")
    }
}

