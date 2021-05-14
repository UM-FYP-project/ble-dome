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
    @ObservedObject var path = PathFinding()
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
                    VStack{
                        Spacer()
                        NavMain(geometry: geometry)
                            .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                            .environmentObject(ble)
                            .environmentObject(reader)
                            .environmentObject(path)
                        Spacer()
                        VStack{
                            Divider()
                            HStack(){
                                VStack{
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
                                    Image(systemName: "house")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 20)
                                        .padding(.top, 10)
                                        .foregroundColor(ble.peripherals.filter({$0.State == 2}).count < 1 ? Color(UIColor.lightGray) : /*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    Text("Home")
                                        .font(.system(size: 12))
                                        .foregroundColor(ble.peripherals.filter({$0.State == 2}).count < 1 ? Color(UIColor.lightGray) : /*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    Spacer()
                                }
                                .onLongPressGesture(minimumDuration: 2) {
                                    if let index = ble.peripherals.firstIndex(where: {$0.State == 2}){
                                        Scanner_longpressed = true
                                        Conncetedperipheral_index = index
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                        }
                        .background(Color("TabBarColor"))
                        .frame(width: geometry.size.width, height: geometry.size.height/9.2)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .navigationBarTitle("Main", displayMode: .inline)
                    .navigationBarItems(trailing:
                                            Button(action: {isScanner_trigged = true}) {
                                                Text("Scanner")
                                            }
                                            .padding()
                                            .disabled(!ble.isBluetoothON)
                    )
                }
                .onAppear(perform: {
                    BLEConnect()
                    isNavorSet()
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
    
    func BLEConnect(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){_ in
            if !ble.isInit{
                ble.initBLE()
            }
            if (ble.peripherals.filter({$0.State == 2}).count < 1) && !isScanner_trigged{
                reader.TagsData.removeAll()
                reader.Tags.removeAll()
                reader.tagsCount = 0
                reader.BytesRecord.removeAll()
                let previousConntection : String? = rememberConntion.object(forKey: "PreviousName") as? String ?? nil
                if previousConntection != nil {
                    print("Conntect with \(previousConntection!)")
                    ble.scan_devices()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let index = ble.peripherals.firstIndex(where: {$0.name == previousConntection!}){
                            ble.connect(peripheral: ble.peripherals[index].Peripheral)
                        }
                        else{
                            ble.stopscan_device()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if !isScanner_trigged{
                                    notConnectedAlert_trigged = true
                                }
                            }
                        }
                    }
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if !isScanner_trigged{
                            notConnectedAlert_trigged = true
                        }
                    }
                }
            }
            else{
                notConnectedAlert_trigged = false
            }
        }

    }
    
    func isNavorSet(){
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true){_ in
            let Serivce : CBUUID = CBUUID(string: "2A68")
            let Char : CBUUID = CBUUID(string: "4676")
            let data : UInt8 = Scanner_longpressed ? 1 : 0
            if !ble.peripherals.isEmpty{
                if !ble.Peripheral_characteristics.isEmpty{
                    if let CharIndex = ble.Peripheral_characteristics.firstIndex(where: {$0.Services_UUID == Serivce && $0.Characteristic_UUID == Char}){
                        if let PeripheralIndex = ble.peripherals.firstIndex(where: {$0.name == ble.Peripheral_characteristics[CharIndex].name && $0.State == 2}){
                            ble.writeValue(value: Data([data]), characteristic: ble.Peripheral_characteristics[CharIndex].Characteristic, peripheral: ble.peripherals[PeripheralIndex].Peripheral)
                        }
                    }
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
