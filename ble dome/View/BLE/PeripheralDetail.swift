//
//  PeripheralDetail.swift
//  ble dome
//
//  Created by UM on 05/02/2021.
//

import SwiftUI

struct PeripheralDetail: View {
    @EnvironmentObject var ble:BLE
    var body: some View {
        VStack{
            Text("Peripheral Services")
                .font(.largeTitle)
                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
            ForEach(ble.Peripheral_Services.indices){ (index) in
                VStack{
                    Text("Service")
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    Text("UUID: \(ble.Peripheral_Services[index])")
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                }
                .frame(width:UIScreen.main.bounds.width , alignment:.leading)
                List(ble.Peripheral_characteristics){ characteristic in
                    characteristicRow(characteristic: characteristic)
                }
            }
        }
    }
}

struct characteristicRow: View {
    @EnvironmentObject var ble:BLE
    var characteristic:Peripheral_characteristic
    var body: some View {
        VStack{
            if characteristic.Characteristic_UUID != nil{
                Text("\(characteristic.Characteristic_UUID!)")
                HStack{
                    Text("Characteristic ")
                    Text(characteristic.properties)
                }
                HStack{
                    Text("Value: ")
                    Text("\(characteristic.valueStr ?? "")")
                }
            }
            if characteristic.iswritable {
                TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

//struct PeripheralDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PeripheralDetail(, characteristic: <#Peripheral_characteristic#>)
//    }
//}
