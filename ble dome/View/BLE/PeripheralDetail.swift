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
    var peripheral : Peripheral
    var body: some View {
//        List {
            ForEach(0..<ble.Peripheral_Services.count, id:\.self){ (index) in
                let service = ble.Peripheral_Services[index]
                if peripheral.name == service.name{
                    VStack(alignment: .leading){
                        Text("Service")
                            .bold()
                        Text("\(service.Services_UUID)")
                    }
                    .padding()
                    .background(Color.gray)
                    CharacteristicDetail(peripheral: peripheral, service: service)
                }
            }
//        }
    }
}

struct CharacteristicDetail: View {
    @EnvironmentObject var ble:BLE
    @State var WrtieValueBox: Bool = false
    var peripheral : Peripheral
    var service : Peripheral_Service
    var body: some View {
        ForEach(0..<ble.Peripheral_characteristics.count, id:\.self){ (index) in
            let characteristic = ble.Peripheral_characteristics[index]
            if service.Services_UUID == characteristic.Services_UUID && peripheral.name == characteristic.name{
                HStack{
                    VStack(alignment: .leading){
                        Text("Characteristic")
                            .bold()
                        Text("\(characteristic.Characteristic_UUID)")
                        Text(characteristic.properties)
                        Text("Value: \(characteristic.valueStr)")
                    }
                    Spacer()
                    CharacteristicProperties(peripheral: peripheral, service: service, characteristic: characteristic)
                }
            }
        }
    }
}

struct CharacteristicProperties: View {
    @EnvironmentObject var ble:BLE
    @State var WrtieValueBox: Bool = false
    @State private var WriteValue = ""
    var peripheral : Peripheral
    var service : Peripheral_Service
    var characteristic : Peripheral_characteristic
    var body: some View {
        VStack(alignment: .trailing){
            if characteristic.isNotify{
                Text("Notifying")
            }
            Spacer()
            HStack(alignment: .bottom){
                if characteristic.properties.contains("Read"){
                    Button(action: {
                        ble.readValue(characteristic: characteristic.Characteristic, peripheral: peripheral.Peripheral)
                    }) {
                        Text("Read")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                }
                if characteristic.iswritable{
                    Button(action: {
                        WrtieValueBox = true
                    }) {
                        Text("Write")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
//                    .alert(isPresented: $WrtieValueBox) {
//                        Alert(
//                            title: Text("Write Value to \(characteristics.Characteristic_UUID)"),
//                            message: TextField("Tap to Field Value", text: $WriteValue),
//                            primaryButton: <#T##Alert.Button#>,
//                            secondaryButton: <#T##Alert.Button#>
//                        )
//                    }
                }
            }
        }
    }
}

//struct PeripheralDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PeripheralDetail()
//    }
//}
