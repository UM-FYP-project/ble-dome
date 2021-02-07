//
//  PeripheralDetail.swift
//  ble dome
//
//  Created by UM on 05/02/2021.
//

import SwiftUI

struct PeripheralDetail: View {
    @EnvironmentObject var ble:BLE
    var peripheral : Peripheral
    var body: some View {
        List {
            VStack(alignment: .leading){
                Text("Advertising Service")
                    .bold()
                Text("\(peripheral.Service)")
            }
            ForEach(0..<ble.Peripheral_Services.count, id:\.self){ (index) in
                let service = ble.Peripheral_Services[index]
                if peripheral.name == service.name{
                    Section(header:
                                VStack(alignment: .leading){
                                    Text("Service")
                                        .bold()
                                    Text("\(service.Services_UUID)")
                                }
                    ){
                        CharacteristicDetail(peripheral: peripheral, service: service)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct CharacteristicDetail: View {
    @EnvironmentObject var ble:BLE
    @State var WrtieValueBox: Bool = false
    var peripheral : Peripheral
    var service : Peripheral_Service
    var WriteValue : String = ""
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
                        if characteristic.iswritable{
                            Text("Value Sent: \(characteristic.WritevalueStr)")
                        }
                        Text("\n")
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
    @State var WriteValueBool : Bool = false
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
                    NavigationLink(
                        destination: WriteValuetoChar(peripheral: peripheral, characteristic: characteristic),
                        isActive: $WriteValueBool,
                        label: {
                            EmptyView()
                        })
                    Text("Write")
                        .foregroundColor(.blue)
                        .onTapGesture(perform: {
                            WriteValueBool = true
                        })
                }
            }
        }
        .onAppear(perform: {
            WriteValueBool = false
        })
    }
}

struct WriteValuetoChar: View {
    @EnvironmentObject var ble:BLE
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var WrtieValueBox : Bool = false
    @State var WriteValueStr : String = ""
    var peripheral : Peripheral
    var characteristic : Peripheral_characteristic
    var body: some View {
        VStack(alignment: .center) {
            Text("Write Value to \(characteristic.Characteristic_UUID)")
                .bold()
                .font(.title)
            Text("Value wrote: \(WriteValueStr)")
            TextField("Value in Byte without 0x", text: $WriteValueStr)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: UIScreen.main.bounds.width - 40)
            HStack{
                Spacer()
                if characteristic.properties.contains("Write"){
                    Button(action: {
                        let WriteValue : Data = WriteValueStr.hexaData
                        ble.writeValue(value: WriteValue, characteristic: characteristic.Characteristic, peripheral: peripheral.Peripheral)
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Write")
                    }
                    Spacer()
                }
                if characteristic.properties.contains("WriteWithoutResponse"){
                    Button(action: {
                        let WriteValue : Data = WriteValueStr.hexaData
                        ble.writeValue_withoutResponse(value: WriteValue, characteristic: characteristic.Characteristic, peripheral: peripheral.Peripheral)
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Write")
                    }
                    Spacer()
                }
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("close")
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

