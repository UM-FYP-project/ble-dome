//
//  DetailTabView.swift
//  ble dome
//
//  Created by UM on 07/02/2021.
//

import SwiftUI

struct DetailTabView: View {
    @EnvironmentObject var ble:BLE
    var peripheral : Peripheral
    var body: some View {
        TabView() {
                PeripheralDetail(peripheral: peripheral).environmentObject(ble)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Detail")
            }
        }
        .navigationBarTitle("\(peripheral.name) Detail")
    }
}
