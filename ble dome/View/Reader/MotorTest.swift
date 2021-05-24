//
//  MotorTest.swift
//  ble dome
//
//  Created by UM on 22/05/2021.
//

import SwiftUI
import Combine
import CoreBluetooth

struct MotorTest: View {
    var geometry : GeometryProxy
    @EnvironmentObject var ble:BLE
    @State var Mode : Int8 = 0
    @State var Counter : Int8 = 0
    @State var Send = false
    var body: some View {
        VStack{
            Text("MotorTest")
                .bold()
                .font(.headline)
            Divider()
            HStack{
                Text("Mode Select")
                    .bold()
                Spacer()
                Button(action: {self.Mode -= 1}) {
                    Image(systemName: "minus")
                }
                .padding()
                .frame(width: 30, height: 30)
                .disabled(Mode < 1)
                TextField("Select Vibration Mode", value: $Mode, formatter: NumberFormatter())
                    .onReceive(Just(Mode), perform: {_ in
                        if Mode > 10 {
                            self.Mode = 10
                        }
                        else if Mode < 0 {
                            self.Mode = 0
                        }
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .frame(maxWidth: 50)
                Button(action: {self.Mode += 1}) {
                    Image(systemName: "plus")
                }
                .disabled(Mode > 10)
                .padding()
                .frame(width: 30, height: 30)
                
            }
            .frame(height: 30)
            Divider()
            HStack{
                Text("Times")
                    .bold()
                Spacer()
                Button(action: {self.Counter -= 1}) {
                    Image(systemName: "minus")
                }
                .padding()
                .frame(width: 30, height: 30)
                .disabled(Counter < 1)
                TextField("Select Vibration Time", value: $Counter, formatter: NumberFormatter())
                    .onReceive(Just(Counter), perform: {_ in
                        if Counter > 10 {
                            self.Counter = 10
                        }
                        else if Counter < 0 {
                            self.Counter = 0
                        }
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .frame(maxWidth: 50)
                Button(action: {self.Counter += 1}) {
                    Image(systemName: "plus")
                }
                .disabled(Counter > 10)
                .padding()
                .frame(width: 30, height: 30)
                
            }
            .frame(height: 30)
            Divider()
            Button(action: {
                let Serivce : CBUUID = CBUUID(string: "2A68")
                let Char : CBUUID = CBUUID(string: "4D6F")
                let sendByte : UInt8 = UInt8(Counter * 10 + Mode)
                Send.toggle()
                if Send{
                    ble.BLEWrtieValue(Serivce: Serivce, Characteristic: Char, ByteData: [sendByte])
                }
                else{
                    ble.BLEWrtieValue(Serivce: Serivce, Characteristic: Char, ByteData: [00])
                }
            }) {
                Text("\(Send ? "Stop Vibration" : "Start Vibration")")
            }
            Spacer()
        }
        .frame(width: geometry.size.width - 20)
    }

}

//struct MotorTest_Previews: PreviewProvider {
//    static var previews: some View {
////        MotorTest(geometry)
//    }
//}
