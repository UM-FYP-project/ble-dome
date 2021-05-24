//
//  ContentView.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI
import CoreBluetooth

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

struct ContentView: View {
    @ObservedObject var ble = BLE()
    @ObservedObject var reader = Reader()
    @ObservedObject var readerconfig = ReaderConfig()
    @ObservedObject var location = LocationManager()
    @ObservedObject var path = PathFinding()
    @ObservedObject var nav = navValue()
    @State var isScanner_trigged = false
    @State var notConnectedAlert_trigged = true
    @State var Conncetedperipheral_index = 0
    @State var ReaderSet : Bool = false
    @State var Latitude : Float = 0
    @State var Longitude : Float = 0
    var body: some View {
        GeometryReader{ geometry in
            NavigationView {
                VStack{
                    Spacer()
                    NavMain(geometry: geometry)
                        .disabled(ble.isBluetoothON && isScanner_trigged)
                        .disabled(ble.peripherals.filter({$0.State == 2}).count < 1)
                        .environmentObject(ble)
                        .environmentObject(reader)
                        .environmentObject(path)
                        .environmentObject(nav)
                    Spacer()
                    HomeTab
                        .frame(width: geometry.size.width, height: geometry.size.height/9.2)
//                    VStack{
//                        Divider()
//                        HStack(){
//                            VStack{
//                                ReaderSettingLink
//                                Image(systemName: "house")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 25, height: 20)
//                                    .padding(.top, 10)
//                                    .foregroundColor(ble.peripherals.filter({$0.State == 2}).count < 1 ? Color(UIColor.lightGray) : /*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
//                                Text("Home")
//                                    .font(.system(size: 12))
//                                    .foregroundColor(ble.peripherals.filter({$0.State == 2}).count < 1 ? Color(UIColor.lightGray) : /*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
//
//                                Spacer()
//                            }
//                            .accessibility(label: Text("Home Tab"))
//                            .accessibilityElement(children: .combine)
//                            .onLongPressGesture(minimumDuration: 2) {
//                                if let index = ble.peripherals.firstIndex(where: {$0.State == 2}){
//                                    ReaderSet = true
//                                    Conncetedperipheral_index = index
//                                }
//                            }
//                            .padding(.bottom, 10)
//                        }
//                    }
//                    .background(Color("TabBarColor"))
//                    .frame(width: geometry.size.width, height: geometry.size.height/9.2)
                }
                .accessibility(hidden: ble.isBluetoothON && isScanner_trigged  ? true : false)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle("Main", displayMode: .inline)
                .background(NavigationConfigurator { nc in
                    if ble.peripherals.filter({$0.State == 2}).count > 0{
                        nc.navigationBar.barTintColor = UIColor.systemTeal
                        nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
                    }
                    else{
                        nc.navigationBar.barTintColor = UIColor(Color("TabBarColor"))
                        nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.label]
                    }
                })
                .navigationBarItems(trailing:
                                        Button(action: {isScanner_trigged = true}) {
                                            Text("Scanner")
                                        }
                                        .accessibility(hidden: ble.isBluetoothON && isScanner_trigged  ? true : false)
                                        .accessibility(hint: Text("Tap to Pop up Bluetooth Scanner"))
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
                    title: Text("Please Connect Device"),
                    message: Text("Scanner will Pop-up"),
                    dismissButton: .default(Text("OK"), action: {isScanner_trigged = true})
                )
            }
            .disabled(ble.isBluetoothON && isScanner_trigged || nav.RoomPicker_Enable)
            .overlay(ble.isBluetoothON && isScanner_trigged || nav.RoomPicker_Enable  ? Color.black.opacity(0.3).ignoresSafeArea() : nil)
            if ble.isBluetoothON && isScanner_trigged{
                BLEScanner_Alert(Enable: $isScanner_trigged, geometry: geometry)
                    .accessibility(hint: Text("Select Device to Connect"))
                    .environmentObject(ble)
                    .accessibilitySortPriority(1)
            }
            if nav.RoomPicker_Enable {
                RoomPicker(geometry: geometry, geoPos: nav.geoPos!, CurrentLocation: nav.CurrentLocation!, Enable: $nav.RoomPicker_Enable, RoomsList: nav.RoomsList, AlertStr: $nav.AlertStr, AlertState: $nav.AlertState)
                    .environmentObject(path)
                    .environmentObject(nav)
            }
        }
    }
    
    var HomeTab: some View{
        VStack{
            Divider()
            HStack(){
                VStack{
                    ReaderSettingLink
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
                .accessibility(label: Text("Home Tab"))
                .accessibilityElement(children: .combine)
                .onLongPressGesture(minimumDuration: 2) {
                    if let index = ble.peripherals.firstIndex(where: {$0.State == 2}){
                        ReaderSet = true
                        Conncetedperipheral_index = index
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .background(Color("TabBarColor"))
    }
    
    var ReaderSettingLink: some View {
        VStack{
            if !ble.peripherals.isEmpty && !(ble.peripherals.filter({$0.State == 2}).count < 1){
                NavigationLink(
                    destination:
                        DetailTabView(peripheral: ble.peripherals[Conncetedperipheral_index])
                        .environmentObject(ble)
                        .environmentObject(reader)
                        .environmentObject(readerconfig)
                        .environmentObject(location)
                        .environmentObject(path)
                        .disabled(ble.isBluetoothON && isScanner_trigged)
                        .overlay(ble.isBluetoothON && isScanner_trigged  ? Color.black.opacity(0.3).ignoresSafeArea() : nil)
                        .navigationBarItems(trailing:
                                                Button(action: {isScanner_trigged = true}) {
                                                    Text("Scanner")
                                                }
                                                .padding()
                                                .disabled(!ble.isBluetoothON)
                        ),
                    isActive: $ReaderSet,
                    label: {
                        EmptyView()
                    })
            }
        }
    }
    
    func BLEConnect(){
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true){_ in
            if !ble.isInit{
                ble.initBLE()
            }
            if ble.peripherals.filter({$0.State == 2}).count > 0 {
                notConnectedAlert_trigged = false
            }
            if (ble.peripherals.filter({$0.State == 2}).count < 1) && !isScanner_trigged{
                ble.scan_devices()
                readerconfig.TagsData.removeAll()
                readerconfig.Tags.removeAll()
                readerconfig.tagsCount = 0
                BytesRecord.removeAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let previousConntection : String? = rememberConntion.object(forKey: "PreviousName") as? String ?? nil
                    if previousConntection != nil && ble.peripherals.contains(where: {$0.name == previousConntection}){
                        if let index = ble.peripherals.firstIndex(where: {$0.name == previousConntection}){
                            ble.connect(peripheral: ble.peripherals[index].Peripheral)
                            ble.stopscan_device()
                        }
                    }
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if !isScanner_trigged{
                                ble.stopscan_device()
                                notConnectedAlert_trigged = true
                            }
                        }
                    }
                }
            }
        }
    }
    func isNavorSet(){
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true){_ in
            let Serivce : CBUUID = CBUUID(string: "2A68")
            let Char : CBUUID = CBUUID(string: "4676")
            readerconfig.isNavorSet = path.isNaving ? 2 : ReaderSet ? 1 : 0
            if readerconfig.isNavorSetUpdate {
                ble.BLEWrtieValue(Serivce: Serivce, Characteristic: Char, ByteData: [readerconfig.isNavorSet])
                readerconfig.isNavorSetUpdate = false
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
