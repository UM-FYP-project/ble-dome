//
//  ReaderInventory.swift
//  ble dome
//
//  Created by UM on 07/05/2021.
//

import SwiftUI
import Combine
import Introspect

struct ReaderInventory: View{
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var readerconfig : ReaderConfig
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
                    //                        Text("\(readerconfig.inventorySpeed[readerconfig.inventorySpeed_Selected])")
                    //                            .font(.headline)
                    //                            .frame(width: 60, height: 30)
                    //                            .background(Color.gray.opacity(0.5))
                    //                            .cornerRadius(10)
                    //                            .onTapGesture {
                    //                                readerconfig.inventorySpeed_picker = true
                    //                            }
                    Button(action: {self.readerconfig.inventorySpeed -= 1}) {
                        Image(systemName: "minus")
                    }
                    .padding()
                    .frame(width: 30, height: 30)
                    .disabled(readerconfig.inventorySpeed < 1)
                    TextField("", value: $readerconfig.inventorySpeed, formatter: NumberFormatter())
                        .onReceive(Just(readerconfig.inventorySpeed), perform: {_ in
                            if readerconfig.inventorySpeed > 255 {
                                self.readerconfig.inventorySpeed = 255
                            }
                            else if readerconfig.inventorySpeed < 0 {
                                self.readerconfig.inventorySpeed = 0
                            }
                        })
                        .multilineTextAlignment(.center)
                        .keyboardType(.numbersAndPunctuation)
                        .frame(maxWidth: 50)
                    Button(action: {self.readerconfig.inventorySpeed += 1}) {
                        Image(systemName: "plus")
                    }
                    .disabled(readerconfig.inventorySpeed > 255)
                    .padding()
                    .frame(width: 30, height: 30)
                    Spacer()
                    Button(action: {
                        if !(ble.peripherals.filter({$0.State == 2}).count < 1){
                            isInventory.toggle()
                        }
                        else {
                            isInventory = false
                        }
                        if !Realtime_Inventory_Toggle{
                            //                                EnableInventory(cmd: reader.cmd_inventory(inventory_speed: UInt8(readerconfig.inventorySpeed[readerconfig.inventorySpeed_Selected])))
                            EnableInventory(cmd: reader.cmd_inventory(inventory_speed: UInt8(readerconfig.inventorySpeed)))
                        }
                        else {
                            //                                EnableInventory(cmd: reader.cmd_real_time_inventory(inventory_speed: UInt8(readerconfig.inventorySpeed[readerconfig.inventorySpeed_Selected])))
                            EnableInventory(cmd: reader.cmd_real_time_inventory(inventory_speed: UInt8(readerconfig.inventorySpeed)))
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
                        Text("\(readerconfig.tagsCount) Tags")
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
                    .disabled(Realtime_Inventory_Toggle || readerconfig.tagsCount <= 0 || Buffer_button_Bool || isInventory)
                    Divider()
                    Button(action: {
                        let cmd : [UInt8] = reader.cmd_clear_inventory_buffer()
                        ble.cmd2reader(cmd: cmd)
                        reader.Byte_Recorder(defined: 1, byte: cmd)
                        readerconfig.tagsCount = 0
                        readerconfig.Tags.removeAll()
                        readerconfig.TagsData.removeAll()
                        readerconfig.EPCstr.removeAll()
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
                if !readerconfig.Tags.isEmpty {
                    ForEach(0..<readerconfig.Tags.count, id: \.self){ index in
                        let tag = readerconfig.Tags[index]
                        let PCstr = Data(tag.PC).hexEncodedString()
                        let EPCstr = tag.EPCStr
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
                                    Text("Floor: \(NavTag!.Floor)/F\t\tHazard: \(NavTag!.HazardStr)\nInformation: \((NavTag!.InformationStr))")
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
                reader.Byte_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            while (flag && LoopCount < 50) {
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    if !feedback.isEmpty{
                        if feedback[0] == 0xA0 && feedback[2] == 0xFE{
                            reader.Byte_Recorder(defined: 2, byte: feedback)
                            if feedback[3] == 0x80 && cmd[3] == 0x80{
                                let funcFeedback = reader.feedback_Inventory(feedback: feedback)
                                readerconfig.tagsCount = funcFeedback.0
                                ErrorString = funcFeedback.1
                                flag = false
                            }
                            if feedback[3] == 0x89 && cmd[3] == 0x89{
                                let funcfeeback = reader.feedback2Tags(feedback: feedback, Tags : readerconfig.Tags, TagsData : readerconfig.TagsData)
                                ErrorString = funcfeeback.0
                                readerconfig.Tags = funcfeeback.1
                                if !readerconfig.Tags.isEmpty{
                                    for tag in readerconfig.Tags{
                                        readerconfig.EPCstr.append(tag.EPCStr)
                                    }
                                }
                                flag = false
                            }
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
                reader.Byte_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            if ble.ValueUpated_2A68{
                let feedback = ble.reader2BLE()
                if !feedback.isEmpty{
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x90{
                        let funcfeeback = reader.feedback2Tags(feedback: feedback, Tags : readerconfig.Tags, TagsData : readerconfig.TagsData)
                        ErrorString = funcfeeback.0
                        readerconfig.Tags = funcfeeback.1
                        if !readerconfig.Tags.isEmpty{
                            for tag in readerconfig.Tags{
                                readerconfig.EPCstr.append(tag.EPCStr)
                            }
                        }
                        completed = true
                    }
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
