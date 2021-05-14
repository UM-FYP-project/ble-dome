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
    @EnvironmentObject var readeract : readerAct
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
                                .environmentObject(readeract)
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
                .disabled(readeract.SelectedBaudrate_picker || readeract.SelectedPower_picker ||  readeract.DataBlock_picker || readeract.EPC_picker)
                .overlay(readeract.SelectedBaudrate_picker || readeract.SelectedPower_picker || readeract.DataBlock_picker ||  readeract.EPC_picker ? Color.black.opacity(0.3).ignoresSafeArea(): nil)
                if readeract.SelectedBaudrate_picker{
                    AlertPicker(picker: readeract.BaudrateCmdinStr,title: "Select Baudrate", label: "Baudrate", geometry: geometry, Selected: $readeract.SelectedBaudrate, enable: $readeract.SelectedBaudrate_picker)
                }
                if readeract.SelectedPower_picker{
                    AlertPicker(picker: readeract.Outpower,title: "Select Output Power", label: "Output Power", geometry: geometry, Selected: $readeract.SelectedPower, enable: $readeract.SelectedPower_picker)
                }
                if readeract.DataBlock_picker{
                    AlertPicker(picker: readeract.DataCmdinStr,title: "Select DataBlock", label: "DataBlock", geometry: geometry, Selected: $readeract.DataBlock_Selected, enable: $readeract.DataBlock_picker)
                }
                if readeract.EPC_picker{
                    AlertPicker(picker: reader.EPCstr, title: "Select Tag EPC", label: "EPC Matching", geometry: geometry, Selected: $readeract.EPC_Selected, enable: $readeract.EPC_picker)
                }
            }
//            .navigationTitle("Reader Setting")
            .navigationBarTitle("\(peripheral.name)", displayMode: .inline)
        }
    }
}

