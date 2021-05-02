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
    @ObservedObject var readeract = readerAct()
    @ObservedObject var location = LocationManager()
    @State var isScanner_trigged = false
    @State var notConnectedAlert_trigged = true
    @State var Scanner_longpressed = false
    @State var Conncetedperipheral_index = 0
    @State var Latitude : Float = 0
    @State var Longitude : Float = 0
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                NavigationView {
                    TabView() {
                        VStack{
                            HStack{
                                if !ble.peripherals.isEmpty && !(ble.peripherals.filter({$0.State == 2}).count < 1){
                                    NavigationLink(
                                        destination:
                                            DetailTabView(geometry: geometry, peripheral: ble.peripherals[Conncetedperipheral_index])
                                            .environmentObject(ble)
                                            .environmentObject(reader)
                                            .environmentObject(readeract)
                                            .environmentObject(location)
                                            .disabled(ble.isBluetoothON && isScanner_trigged)
                                            .overlay(ble.isBluetoothON && isScanner_trigged  ? Color.black.opacity(0.3).ignoresSafeArea() : nil),
                                        isActive: $Scanner_longpressed,
                                        label: {
                                            EmptyView()
                                        })
                                }
                                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                                    .onTapGesture(perform: {
                                        if let index = ble.peripherals.firstIndex(where: {$0.State == 2}){
                                            Scanner_longpressed = true
                                            Conncetedperipheral_index = index
                                        }
                                    })
                            }
                            Button(action: {
                                self.location.start()
                                Latitude = Float(self.location.lastLocation?.coordinate.latitude ?? 00)
                                Longitude = Float(self.location.lastLocation?.coordinate.longitude ?? 00)
                                print("LatitudeInByte: \(Data(Latitude.bytes).hexEncodedString()) LongitudeInByte: \(Data(Longitude.bytes).hexEncodedString())")
//                                print(LongitudeInByte)
//                                self.location.stop()
                            }) {
                                Text("Get Location")
                                    .bold()
                                    .font(.headline)
                            }
                            HStack{
                                Text("Latitude:")
                                    .font(.headline)
                                Text("\(Latitude)")
                                Spacer()
                                Divider()
                                    .frame(height: 20)
                                Text("Longitude:")
                                    .font(.headline)
                                Text("\(Longitude)")
                                Spacer()
                            }
                            .frame(width: geometry.size.width - 20)
                            Divider()
                            HStack{
                                Text("Latitude:")
                                    .font(.headline)
                                Text("\(Data(Latitude.bytes).hexEncodedString())")
                                Spacer()
                                Divider()
                                    .frame(height: 20)
                                Text("\(Data(Latitude.bytes).withUnsafeBytes{$0.load(fromByteOffset: 0, as: Float.self)})")
                                Spacer()
                            }
                            .frame(width: geometry.size.width - 20)
                            Divider()
                            HStack{
                                Text("Longitude:")
                                    .font(.headline)
                                Text("\(Data(Longitude.bytes).hexEncodedString())")
                                Spacer()
                                Divider()
                                    .frame(height: 20)
                                Text("\(Data(Longitude.bytes).withUnsafeBytes{$0.load(as: Float.self)})")
                                Spacer()
                            }
                            .frame(width: geometry.size.width - 20)
                        }
                        
                        .tabItem{
                            Image(systemName: "house")
                            Text("Home")
                        }
                    }
                    .navigationTitle("Test")
                    .navigationBarItems(trailing:
                                            Button(action: {isScanner_trigged = true}) {
                                                Text("Scanner")
                                            }
                                            .padding()
                                            .disabled(!ble.isBluetoothON)
                    )
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
