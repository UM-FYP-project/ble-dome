//
//  DetailTabView.swift
//  ble dome
//
//  Created by UM on 07/02/2021.
//

import SwiftUI

struct DetailTabView: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader : Reader
    @Binding var Enable : Bool
    var peripheral : Peripheral
    var body: some View {
//        GeometryReader { gemetry in
        ZStack{
            TabView() {
                if peripheral.Service.contains("2A68"){
                    NavigationView{
                        GeometryReader{ geometry in
                            ReaderTab(geometry: geometry)
                            .environmentObject(reader)
                            .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                            .navigationTitle("\(peripheral.name) Reader")
                            .navigationBarItems(leading:
                                                    Button(action: {Enable = false}){
                                                        HStack{
                                                            Image(systemName: "chevron.backward")
                                                            Text("Back")
                                                        }
                                                    })
                        }
                    }
                    .tabItem {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("Reader")
                            .tag(1)
                    }
                }
                NavigationView{
                    PeripheralDetail(peripheral: peripheral)
                        .environmentObject(ble)
                        .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                        .navigationTitle("\(peripheral.name) Detail")
                        .navigationBarItems(leading:
                                                Button(action: {Enable = false}){
                                                    HStack{
                                                        Image(systemName: "chevron.backward")
                                                        Text("Back")
                                                    }
                                                })
                }
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Detail")
                        .tag(2)
                }
            }

        }
//        .navigationBarHidden(true)
//        }
    }
}

