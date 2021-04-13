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
    @EnvironmentObject var readeract : readerAct
    @State private var selectedTab = 0
//    @Binding var Enable : Bool
    var peripheral : Peripheral
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                //                NavigationView{
                TabView(selection: $selectedTab) {
                    if peripheral.Service.contains("2A68"){
                        //                        NavigationView{
                        GeometryReader{ geom in
                            ReaderTab(geometry: geom)
                                .environmentObject(reader)
                                .environmentObject(readeract)
                                .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                        }
                        .tabItem {
                            Image(systemName: "dot.radiowaves.left.and.right")
                            Text("Reader")
                                .tag(0)
                        }
                    }
                    //                    NavigationView{
                    PeripheralDetail(peripheral: peripheral)
                        .environmentObject(ble)
                        .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                        .tabItem {
                            Image(systemName: "list.dash")
                            Text("Detail")
                                .tag(1)
                        }
                }
                //            }
            }
            
            .disabled(readeract.SelectedBaudrate_picker || readeract.SelectedPower_picker || readeract.inventorySpeed_picker || readeract.DataBlock_picker || readeract.DataStart_picker ||  readeract.DataLen_picker || readeract.EPC_picker)
            .overlay(readeract.SelectedBaudrate_picker || readeract.SelectedPower_picker || readeract.inventorySpeed_picker || readeract.DataBlock_picker || readeract.DataStart_picker ||  readeract.DataLen_picker || readeract.EPC_picker ? Color.black.opacity(0.3).ignoresSafeArea(): nil)
            if readeract.SelectedBaudrate_picker{
                Reader_Picker(picker: readeract.BaudrateCmdinStr,title: "Select Baudrate", label: "Baudrate", geometry: geometry, Selected: $readeract.SelectedBaudrate, enable: $readeract.SelectedBaudrate_picker)
            }
            if readeract.SelectedPower_picker{
                Reader_Picker(picker: readeract.Outpower,title: "Select Output Power", label: "Output Power", geometry: geometry, Selected: $readeract.SelectedPower, enable: $readeract.SelectedPower_picker)
            }
            if readeract.inventorySpeed_picker {
                Reader_Picker(picker: readeract.inventorySpeed, title: "Select Speed", label: "Speed", geometry: geometry, Selected: $readeract.inventorySpeed_Selected, enable: $readeract.inventorySpeed_picker)
            }
            if readeract.DataBlock_picker{
                Reader_Picker(picker: readeract.DataCmdinStr,title: "Select DataBlock", label: "DataBlock", geometry: geometry, Selected: $readeract.DataBlock_Selected, enable: $readeract.DataBlock_picker)
            }
            if readeract.DataStart_picker{
                Reader_Picker(picker: readeract.DataByte,title: "Select Data Start", label: "Data Start", geometry: geometry, Selected: $readeract.DataStart_Selected, enable: $readeract.DataStart_picker)
            }
            if readeract.DataLen_picker{
                Reader_Picker(picker: readeract.DataByte,title: "Select Data Lenght", label: "Data Lenght", geometry: geometry, Selected: $readeract.DataLen_Selected, enable: $readeract.DataLen_picker)
            }
            if readeract.EPC_picker{
                Reader_Picker(picker: reader.EPCstr, title: "Select Tag EPC", label: "EPC Matching", geometry: geometry, Selected: $readeract.EPC_Selected, enable: $readeract.EPC_picker)
            }
        }
        .navigationTitle("\(peripheral.name)")
    }
}

