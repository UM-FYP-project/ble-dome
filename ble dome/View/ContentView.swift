//
//  ContentView.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var ble = BLE()
    @State var isScanner_trigged = false
    @State var notConnectedAlert_trigged = true
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                //if !Scanner_longpressed {
                    TabView() {
                        NavigationView {
                            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                                .navigationBarItems(trailing:
                                                        Button(action: {isScanner_trigged = true}) {
                                                            Text("Scanner")
                                                        }
                                                        .padding()
                                                        .disabled(!ble.isBluetoothON)
                                )
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
//                }
//                else if Scanner_longpressed{
//
//                }
            }
//        BLEScanner()
//            .environmentObject(ble)
//            .onAppear(perform: {
//                if !ble.isInit{
//                    ble.initBLE()
//                }
//            })
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
