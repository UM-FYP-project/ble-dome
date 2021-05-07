//
//  ReaderInventory.swift
//  ble dome
//
//  Created by UM on 07/05/2021.
//

import SwiftUI
import Combine

struct ReaderInventory: View{
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var readeract : readerAct
    var geometry : GeometryProxy
    @Binding var isInventory : Bool
    @Binding var Realtime_Inventory_Toggle : Bool
    @State var Inventory_button_str = "Start"
    @State var Buffer_button_str = "Read"
    @State var Buffer_button_Bool = false
    @State var ErrorString = "nil"
    @State var ErrorStr : String = ""
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                Toggle(isOn: $Realtime_Inventory_Toggle) {
                    Text("Realtime Inventory")
                        .font(.headline)
                }
                .disabled(isInventory)
                Divider()
                HStack{
                    Text("Inventory Speed:")
                        .font(.headline)
                    Divider()
                        .frame(height: 30)
                    //                        Text("\(readeract.inventorySpeed[readeract.inventorySpeed_Selected])")
                    //                            .font(.headline)
                    //                            .frame(width: 60, height: 30)
                    //                            .background(Color.gray.opacity(0.5))
                    //                            .cornerRadius(10)
                    //                            .onTapGesture {
                    //                                readeract.inventorySpeed_picker = true
                    //                            }
                    Button(action: {self.readeract.inventorySpeed -= 1}) {
                        Image(systemName: "minus")
                    }
                    .frame(width: 30)
                    .disabled(readeract.inventorySpeed < 1)
                    TextField("", value: $readeract.inventorySpeed, formatter: NumberFormatter())
                        .onReceive(Just(readeract.inventorySpeed), perform: {_ in
                            if readeract.inventorySpeed > 255 {
                                self.readeract.inventorySpeed = 255
                            }
                            else if readeract.inventorySpeed < 0 {
                                self.readeract.inventorySpeed = 0
                            }
                        })
                        .multilineTextAlignment(.center)
                        .keyboardType(.numbersAndPunctuation)
                        .frame(maxWidth: 50)
                    Button(action: {self.readeract.inventorySpeed += 1}) {

                        Image(systemName: "plus")
                    }
                    .disabled(readeract.inventorySpeed > 255)
                    .frame(width: 30)
                    Spacer()
                    Button(action: {
                        if !(ble.peripherals.filter({$0.State == 2}).count < 1){
                            isInventory.toggle()
                        }
                        else {
                            isInventory = false
                        }
                        if !Realtime_Inventory_Toggle{
                            //                                EnableInventory(cmd: reader.cmd_inventory(inventory_speed: UInt8(readeract.inventorySpeed[readeract.inventorySpeed_Selected])))
                            EnableInventory(cmd: reader.cmd_inventory(inventory_speed: UInt8(readeract.inventorySpeed)))
                        }
                        else {
                            //                                EnableInventory(cmd: reader.cmd_real_time_inventory(inventory_speed: UInt8(readeract.inventorySpeed[readeract.inventorySpeed_Selected])))
                            EnableInventory(cmd: reader.cmd_real_time_inventory(inventory_speed: UInt8(readeract.inventorySpeed)))
                        }
                        Inventory_button_str = (isInventory ? "Stop" : "Start")
                    }) {
                        Text(Inventory_button_str)
                            .bold()
                    }
                }
                .frame(height: 30, alignment: .center)
                Divider()
                HStack{
                    Text("Inventoried:")
                        .font(.headline)
                    Spacer()
                    if ErrorString != "nil" {
                        Text("Error: \(ErrorString)")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    else {
                        Text("\(reader.tagsCount) Tags")
                            .font(.headline)
                    }
                }
                .frame(height: 30, alignment: .center)
                Divider()
                HStack{
                    Text("Buffer:")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        get_Buffer()
                        
                    }) {
                        Text(Buffer_button_str)
                            .bold()
                    }
                    .disabled(Realtime_Inventory_Toggle || reader.tagsCount <= 0 || Buffer_button_Bool || isInventory)
                    Divider()
                    Button(action: {
                        let cmd : [UInt8] = reader.cmd_clear_inventory_buffer()
                        ble.cmd2reader(cmd: cmd)
                        reader.Btye_Recorder(defined: 1, byte: cmd)
                        reader.tagsCount = 0
                    }) {
                        Text("Clear")
                            .bold()
                    }
                }
                .frame(height: 30, alignment: .center)
                Divider()
                Bufferlist
                Spacer()
            }
            .frame(width: geometry.size.width - 20)
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        .onAppear(perform: {
            Inventory_button_str = (isInventory ? "Stop" : "Start")
        })
    }
    
    var Bufferlist: some View {
        VStack(alignment: .center){
            Text("Buffer List")
                .font(.headline)
            Divider()
            List {
                if ErrorStr != ""{
                    Text(ErrorStr)
                        .foregroundColor(.red)
                }
                if !reader.Tags.isEmpty {
                    ForEach(0..<reader.Tags.count, id: \.self){ index in
                        let tag = reader.Tags[index]
                        let PCstr = Data(tag.PC).hexEncodedString()
                        let EPCstr = Data(tag.EPC).hexEncodedString()
                        let CRCstr = Data(tag.CRC).hexEncodedString()
                        let NavTag : NavTag? = reader.TagtoNav(Tag:tag, TagData: nil)
                        HStack{
                            Text("\(tag.id + 1)")
                                .frame(width: 15)
                            Divider()
                            VStack(alignment: .leading){
                                Text("\(EPCstr)")
                                    .font(.headline)
                                HStack{
                                    Text("PC:\(PCstr)")
                                    Text("CRC:\(CRCstr)")
                                    Text("Len:\(Int(tag.EPClen))")
                                    Text("RSSI:\(tag.RSSI)")
                                }
                                if NavTag != nil {
                                    Text("Floor:\(NavTag!.floor)/F\t\tInfor:\(NavTag!.Infor)\(NavTag!.Seq) \(NavTag!.Step)")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .frame(width: geometry.size.width, height: geometry.size.height / 2 + 60, alignment: .center)
        }
    }
    
    func EnableInventory(cmd: [UInt8]){
        var flag : Bool = false
        var counter : Int = 0
        var LoopCount : Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true){ timer in
            if !flag || counter > 5{
                counter = 0
                ble.cmd2reader(cmd: cmd)
                reader.Btye_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            while (flag && LoopCount < 50) {
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    reader.Btye_Recorder(defined: 2, byte: feedback)
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE{
                        if feedback[3] == 0x80 && cmd[3] == 0x80{
                            reader.tagsCount = reader.feedback_Inventory(feedback: feedback).0
                            ErrorString = reader.feedback_Inventory(feedback: feedback).1
                            flag = false
                        }
                        if feedback[3] == 0x89 && cmd[3] == 0x89{
                            ErrorString = reader.feedback2Tags(feedback: feedback)
                            flag = false
                        }
                    }
                    ble.ValueUpated_2A68 = false
                }
                LoopCount += 1
            }
            counter += 1
            LoopCount = 0
            if !isInventory || ble.peripherals.filter({$0.State == 2}).count < 1 {
                isInventory = false
                timer.invalidate()
            }
        }
    }
    
    func get_Buffer(){
        var flag : Bool = false
        var completed : Bool = false
        var counter : Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){ timer in
            Buffer_button_str = "Reading"
            Buffer_button_Bool = true
            let cmd : [UInt8] = reader.cmd_get_inventory_buffer()
            if !flag{
                ble.cmd2reader(cmd: cmd)
                reader.Btye_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            if ble.ValueUpated_2A68{
                let feedback = ble.reader2BLE()
                if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x90{
                    ErrorStr = reader.feedback2Tags(feedback: feedback)
                    completed = true
                }
                ble.ValueUpated_2A68 = false
            }
            counter += 1
            if counter > 20 || completed {
                Buffer_button_str = "Read"
                Buffer_button_Bool = false
                timer.invalidate()
            }
        }
    }
}
