//
//  ContentView.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var ble = BLE()
    @ObservedObject var reader = Reader()
    @State var isScanner_trigged = false
    @State var notConnectedAlert_trigged = true
    @State var Scanner_longpressed = false
    @State var Conncetedperipheral_index = 0
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                TabView() {
                    NavigationView {
                        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                            .onTapGesture(perform: {
//                                if ble.Connected_Peripheral != nil{
//                                    Scanner_longpressed = true
//                                }
                                if let index = ble.peripherals.firstIndex(where: {$0.State == 2}){
                                    Scanner_longpressed = true
                                    Conncetedperipheral_index = index
                                }
                            })
                            .navigationBarItems(trailing:
                                                    Button(action: {isScanner_trigged = true}) {
                                                        Text("Scanner")
                                                    }
                                                    .padding()
                                                    .disabled(!ble.isBluetoothON)
                            )
                    }
                    .tabItem{
                        Image(systemName: "house")
                        Text("Home")
                    }
                }
                .onAppear(perform: {
                    if !ble.isInit{
                        ble.initBLE()
                    }
                    if !ble.isConnected{
                        notConnectedAlert_trigged = true
                    }
                    else{
                        notConnectedAlert_trigged = false
                    }
                })
                .alert(isPresented: $notConnectedAlert_trigged) {
                    Alert(
                        title: Text("Please Connect Deivce"),
                        message: Text("Scanner will Pop-up"),
                        dismissButton: .default(Text("OK"), action: {isScanner_trigged = true})
                    )
                }
                .overlay(ble.isBluetoothON && isScanner_trigged  ? Color.black.opacity(0.3) : nil)
                if ble.isBluetoothON && isScanner_trigged{
                    BLEScanner_Alert(Enable: $isScanner_trigged, geometry: geometry).environmentObject(ble)
                }
                if Scanner_longpressed{
                    DetailTabView(Enable: $Scanner_longpressed, peripheral: ble.peripherals[Conncetedperipheral_index])
                        .environmentObject(ble)
                        .environmentObject(reader)
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
