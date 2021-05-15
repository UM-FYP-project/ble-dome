//
//  DetailTabView.swift
//  ble dome
//
//  Created by UM on 07/02/2021.
//

import SwiftUI
import CoreBluetooth

struct DetailTabView: View {
//    var geometry : GeometryProxy
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader : Reader
    @EnvironmentObject var readerconfig : ReaderConfig
    @EnvironmentObject var location : LocationManager
//    @Binding var Enable : Bool
    var peripheral : Peripheral
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                //                NavigationView{
                TabView() {
                    if peripheral.Service.contains("2A68"){
                        GeometryReader{ geom in
                            ReaderTab(geometry: geom)
                                .environmentObject(reader)
                                .environmentObject(readerconfig)
                                .environmentObject(location)
                                .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                        }
                        .tabItem {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Reader")
                                .tag(0)
                        }
                        Text("Hello")
                            .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                            .tabItem {
                                Image(systemName: "dot.radiowaves.left.and.right")
                                Text("Vibration")
                                    .tag(1)
                            }
                    }
                    //                    NavigationView{
                    PeripheralDetail(peripheral: peripheral)
                        .environmentObject(ble)
                        .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                        .tabItem {
                            Image(systemName: "list.dash")
                            Text("Detail")
                                .tag(2)
                        }
                }
                .disabled(readerconfig.SelectedBaudrate_picker || readerconfig.SelectedPower_picker ||  readerconfig.DataBlock_picker || readerconfig.EPC_picker)
                .overlay(readerconfig.SelectedBaudrate_picker || readerconfig.SelectedPower_picker || readerconfig.DataBlock_picker ||  readerconfig.EPC_picker ? Color.black.opacity(0.3).ignoresSafeArea(): nil)
                if readerconfig.SelectedBaudrate_picker{
                    AlertPicker(picker: readerconfig.BaudrateCmdinStr,title: "Select Baudrate", label: "Baudrate", geometry: geometry, Selected: $readerconfig.SelectedBaudrate, enable: $readerconfig.SelectedBaudrate_picker)
                }
                if readerconfig.SelectedPower_picker{
                    AlertPicker(picker: readerconfig.Outpower,title: "Select Output Power", label: "Output Power", geometry: geometry, Selected: $readerconfig.SelectedPower, enable: $readerconfig.SelectedPower_picker)
                }
                if readerconfig.DataBlock_picker{
                    AlertPicker(picker: readerconfig.DataCmdinStr,title: "Select DataBlock", label: "DataBlock", geometry: geometry, Selected: $readerconfig.DataBlock_Selected, enable: $readerconfig.DataBlock_picker)
                }
                if readerconfig.EPC_picker{
                    AlertPicker(picker: readerconfig.EPCstr, title: "Select Tag EPC", label: "EPC Matching", geometry: geometry, Selected: $readerconfig.EPC_Selected, enable: $readerconfig.EPC_picker)
                }
            }
//            .navigationTitle("Reader Setting")
            .navigationBarTitle("\(peripheral.name)", displayMode: .inline)
        }
    }
}

