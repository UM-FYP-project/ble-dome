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
                        HStack{
//                            if !ble.peripherals.isEmpty {
//                                NavigationLink(
//                                    destination:DetailTabView(Enable: $Scanner_longpressed, peripheral: ble.peripherals[Conncetedperipheral_index])
//                                        .environmentObject(ble)
//                                        .environmentObject(reader)
//                                        .navigationBarHidden(true),
//                                    isActive: $Scanner_longpressed,
//                                    label: {
//                                        EmptyView()
//                                    })
//                            }
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
                        }
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
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true){_ in
                        if !ble.isInit{
                            ble.initBLE()
                        }
                        //                    if !ble.isConnected{
                        //                        notConnectedAlert_trigged = true
                        //                    }
                        if (ble.peripherals.filter({$0.State == 2}).count < 1) && !isScanner_trigged{
                            notConnectedAlert_trigged = true
                        }
                        else{
                            notConnectedAlert_trigged = false
                        }
                    }
                })
                .alert(isPresented: $notConnectedAlert_trigged) {
                    Alert(
                        title: Text("Please Connect Deivce"),
                        message: Text("Scanner will Pop-up"),
                        dismissButton: .default(Text("OK"), action: {isScanner_trigged = true})
                    )
                }
                .disabled(ble.isBluetoothON && isScanner_trigged)
                .overlay(ble.isBluetoothON && isScanner_trigged  ? Color.black.opacity(0.3).ignoresSafeArea() : nil)
                if Scanner_longpressed{
                    DetailTabView(Enable: $Scanner_longpressed, peripheral: ble.peripherals[Conncetedperipheral_index])
                        .environmentObject(ble)
                        .environmentObject(reader)
                        .disabled(ble.isBluetoothON && isScanner_trigged)
                        .overlay(ble.isBluetoothON && isScanner_trigged  ? Color.black.opacity(0.3).ignoresSafeArea()  : nil)
                }
                if ble.isBluetoothON && isScanner_trigged{
                    BLEScanner_Alert(Enable: $isScanner_trigged, geometry: geometry).environmentObject(ble)
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
