//
//  ContentView.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI
import CoreBluetooth

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
                                            DetailTabView(peripheral: ble.peripherals[Conncetedperipheral_index])
                                            .environmentObject(ble)
                                            .environmentObject(reader)
                                            .environmentObject(readeract)
                                            .environmentObject(location)
                                            .disabled(ble.isBluetoothON && isScanner_trigged)
                                            .overlay(ble.isBluetoothON && isScanner_trigged  ? Color.black.opacity(0.3).ignoresSafeArea() : nil)
                                            .navigationBarItems(trailing:
                                                                    Button(action: {isScanner_trigged = true}) {
                                                                        Text("Scanner")
                                                                    }
                                                                    .padding()
                                                                    .disabled(!ble.isBluetoothON)
                                            ),
                                        isActive: $Scanner_longpressed,
                                        label: {
                                            EmptyView()
                                        })
                                }
                                Text("Setting")
                                    .onTapGesture(perform: {
                                        if let index = ble.peripherals.firstIndex(where: {$0.State == 2}){
                                            Scanner_longpressed = true
                                            Conncetedperipheral_index = index
                                        }
                                    })
                            }
                        }
                        .tabItem{
                            Image(systemName: "house")
                            Text("Home")
                        }
                    }
                    .navigationTitle("Home")
                    .navigationBarItems(trailing:
                                            Button(action: {isScanner_trigged = true}) {
                                                Text("Scanner")
                                            }
                                            .padding()
                                            .disabled(!ble.isBluetoothON)
                    )
                }
                .onAppear(perform: {
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: true){_ in
                        if !ble.isInit{
                            ble.initBLE()
                        }
                        if (ble.peripherals.filter({$0.State == 2}).count < 1) && !isScanner_trigged{
                            Scanner_longpressed = false
                            reader.TagsData.removeAll()
                            reader.Tags.removeAll()
                            reader.tagsCount = 0
                            reader.BytesRecord.removeAll()
                            let previousConntection : String? = rememberConntion.object(forKey: "PreviousName") as? String ?? nil
                            if previousConntection != nil {
                                print("Conntect with \(previousConntection!)")
                                ble.scan_devices()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    if let index = ble.peripherals.firstIndex(where: {$0.name == previousConntection!}){
                                        ble.connect(peripheral: ble.peripherals[index].Peripheral)
                                    }
                                    else{
                                        ble.stopscan_device()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            notConnectedAlert_trigged = true
                                        }
                                    }
                                }
                            }
                            else {
                                notConnectedAlert_trigged = true
                            }
                        }
                        else{
                            notConnectedAlert_trigged = false
                        }
                        isNavorSet()
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
    
    func isNavorSet(){
        if ble.peripherals.contains(where: {$0.State == 2 && $0.Service.contains("2A68")}){
            let peripheralIndex = ble.peripherals.firstIndex(where: {$0.State == 2 && $0.Service.contains("2A68")})
            let peripheral = ble.peripherals[peripheralIndex!].Peripheral
            let characteristicIndex = ble.Peripheral_characteristics.firstIndex(where: {$0.Characteristic_UUID == CBUUID(string: "4676")})
            let characteristic = ble.Peripheral_characteristics[characteristicIndex!].Characteristic
            let data : UInt8 = Scanner_longpressed ? 1 : 0
            ble.writeValue(value: Data([data]), characteristic: characteristic, peripheral: peripheral)
//            longpressedChanged = false
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
