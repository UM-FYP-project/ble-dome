//
//  ReaderTab.swift
//  ble dome
//
//  Created by UM on 08/02/2021.
//

import SwiftUI

struct ReaderTab: View {
    @State var menuButton :Bool = false
    @State var Reader_disable : Bool = false
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var picker : readerPicker
    var geometry : GeometryProxy
    @State var Selected = 0
    @State var isInventory = false // Reader Inverntorying or not
    // data Write
    @State var MatchState : Int = 0
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
                    if Selected == 0{
                        ReaderSetting(geometry: geometry)
                            .environmentObject(reader)
                            .environmentObject(picker)
                        
                    }
                    else if Selected == 1{
                        ReaderInventory(geometry: geometry, isInventory: $isInventory)
                            .environmentObject(reader)
                            .environmentObject(picker)

                    }
                    else if Selected == 2{
                        ReadTags_data(geometry: geometry)
                            .environmentObject(reader)
                            .environmentObject(picker)
                    }
                    else if Selected == 3{
                        Reader_WriteData(geometry: geometry, MatchState: $MatchState)
                            .environmentObject(reader)
                            .environmentObject(picker)
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

struct ReaderSetting: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var picker : readerPicker
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
                    Divider()
                    HStack{
                        Text("Set Baudrate")
                            .font(.headline)
                        Spacer()
                        Text("\(picker.BaudrateCmdinStr[picker.SelectedBaudrate])")
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                picker.SelectedBaudrate_picker = true
                            }
                        Button(action: {
                            let cmd : [UInt8] = reader.cmd_set_baudrate(baudrate_para: picker.BaudrateCmdinByte[picker.SelectedBaudrate])
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
                    Divider()
                    HStack{
                        Text("Set Power")
                            .font(.headline)
                            .frame(width: 120, height: 30,alignment: .leading)
                        Spacer()
                        Text("\(picker.Outpower[picker.SelectedPower])dBm")
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                picker.SelectedPower_picker = true
                            }
                        Button(action: {
                            let cmd : [UInt8] = reader.cmd_set_output_power(output_power: picker.Outpower[picker.SelectedPower])
                            cmdtransitor(cmd: cmd)
                        }) {
                            Text("Set")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                    }
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
                    Divider()
                    ErrorList
                    Spacer()
                }
                .frame(width: geometry.size.width - 20)
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
    @EnvironmentObject var picker : readerPicker
    var geometry : GeometryProxy
    @Binding var isInventory : Bool
    @State var Inventory_button_str = "Start"
    @State var Buffer_button_str = "Read"
    @State var Buffer_button_Bool = false
    @State var Realtime_Inventory_Toggle = false
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
                        Spacer()
                        Text("\(picker.inventorySpeed[picker.inventorySpeed_Selected])")
                            .font(.headline)
                            .frame(width: 60, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                picker.inventorySpeed_picker = true
                            }
                        Button(action: {
                            isInventory.toggle()
                            if !Realtime_Inventory_Toggle{
                                EnableInventory(cmd: reader.cmd_inventory(inventory_speed: UInt8(picker.inventorySpeed[picker.inventorySpeed_Selected])))
                            }
                            else {
                                EnableInventory(cmd: reader.cmd_real_time_inventory(inventory_speed: UInt8(picker.inventorySpeed[picker.inventorySpeed_Selected])))
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
                        ForEach(0..<reader.BytesRecord.count){ index in
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
    @EnvironmentObject var picker : readerPicker
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
                        Text(picker.DataCmdinStr[picker.DataBlock_Selected])
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                picker.DataBlock_picker = true
                            }
                    }
                    .frame(width: geometry.size.width - 20, height: 30)
                    Divider()
                    HStack{
                        Text("Start Address:")
                            .font(.headline)
                        Spacer()
                        Text("\(picker.DataByte[picker.DataStart_Selected])bit")
                            .font(.headline)
                            .frame(width: 60, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                picker.DataStart_picker = true
                            }
                        Divider()
                        Text("Data Len:")
                            .bold()
                            .font(.headline)
                        Spacer()
                        Text("\(picker.DataByte[picker.DataLen_Selected])bit")
                            .font(.headline)
                            .frame(width: 60, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                picker.DataLen_picker = true
                            }
                    }
                    .frame(width: geometry.size.width - 20, height: 30)
                    Divider()
                    HStack{
                        Text("Data Read")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            var flag : Bool = false
                            var completed : Bool = false
                            var counter : Int = 0
                            let cmd : [UInt8] = reader.cmd_data_read(data_block: picker.DataCmdinByte[picker.DataBlock_Selected], data_start: UInt8(picker.DataByte[picker.DataStart_Selected]), data_len: UInt8(picker.DataByte[picker.DataLen_Selected]))
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
                        }) {
                            Text("Read")
                        }
                        .disabled(!(reader.tagsCount > 0))
                    }
                    .frame(width: geometry.size.width - 20, height: 20, alignment: .center)
                    Divider()
                    Text("Data List")
                        .bold()
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
                    .frame(width: geometry.size.width, height: geometry.size.height / 2 + 80)
                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height - 20, alignment: .center)
    }
}

struct Reader_WriteData: View{
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var picker : readerPicker
    var geometry : GeometryProxy
    @State var EPC_Match_Error : String = ""
    @State var FeedbackStr = [String]()
//    @State var Match_ButtState : Int = 0
    @Binding var MatchState : Int // 0: Match, 1: Matching, 2: Matched
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("Tag")
                        .font(.headline)
                    Spacer()
                    Text(reader.Tags.isEmpty ? "" : Data(reader.Tags[picker.EPC_Selected].EPC).hexEncodedString())
                        .font(.headline)
                        .frame(height: 30)
                        .frame(maxWidth: 350)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        .onTapGesture {
                            picker.EPC_picker = (reader.Tags.isEmpty ? false : true)
                        }
                }
                Divider()
                HStack{
                    Text("Match Tag")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        Match_ButtAct()
                    }){
                        Text(MatchState == 0 ? "Match" : MatchState == 2 ? "Unmatch" : "Matching")
                            .bold()
                    }
                }
                Divider()
                Spacer()
            }
            .frame(width: geometry.size.width - 20)
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
    
    func Match_ButtAct(){
        var CmdState : Int = 0
        var counter : Int = 0
        let EPC : [UInt8] = Array(reader.Tags[picker.EPC_Selected].EPC)
        let cmd_Match : [UInt8] = reader.cmd_EPC_match(setEPC_mode: 0x00, EPC: EPC)
        let cmd_umMatch : [UInt8] = reader.cmd_EPC_match(setEPC_mode: 0x01, EPC: [])
        let cmd_getMatched : [UInt8] = [0xA0, 0x03, 0xFE, 0x86]
//        ble.cmd2reader(cmd: cmd_Match)
        //        reader.Btye_Recorder(defined: 1, byte: cmd_Match)
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){ timer in
            if CmdState == 0 && MatchState == 0{
                ble.cmd2reader(cmd: cmd_Match)
                reader.Btye_Recorder(defined: 1, byte: cmd_Match)
                MatchState = 1
                CmdState = 1
            }
            else if CmdState == 0 && MatchState == 2 {
                ble.cmd2reader(cmd: cmd_umMatch)
                reader.Btye_Recorder(defined: 1, byte: cmd_umMatch)
                MatchState = 1
                CmdState = 1
            }
            else if CmdState == 1 && (MatchState == 1 || MatchState == 2) {
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    reader.Btye_Recorder(defined: 2, byte: feedback)
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x85{
                        let ErrorStr = reader.reader_error_code(code: feedback[4])
                        FeedbackStr.append(ErrorStr)
                        CmdState = (MatchState == 2 ? 4 : 2)
                    }
                    ble.ValueUpated_2A68 = false
                }
            }
            else if CmdState == 2 && MatchState == 1 {
                ble.cmd2reader(cmd: cmd_getMatched)
                reader.Btye_Recorder(defined: 1, byte: cmd_getMatched)
                MatchState = 1
                CmdState = 3
            }
            else if CmdState == 3 && MatchState == 1 {
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    reader.Btye_Recorder(defined: 2, byte: feedback)
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x86{
                        if feedback[4] == 0 {
                            MatchState = 2
                        }
                        else {
                            MatchState = 0
                            FeedbackStr.append("Matching EPC Fail")
                        }
                        CmdState = 4
                    }
                    ble.ValueUpated_2A68 = false
                }
            }
            counter += 1
            if CmdState > 3 || counter > 30 {
                if counter > 25 && MatchState == 1{
                    FeedbackStr.append("Matching EPC Fail")
                    MatchState = 0
                }
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
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
}

struct ReaderTab_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            ReaderTab()
            GeometryReader {geometry in
//                Reader_WriteData(geometry: geometry)
    //            ReaderInventory()
//                ReaderSetting(geometry: geometry)
//                ReaderInventory()
                //ReadTags_data()
            }
        }
    }
}
