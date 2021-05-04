//
//  ReaderTab.swift
//  ble dome
//
//  Created by UM on 08/02/2021.
//

import SwiftUI
import Combine

struct ReaderTab: View {
    @State var menuButton :Bool = false
    @State var Reader_disable : Bool = false
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var readeract : readerAct
    @EnvironmentObject var location : LocationManager
    var geometry : GeometryProxy
    @State var Selected = 0
//    @State var isInventory = false // Reader Inverntorying or not
    // data Write
//    @State var MatchState : Int = 0
    var body: some View {
            ZStack() {
                VStack{
                    Picker(selection: $Selected, label: Text("Reader Picker")) {
                        Text("Setting").tag(0)
                        Text("Inventory").tag(1)
                        Text("Read").tag(2)
                        Text("Write").tag(3)
                        Text("Monitor").tag(4)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: geometry.size.width - 20)
                    ScrollView {
                        if Selected == 0{
                            ReaderSetting(geometry: geometry)
                                .environmentObject(reader)
                                .environmentObject(readeract)
                            
                        }
                        else if Selected == 1{
                            ReaderInventory(geometry: geometry, isInventory: $readeract.isInventory, Realtime_Inventory_Toggle: $readeract.RealtimeInventory_Toggle)
                                .environmentObject(reader)
                                .environmentObject(readeract)

                        }
                        else if Selected == 2{
                            ReadTags_data(geometry: geometry)
                                .environmentObject(reader)
                                .environmentObject(readeract)
                        }
                        else if Selected == 3{
                            Reader_WriteData(geometry: geometry)
                                .environmentObject(reader)
                                .environmentObject(readeract)
                                .disabled(reader.Tags.isEmpty)
                        }
                        else if Selected == 4{
                            Record_Monitor(geometry: geometry)
                                .environmentObject(reader)
                        }
                    }
                }
            }
    }
}

struct ReaderSetting: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var readeract : readerAct
    var geometry : GeometryProxy
    @State var Outpower_feedback : Int?
    @State var ErrorStr = [String]()
    var body: some View {
            ZStack{
                VStack(alignment: .center){
                    HStack{
                        Text("Reset Reader")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            let cmd = reader.cmd_reset()
                            cmdtransitor(cmd: cmd)
                        }) {
                            Text("Reset")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                    }
                    .frame(width: geometry.size.width - 20)
                    Divider()
                    HStack{
                        Text("Set Baudrate")
                            .font(.headline)
                        Spacer()
                        Text("\(readeract.BaudrateCmdinStr[readeract.SelectedBaudrate])")
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                            .onTapGesture {
                                readeract.SelectedBaudrate_picker = true
                            }
                        Button(action: {
                            let cmd : [UInt8] = reader.cmd_set_baudrate(baudrate_para: readeract.BaudrateCmdinByte[readeract.SelectedBaudrate])
//                            var feedback = [UInt8]()
                            cmdtransitor(cmd: cmd)
//                            ble.cmd2reader(cmd: cmd)
//                            reader.Btye_Recorder(defined: 1, byte: cmd)
                        }) {
                            Text("Set")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                    }
                    .frame(width: geometry.size.width - 20)
                    Divider()
                    HStack{
                        Text("Set Power")
                            .font(.headline)
                            .frame(width: 120, height: 30,alignment: .leading)
                        Spacer()
                        Text("\(readeract.Outpower[readeract.SelectedPower])dBm")
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                            .onTapGesture {
                                readeract.SelectedPower_picker = true
                            }
                        Button(action: {
                            let cmd : [UInt8] = reader.cmd_set_output_power(output_power: readeract.Outpower[readeract.SelectedPower])
                            cmdtransitor(cmd: cmd)
                        }) {
                            Text("Set")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                    }
                    .frame(width: geometry.size.width - 20)
                    Divider()
                    HStack{
                        Text("Get Power")
                            .font(.headline)
                            .frame(width: 120, height: 30,alignment: .leading)
                        Spacer()
                        if Outpower_feedback != nil {
                            Text("\(Outpower_feedback!)dBm")
                                .frame(width: 120, height: 30, alignment: .center)
                                .font(.headline)
                        }
                        else{
                            Text("")
                                .frame(width: 120, height: 30, alignment: .center)
                        }
                        Button(action: {
                            let cmd : [UInt8] = reader.cmd_get_output_power()
                            cmdtransitor(cmd: cmd)
                        }) {
                            Text("Get")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                    }
                    .frame(width: geometry.size.width - 20)
                    Divider()
                    ErrorList
                    Spacer()
                }
//                .frame(width: geometry.size.width - 20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
    
    var ErrorList: some View {
        List{
            if !ErrorStr.isEmpty{
                ForEach (0..<ErrorStr.count, id: \.self){ index in
                    Text(ErrorStr[ErrorStr.count - 1 - index])
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    func cmdtransitor(cmd: [UInt8]){
        var flag : Bool = false
        var readState : Bool = false
        var counter : Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
            if !flag{
                ble.cmd2reader(cmd: cmd)
                reader.Btye_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            if ble.ValueUpated_2A68{
                print("ValueUpated_2A68")
                let feedback = ble.reader2BLE()
                reader.Btye_Recorder(defined: 2, byte: feedback)
                if feedback[0] == 0xA0 && feedback[2] == 0xFE {
                    if feedback[3] == 0x70 || feedback[3] == 0x71 || feedback[3] == 0x76{
                        let Error = reader.reader_error_code(code: feedback[Int(feedback[1])])
                        if ErrorStr.count > 5 {
                            ErrorStr.removeAll()
                        }
                        ErrorStr.append(feedback[3] == 0x70 ? "Reset:" + Error : feedback[3] == 0x71 ? "SetBaudrate:" + Error : "SetPower:" + Error)
                    }
                    else if feedback[3] == 0x77 {
                        Outpower_feedback = reader.feedback_get_output_power(feedback: feedback)
                    }
                    readState = true
                }
                ble.ValueUpated_2A68 = false
            }
            counter += 1
            if counter > 20 || readState{
                timer.invalidate()
            }
        }
    }
}

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
                                Text("-")
                                    .bold()
                                    .font(.headline)
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
                                Text("+")
                                    .bold()
                                    .font(.headline)
                            }
                            .disabled(readeract.inventorySpeed > 255)
                            .frame(width: 30)
                        Spacer()
                        Button(action: {
                            isInventory.toggle()
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
                                    HStack{
                                        Text("Floor:\(NavTag!.floor)/F")
                                        Text("Infor:\(NavTag!.Infor)\(NavTag!.Seq) \(NavTag!.Step)")
                                    }
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
            if !isInventory {
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

struct Record_Monitor: View {
    @EnvironmentObject var reader:Reader
    var geometry : GeometryProxy
    var body: some View {
//        GeometryReader{ geometry in
        ZStack{
            VStack(alignment: .center){
                List{
                    if !reader.BytesRecord.isEmpty {
                        ForEach(0..<reader.BytesRecord.count, id: \.self){ index in
//                            let Index = reader.Byte_Record.count - index
                            let byte_record = reader.BytesRecord[reader.BytesRecord.count - 1 - index]
                            let byte_str = Data(byte_record.Byte).hexEncodedString()
                            VStack(alignment: .leading){
                                Text(byte_record.Time)
                                Text(byte_str)
                                    .foregroundColor(byte_record.Defined == 1 ? .blue : .red)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                Spacer()
            }
        }
        .frame(width: geometry.size.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//        }
    }
}

struct ReadTags_data: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var readeract : readerAct
    var geometry : GeometryProxy
    @State var ErrorStr : String = ""
    @State var list_show = false
    var body: some View {
            ZStack{
                VStack(alignment: .center){
                    HStack{
                        Text("Data Block")
                            .font(.headline)
                        Spacer()
                        Text(readeract.DataCmdinStr[readeract.DataBlock_Selected])
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                            .onTapGesture {
                                readeract.DataBlock_picker = true
                            }
                    }
                    .frame(width: geometry.size.width - 20, height: 30)
                    Divider()
                    HStack{
                        Text("Start Address:")
                            .font(.headline)
                        Spacer()
//                        Text("\(readeract.DataByte[readeract.DataStart_Selected])bit")
//                            .font(.headline)
//                            .frame(width: 60, height: 30)
//                            .background(Color.gray.opacity(0.15))
//                            .cornerRadius(10)
//                            .onTapGesture {
//                                readeract.DataStart_picker = true
//                            }
                        Button(action: {self.readeract.DataStart -= 1}) {
                            Text("-")
                                .bold()
                                .font(.headline)
                        }
                        .frame(width: 30)
                        .disabled(readeract.DataStart < 1)
                        TextField("", value: $readeract.DataStart, formatter: NumberFormatter())
                            .onReceive(Just(readeract.DataStart), perform: {_ in
                                if readeract.DataStart > 255 {
                                    self.readeract.DataStart = 255
                                }
                                else if readeract.DataStart < 0 {
                                    self.readeract.DataStart = 0
                                }
                            })
                            .multilineTextAlignment(.center)
                            .keyboardType(.numbersAndPunctuation)
                            .frame(maxWidth: 50)
                        Button(action: {self.readeract.DataStart += 1}) {
                            Text("+")
                                .bold()
                                .font(.headline)
                        }
                        .disabled(readeract.DataStart > 255)
                        .frame(width: 30)
                    }
                    .frame(width: geometry.size.width - 20, height: 30)
                    Divider()
                    HStack{
                        Text("Data Len:")
                            .bold()
                            .font(.headline)
                        Spacer()
                        Button(action: {self.readeract.DataLen -= 1}) {
                            Text("-")
                                .bold()
                                .font(.headline)
                        }
                        .frame(width: 30)
                        .disabled(readeract.DataLen < 1)
                        TextField("", value: $readeract.DataLen, formatter: NumberFormatter())
                            .onReceive(Just(readeract.DataLen), perform: {_ in
                                if readeract.DataLen > 255 {
                                    self.readeract.DataLen = 255
                                }
                                else if readeract.DataLen < 0 {
                                    self.readeract.DataLen = 0
                                }
                            })
                            .multilineTextAlignment(.center)
                            .keyboardType(.numbersAndPunctuation)
                            .frame(maxWidth: 50)
                        Button(action: {self.readeract.DataLen += 1}) {
                            Text("+")
                                .bold()
                                .font(.headline)
                        }
                        .disabled(readeract.DataLen > 255)
                        .frame(width: 30)
//                        Text("\(readeract.DataByte[readeract.DataLen_Selected])bit")
//                            .font(.headline)
//                            .frame(width: 60, height: 30)
//                            .background(Color.gray.opacity(0.15))
//                            .cornerRadius(10)
//                            .onTapGesture {
//                                readeract.DataLen_picker = true
//                            }
                    }
                    Divider()
                    HStack{
                        Text("Data Read")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            ReadTags()
                        }) {
                            Text("Read")
                        }
                        .disabled(!(reader.tagsCount > 0))
                    }
                    .frame(width: geometry.size.width - 20, height: 20, alignment: .center)
                    Divider()
                    Text("Data List")
                        .bold()
                    
                    TagsList
                }
                .frame(width: geometry.size.width - 20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height - 20, alignment: .center)
    }
    
    var TagsList: some View {
        VStack{
            Divider()
            List{
                if ErrorStr != "" {
                    Text(ErrorStr)
                        .foregroundColor(.red)
                }
                if !reader.TagsData.isEmpty {
                    ForEach(0..<reader.TagsData.count, id: \.self ){ index in
                        let TagData = reader.TagsData[index]
                        let PCstr = Data(TagData.PC).hexEncodedString()
                        let CRCstr = Data(TagData.CRC).hexEncodedString()
                        let Datastr = Data(TagData.Data).hexEncodedString()
                        HStack{
                            Text("\(TagData.id + 1)")
                                .frame(width: 20)
                            Divider()
                            VStack(alignment: .leading){
                                Text("\(Datastr)")
                                    .font(.headline)
                                HStack{
                                    Text("PC:\(PCstr)")
                                    Text("CRC:\(CRCstr)")
                                    Text("Len:\(Int(TagData.DataLen))")
                                    Text("RSSI:\(TagData.RSSI)")
                                }
                            }
                        }
                    }
                }

            }
            .listStyle(PlainListStyle())
            .frame(width: geometry.size.width, height: geometry.size.height / 2 + 60)
        }
    }
    
    func ReadTags(){
        var flag : Bool = false
        var completed : Bool = false
        var counter : Int = 0
        let cmd : [UInt8] = reader.cmd_data_read(data_block: readeract.DataCmdinByte[readeract.DataBlock_Selected], data_start: UInt8(readeract.DataStart), data_len: UInt8(readeract.DataLen))
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){timer in
            if !flag {
                ble.cmd2reader(cmd: cmd)
                reader.Btye_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            if ble.ValueUpated_2A68{
                let feedback = ble.reader2BLE()
                if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x81{
                    ErrorStr = reader.feedback2Tags(feedback: feedback)
                    completed = true
                }
                ble.ValueUpated_2A68 = false
            }
            counter += 1
            if counter > 30 || completed {
                timer.invalidate()
            }
        }
    }
}

struct Reader_WriteData: View{
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var readeract : readerAct
    var geometry : GeometryProxy
    @State var EPC_Match_Error : String = ""
    @State var FeedbackStr = [String]()
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                HStack{
                    Text("Tag")
                        .font(.headline)
                    Spacer()
                    Text(reader.Tags.isEmpty ? "" : Data(reader.Tags[readeract.EPC_Selected].EPC).hexEncodedString())
                        .font(.headline)
                        .frame(height: 30)
                        .frame(maxWidth: 350)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                        .onTapGesture {
                            readeract.EPC_picker = (reader.Tags.isEmpty ? false : true)
                        }
                }
                .frame(width: geometry.size.width - 20)
                Divider()
                HStack{
                    Text("Match Tag")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        Match_ButtAct()
                    }){
                        Text(readeract.MatchState == 0 ? "Match" : readeract.MatchState == 1 ? "Matching" : readeract.MatchState == 2 ? "Unmatch" : "Unmatching")
                            .bold()
                    }
                }
                .frame(width: geometry.size.width - 20)
                Divider()
//                HStack{
//                    Text("Data Write")
//                        .font(.headline)
//                    Spacer()
//                    Button(action: {
//                        Match_ButtAct()
//                    }){
//                        Text("Write")
//                    }
//                    .disabled(readeract.MatchState != 2)
//                }
//                .frame(width: geometry.size.width - 20)
//                Divider()
                feedbackStrList
                TagData_Write(geometry: geometry)
                    .disabled(readeract.MatchState != 2)
                Spacer()
            }
            .frame(width: geometry.size.width - 20)
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
    
    var feedbackStrList: some View {
        VStack(alignment: .center){
            if !FeedbackStr.isEmpty{
                List{
                    ForEach (0..<FeedbackStr.count, id: \.self){ index in
                        Text(FeedbackStr[FeedbackStr.count - 1 - index])
                            .foregroundColor(.red)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(width: geometry.size.width - 20)
            }
            Divider()
        }
    }
    
    func Match_ButtAct(){
        var CmdState : Int = 0
        var counter : Int = 0
        let EPC : [UInt8] = Array(reader.Tags[readeract.EPC_Selected].EPC)
        let cmd_Match : [UInt8] = reader.cmd_EPC_match(setEPC_mode: 0x00, EPC: EPC)
        let cmd_umMatch : [UInt8] = reader.cmd_EPC_match(setEPC_mode: 0x01, EPC: [])
        let cmd_getMatched : [UInt8] = [0xA0, 0x03, 0xFE, 0x86]
//        ble.cmd2reader(cmd: cmd_Match)
        //        reader.Btye_Recorder(defined: 1, byte: cmd_Match)
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){ timer in
            if CmdState == 0 && readeract.MatchState == 0{ // Send Match Cmd
                ble.cmd2reader(cmd: cmd_Match)
                reader.Btye_Recorder(defined: 1, byte: cmd_Match)
                readeract.MatchState = 1
                CmdState = 1
            }
            else if CmdState == 0 && readeract.MatchState == 2 { // Send UnMatch Cmd
                ble.cmd2reader(cmd: cmd_umMatch)
                reader.Btye_Recorder(defined: 1, byte: cmd_umMatch)
                readeract.MatchState = 3
                CmdState = 1
            }
            else if CmdState == 1 && (readeract.MatchState == 1 || readeract.MatchState == 3) { // Matching or UmMactching for waiting feedback
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    reader.Btye_Recorder(defined: 2, byte: feedback)
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x85{
                        if feedback[1] == 0x04 {
                            if feedback[4] != 0x10{
                                let ErrorStr = reader.reader_error_code(code: feedback[4])
                                FeedbackStr.append(ErrorStr)
                                CmdState = 4
                                if readeract.MatchState == 1 {
                                    readeract.MatchState = 0
                                }
                                else if readeract.MatchState == 3{
                                    readeract.MatchState = 2
                                }
                            }
                            else{
                                CmdState = 2
                            }
                        }
                    }
                    ble.ValueUpated_2A68 = false
                }
            }
            else if CmdState == 2 && (readeract.MatchState == 1 || readeract.MatchState == 3) { // verify mactching result
                ble.cmd2reader(cmd: cmd_getMatched)
                reader.Btye_Recorder(defined: 1, byte: cmd_getMatched)
                CmdState = 3
            }
            else if CmdState == 3 && (readeract.MatchState == 1 || readeract.MatchState == 3) {
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    reader.Btye_Recorder(defined: 2, byte: feedback)
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x86{
                        if feedback[4] == 0 {
                            if readeract.MatchState == 1 {
//                                FeedbackStr.append("Matching Complete")
                            }
                            else {
                                FeedbackStr.append("Unmatching EPC Fail")
                            }
                            readeract.MatchState = 2
                        }
                        else {
                            if readeract.MatchState == 1 {
                                FeedbackStr.append("Matching EPC Fail")
                            }
                            else {
//                                FeedbackStr.append("Unmatching Complete")
                            }
                            readeract.MatchState = 0
                        }
                        CmdState = 4
                    }
                    ble.ValueUpated_2A68 = false
                }
            }
            counter += 1
            if CmdState > 3 || counter > 30 {
                if counter > 25 && readeract.MatchState == 1{
                    FeedbackStr.append("Matching EPC isn't Complete")
                    readeract.MatchState = 0
                }
                timer.invalidate()
            }
        }
    }
}

struct TagData_Write: View{
    var geometry : GeometryProxy
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var location : LocationManager
    @EnvironmentObject var readeract : readerAct
    @State var funcSelected : Int = 4
//    @State var floor : Int = 0
//    @State var Seq : UInt = 0
    @State var inforSelected : Int = 4
    @State var Latitude : Float = 0
    @State var Longitude : Float = 0
//    @State var Xcoordinate : String = "0.0"
//    @State var Ycoordinate : String = "0.0"
    @State var writeAlert : Bool = false
    @State var AlertStr : String = ""
    @State var StartAdd : Int = 0
    @State var WriteByteStr : String = ""
    @State var PasswdStr : String = ""
    @State var Steps : Int = 0
    @State var ErrorStr = [String]()
    let InforStrArray : [String] = ["Stairs","Entrance","Elevator","Crossroad","Straight"]
    var body: some View {
        VStack(alignment: .center){
            HStack{
                Text("Write Data")
                    .bold()
                    .font(.headline)
                Spacer()
                Button(action: {
                    writeAlert = true
                    if funcSelected == 4{
                        AlertStr = "Password: \(String(PasswdStr.prefix(8)).hexaData.hexEncodedString())\nFloor: \(readeract.floor == 0 ? "G/F" : "\(readeract.floor)/F")\nInformation: \(InforStrArray[inforSelected])\(inforSelected != 4 ? readeract.Seq < 10 ? "0\(readeract.Seq)" : "\(readeract.Seq)" : "")\n\(inforSelected == 0 ? "Num of Steps: \(Steps)\n" : "")Indoor: \(Float(readeract.Xcoordinate) ?? 0) : \(Float(readeract.Ycoordinate) ?? 0)\nLocation: \(Latitude) : \(Longitude)"
                    }
                    else{
                        AlertStr = "Password: \(PasswdStr.hexaData.hexEncodedString())\nWrite Data to: \(readeract.DataCmdinStr[funcSelected])\nData: \(WriteByteStr.hexaData.hexEncodedString())\nStartAddress: \(StartAdd)"
                    }
                }) {
                    Text("Write")
                }
            }
            .frame(width: geometry.size.width - 20)
            Picker(selection: $funcSelected, label: Text("DataBL Picker")) {
                Text("RESERVED").tag(0)
                Text("EPC").tag(1)
                Text("TAG ID").tag(2)
                Text("USER DATA").tag(3)
                Text("NaviTag").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            Divider()
            HStack{
                Text("Password")
                    .font(.headline)
                Spacer()
                TextField("(4 bytes) without 0x and space ", text: $PasswdStr)
                    .onReceive(Just(PasswdStr), perform: { newValue in
                        let filtered = newValue.filter { "0123456789ABCDEFabcdef".contains($0) }
                        if filtered != newValue {
                            self.PasswdStr = filtered
                        }
                        if PasswdStr.count > 7 {
                            PasswdStr = String(PasswdStr.prefix(8))
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width:280, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
            }
            .frame(width: geometry.size.width - 20)
            Divider()
            if funcSelected == 4{
                NaviTagWrite
            }
            else {
                HStack{
                    Text("StatAdd")
                        .font(.headline)
                    Spacer()
                    Button(action: {self.StartAdd -= 1}) {
                        Text("-")
                            .bold()
                            .font(.headline)
                    }
                    .frame(width: 30)
                    .disabled(StartAdd < 1)
                    TextField("", value: $StartAdd, formatter: NumberFormatter())
                        .onReceive(Just(StartAdd), perform: {_ in
                            if StartAdd > 255 {
                                self.StartAdd = 255
                            }
                            else if StartAdd < 0 {
                                self.StartAdd = 0
                            }
                        })
                        .multilineTextAlignment(.center)
                        .keyboardType(.numbersAndPunctuation)
                        .frame(maxWidth: 50)
                    Button(action: {self.StartAdd += 1}) {
                        Text("+")
                            .bold()
                            .font(.headline)
                    }
                    .disabled(StartAdd > 255)
                    .frame(width: 30)
                }
                .frame(width: geometry.size.width - 20)
                Divider()
                Text("Write Bytes")
                Divider()
                TextField("Value in Byte without 0x and Space", text: $WriteByteStr)
                    .onReceive(Just(WriteByteStr), perform: { newValue in
                        let filtered = newValue.filter { "0123456789ABCDEFabcdef".contains($0) }
                        if filtered != newValue {
                            self.WriteByteStr = filtered
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width - 20, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                Divider()
            }
        }
        .alert(isPresented: $writeAlert) {
            Alert(
                title: Text("Write Data to Tag"),
                message: Text("Please Confirm the Data\n\n\(AlertStr)"),
                primaryButton:
                    .cancel(),
                secondaryButton:
                    .default(
                    Text("Confirm to Write"),
                    action: {
                        WirtetoTag()
                    }
                )
            )}
    }
    
    var NaviTagWrite: some View{
        VStack(alignment: .center){
            HStack(){
                Text("Floor")
                    .font(.headline)
                Spacer()
                Button(action: {readeract.floor -= 1}) {
                    Text("-")
                        .bold()
                        .font(.headline)
                }
                .disabled(readeract.floor < -255)
                .frame(width: 30)
                TextField("", value: $readeract.floor, formatter: NumberFormatter())
                    .onReceive(Just(readeract.floor), perform: {_ in
                        if readeract.floor > 255 {
                            readeract.floor = 255
                        }
                        else if readeract.floor < -255 {
                            readeract.floor = -255
                        }
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .frame(maxWidth: 50)
                Button(action: {readeract.floor += 1}) {
                    Text("+")
                        .bold()
                        .font(.headline)
                }
                .disabled(readeract.floor > 255)
                .frame(width: 30)
            }
            .frame(width: geometry.size.width - 20)
            Divider()
            VStack{
                Text("Information")
                    .font(.headline)
                Picker(selection: $inforSelected, label: Text("Hazard Picker")) {
                    Text("Stairs").tag(0)
                    Text("Entrance").tag(1)
                    Text("Elevator").tag(2)
                    Text("Crossroad").tag(3)
                    Text("Straight").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .frame(width: geometry.size.width - 20)
            Divider()
            if inforSelected != 4{
                HStack{
                    Text("Sequence")
                        .font(.headline)
                    Spacer()
                    Button(action: {readeract.Seq -= 1}) {
                        Text("-")
                            .bold()
                            .font(.headline)
                    }
                    .disabled(readeract.Seq < 1)
                    .frame(width: 30)
                    Text(readeract.Seq < 10 ? "0\(readeract.Seq)" : "\(readeract.Seq)")
                        .bold()
                        .font(.headline)
                        .frame(width: 30)
                    Button(action: {readeract.Seq += 1}) {
                        Text("+")
                            .bold()
                            .font(.headline)
                    }
                    .frame(width: 30)
                }
                .frame(width: geometry.size.width - 20)
                Divider()
            }
            if inforSelected == 0{
                HStack{
                    Text("Num of Step")
                        .font(.headline)
                    Spacer()
                    Button(action: {self.Steps -= 1}) {
                        Text("-")
                            .bold()
                            .font(.headline)
                    }
                    .disabled(Steps < 1)
                    .frame(width: 30)
//                    Text("\(Steps)")
//                        .bold()
//                        .font(.headline)
//                        .frame(width: 30)
                    TextField("", value: $Steps, formatter: NumberFormatter())
                        .onReceive(Just(Steps), perform: {_ in
                            if Steps > 255 {
                                self.Steps = 255
                            }
                            else if Steps < 0 {
                                self.Steps = 0
                            }
                        })
                    Button(action: {self.Steps += 1}) {
                        Text("+")
                            .bold()
                            .font(.headline)
                    }
                    .disabled(Steps > 255)
                    .frame(width: 30)
                }
                .frame(width: geometry.size.width - 20)
                Divider()
            }
            Cooradintion
            ErrorList
        }
    }
    
    var Cooradintion: some View{
        VStack(alignment: .center){
            HStack{
                Text("Location")
                    .font(.headline)
                Spacer()
                Button(action: {
                    getLocation()
                }) {
                    Text("Get")
                        .bold()
                        .font(.headline)
                    Image(systemName: "mappin.and.ellipse")
                }
                .frame(width: 60)
            }
            .frame(width: geometry.size.width - 20)
            Divider()
            HStack{
                Text("Latitude:")
                    .font(.headline)
                Spacer()
                Text("\(Latitude)")
                Divider()
                    .frame(height: 20)
                Text("Longitude:")
                    .font(.headline)
                Spacer()
                Text("\(Longitude)")
            }
            .frame(width: geometry.size.width - 20)
            Divider()
            Text("Indoor Cooradination")
                .font(.headline)
            HStack{
                Text("X:")
                    .font(.headline)
                Spacer()
                TextField("X Coordinate", text: $readeract.Xcoordinate)
                    .keyboardType(.numbersAndPunctuation)
                    .onReceive(Just(readeract.Xcoordinate), perform: { newValue in
                        let filtered = newValue.filter { "0123456789.-".contains($0) }
                        if filtered != newValue {
                            let float : Float = Float(filtered) ?? 00
                            readeract.Xcoordinate = String(float)
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width:150, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                Divider()
                    .frame(height: 30)
                Text("Y:")
                    .font(.headline)
                Spacer()
                TextField("Y Coordinate", text: $readeract.Ycoordinate)
                    .keyboardType(.numbersAndPunctuation)
                    .onReceive(Just(readeract.Ycoordinate), perform: { newValue in
                        let filtered = newValue.filter { "0123456789.-".contains($0) }
                        if filtered != newValue {
                            let float : Float = Float(filtered) ?? 00
                            readeract.Ycoordinate = String(float)
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width:150, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
            }
            .frame(width: geometry.size.width - 20)
            Divider()
        }
    }
    
    var ErrorList: some View{
        VStack{
            if !ErrorStr.isEmpty {
                List{
                    ForEach (0..<ErrorStr.count, id: \.self){ index in
                        Text(ErrorStr[ErrorStr.count - 1 - index])
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    func getLocation() {
        self.location.start()
        var counter : Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
            Latitude = Float(self.location.lastLocation?.coordinate.latitude ?? 00)
            Longitude = Float(self.location.lastLocation?.coordinate.longitude ?? 00)
            counter += 1
            if location.LocationIsUpdate || counter > 10 {
                self.location.stop()
                timer.invalidate()
                if !(counter > 10){
                    print("LatitudeInByte: \(Data(Latitude.bytes).hexEncodedString()) LongitudeInByte: \(Data(Longitude.bytes).hexEncodedString())")
                }
            }
        }
    }
    
    func WirtetoTag(){
        var flag : Bool = false
        var completed : Bool = false
        var counter : Int = 0
        var cmd = [UInt8]()
        let PasswdBytes : [UInt8] = [UInt8](PasswdStr.hexaData)
        if funcSelected == 4{
            let infor : [UInt8] = [0x00,0x00,0x00,UInt8(inforSelected)]
            let coordinate : [UInt8] = (Float(readeract.Xcoordinate) ?? 0).bytes + (Float(readeract.Ycoordinate) ?? 0).bytes + Latitude.bytes + Longitude.bytes + [UInt8(0xEC)]
            let Data : [UInt8] = [0x4E,0x56] + Array(Int16(readeract.floor).bytes) + infor + [UInt8(readeract.Seq), UInt8(Steps)] + coordinate
            cmd = reader.cmd_data_write(passwd: PasswdBytes, data_block: UInt8(1), data_start: UInt8(2), data: Data)
        }
        else{
            cmd = reader.cmd_data_write(passwd: PasswdBytes, data_block: readeract.DataCmdinByte[funcSelected], data_start: UInt8(StartAdd), data: [UInt8](WriteByteStr.hexaData))
        }
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){timer in
            if !flag {
                ble.cmd2reader(cmd: cmd)
                reader.Btye_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            if ble.ValueUpated_2A68{
                let feedback = ble.reader2BLE()
                if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x82{
                    if feedback[1] != 4 {
                        ErrorStr.append("Write Tag Succeeded")
                        readeract.MatchState = 0
                    }
                    else {
                        ErrorStr.append(reader.reader_error_code(code: feedback[4]))
                    }
                    completed = true
                }
                ble.ValueUpated_2A68 = false
            }
            counter += 1
            if counter > 30 || completed {
                timer.invalidate()
            }
        }
    }
    
}

struct Reader_Picker: View{
    var picker : [Any]
    var title : String
    var label : String
    var geometry : GeometryProxy
    @Binding var Selected : Int
    @Binding var enable : Bool
    var body: some View {
//        ZStack{
            let picker_text : [String] = picker.compactMap {String(describing: $0)}
            VStack{
                VStack(alignment: .center){
                    Text(title)
                        .font(.headline)
                        .padding()
                    Picker(selection: self.$Selected, label: Text(label)) {
                        ForEach(picker_text.indices) { (index) in
                            Text("\(picker_text[index])")
                        }
                    }
                    .padding()
                    .clipped()
                }
                .background(RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 1))
                VStack{
                    Button(action: {self.enable = false}) {
                        Text("OK")
                            .bold()
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: geometry.size.width - 30)
                    .background(RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 1))
                }
            }
            .frame(maxWidth: geometry.size.width - 30)
//        }
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
}


struct ReaderTab_Previews: PreviewProvider {
//    @State var floor = 0
    static var previews: some View {
        Group {
//            ReaderTab()
            GeometryReader {geometry in
                TagData_Write(geometry: geometry)
                    .environmentObject(readerAct())
//                Reader_WriteData(geometry: geometry)
    //            ReaderInventory()
//                ReaderSetting(geometry: geometry)
//                ReaderInventory()
                //ReadTags_data()
            }
        }
    }
}

