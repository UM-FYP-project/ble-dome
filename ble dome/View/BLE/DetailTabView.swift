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
    @EnvironmentObject var picker : readerPicker
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
            
            .disabled(picker.SelectedBaudrate_picker || picker.SelectedPower_picker || picker.inventorySpeed_picker || picker.DataBlock_picker || picker.DataStart_picker ||  picker.DataLen_picker || picker.EPC_picker)
            .overlay(picker.SelectedBaudrate_picker || picker.SelectedPower_picker || picker.inventorySpeed_picker || picker.DataBlock_picker || picker.DataStart_picker ||  picker.DataLen_picker || picker.EPC_picker ? Color.black.opacity(0.3).ignoresSafeArea(): nil)
            if picker.SelectedBaudrate_picker{
                Reader_Picker(picker: picker.BaudrateCmdinStr,title: "Select Baudrate", label: "Baudrate", geometry: geometry, Selected: $picker.SelectedBaudrate, enable: $picker.SelectedBaudrate_picker)
            }
            if picker.SelectedPower_picker{
                Reader_Picker(picker: picker.Outpower,title: "Select Output Power", label: "Output Power", geometry: geometry, Selected: $picker.SelectedPower, enable: $picker.SelectedPower_picker)
            }
            if picker.inventorySpeed_picker {
                Reader_Picker(picker: picker.inventorySpeed, title: "Select Speed", label: "Speed", geometry: geometry, Selected: $picker.inventorySpeed_Selected, enable: $picker.inventorySpeed_picker)
            }
            if picker.DataBlock_picker{
                Reader_Picker(picker: picker.DataCmdinStr,title: "Select DataBlock", label: "DataBlock", geometry: geometry, Selected: $picker.DataBlock_Selected, enable: $picker.DataBlock_picker)
            }
            if picker.DataStart_picker{
                Reader_Picker(picker: picker.DataByte,title: "Select Data Start", label: "Data Start", geometry: geometry, Selected: $picker.DataStart_Selected, enable: $picker.DataStart_picker)
            }
            if picker.DataLen_picker{
                Reader_Picker(picker: picker.DataByte,title: "Select Data Lenght", label: "Data Lenght", geometry: geometry, Selected: $picker.DataLen_Selected, enable: $picker.DataLen_picker)
            }
            if picker.EPC_picker{
                Reader_Picker(picker: reader.EPCstr, title: "Select Tag EPC", label: "EPC Matching", geometry: geometry, Selected: $picker.EPC_Selected, enable: $picker.EPC_picker)
            }
        }
        .navigationTitle("\(peripheral.name)")
    }
}

