//
//  PeripheralDetail.swift
//  ble dome
//
//  Created by UM on 05/02/2021.
//

import SwiftUI

struct PeripheralDetail: View {
    @EnvironmentObject var ble:BLE
    @State var WrtieValue: Bool = false
    var body: some View {
        GeometryReader{ geometry in
            NavigationView {
                List {
                    ForEach(0..<ble.Peripheral_Services.count){ (Index) in
                        VStack(alignment: .leading){
                            Text("Service")
                                .bold()
                            Text("\(ble.Peripheral_Services[Index])")
                        }
                        .listStyle(InsetGroupedListStyle())
                        ForEach(0..<ble.Peripheral_characteristics.count){ (index) in
                            let characteristic = ble.Peripheral_characteristics[index]
                            if ble.Peripheral_Services[Index] == characteristic.Services_UUID{
                                HStack{
                                    VStack(alignment: .leading){
                                        Text("Characteristic")
                                            .bold()
                                        Text("\(characteristic.Characteristic_UUID)")
                                        Text(characteristic.properties)
                                        Text("Value: \(characteristic.valueStr)")
                                    }
                                    Spacer()
                                    VStack{
                                        if characteristic.isNotify{
                                            Text("Notifying")
                                                .multilineTextAlignment(.trailing)
                                        }
                                        Spacer()
                                        HStack{
                                            if characteristic.properties.contains("Read"){
                                                Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                                                    Text("Read")
                                                        .multilineTextAlignment(.trailing)
                                                }
                                            }
                                            if characteristic.iswritable{
                                                Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                                                    Text("Write")
                                                        .multilineTextAlignment(.trailing)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle(Text("Peripheral Detail"))
            }
        }
    }
}

//struct PeripheralDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PeripheralDetail()
//    }
//}
