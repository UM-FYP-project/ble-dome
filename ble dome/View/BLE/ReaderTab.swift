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
    var geometry : GeometryProxy
    @State var Selected = 0
    // Reader Setting
    @State var isInventory = false
//    let Baudrate : [String] = ["9600bps", "19200bps", "38400bps", "115200bps"]
//    let Baudrate_cmd : [UInt8] = [0x01, 0x02 , 0x03, 0x04]
//    let Outpower : [Int] = [20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    @State var SelectedBaudrate = 3
    @State var SelectedBaudrate_picker = false
    @State var SelectedPower = 13
    @State var SelectedPower_picker = false
    // Reader inventory Picker
//    let inventorySpeed = Array(1...255)
    @State var inventorySpeed_Selected = 254
    @State var inventorySpeed_picker = false
    // Reader Data Picker
    @State var DataBlock_picker = false
    @State var DataBlock_Selected = 1
    @State var DataStart_picker = false
    @State var DataStart_Selected = 2
    @State var DataLen_picker = false
    @State var DataLen_Selected = 20
    // data Write
    @State var MatchState : Int = 0
//    @Binding var overlayState : Bool
//    let DataBlock_str = ["RESERVED", "EPC", "TAG ID", "USER DATA"]
//    let DataBlock_byte :[UInt8] = [0x00, 0x01, 0x02, 0x03]
//    let byte = Array(0...255)
    var body: some View {
//        GeometryReader{ geometry in
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
                        //                        ReaderSetting(geometry: geometry).environmentObject(reader)
                        ReaderSetting(geometry: geometry, SelectedBaudrate: $SelectedBaudrate, SelectedBaudrate_picker: $SelectedBaudrate_picker, SelectedPower: $SelectedPower, SelectedPower_picker: $SelectedPower_picker)
                            .environmentObject(reader)
                    }
                    else if Selected == 1{
//                        ReaderInventory(geometry: geometry).environmentObject(reader)
                        ReaderInventory(geometry: geometry, Selected: $inventorySpeed_Selected, picker: $inventorySpeed_picker, isInventory: $isInventory)
                            .environmentObject(reader)
                    }
                    else if Selected == 2{
//                        ReadTags_data(geometry: geometry)
//                            .environmentObject(reader)
                        ReadTags_data(geometry: geometry, DataBlock_picker: $DataBlock_picker, DataBlock_Selected: $DataBlock_Selected, DataStart_picker: $DataStart_picker, DataStart_Selected: $DataStart_Selected, DataLen_picker: $DataLen_picker, DataLen_Selected: $DataLen_Selected)
                            .environmentObject(reader)
                    }
                    else if Selected == 3{
                        Reader_WriteData(geometry: geometry, MatchState: $MatchState)
                            .environmentObject(reader)
                            .disabled(reader.Tags.isEmpty)
                    }
                    else if Selected == 4{
                        Record_Monitor(geometry: geometry)
                            .environmentObject(reader)
                    }
                }
                .disabled(SelectedBaudrate_picker || SelectedPower_picker || inventorySpeed_picker || DataBlock_picker || DataStart_picker ||  DataLen_picker)
                .overlay(SelectedBaudrate_picker || SelectedPower_picker || inventorySpeed_picker || DataBlock_picker || DataStart_picker ||  DataLen_picker ? Color.black.opacity(0.3).ignoresSafeArea(): nil)
                pickerView
            }
    }
    var pickerView: some View {
        ZStack{
            if SelectedBaudrate_picker == true {
                Reader_Picker(picker: ["9600bps", "19200bps", "38400bps", "115200bps"],title: "Select Baudrate", label: "Baudrate", geometry: geometry, Selected: $SelectedBaudrate, enable: $SelectedBaudrate_picker)
            }
            if SelectedPower_picker == true{
                Reader_Picker(picker: [20,21,22,23,24,25,26,27,28,29,30,31,32,33],title: "Select Output Power", label: "Output Power", geometry: geometry, Selected: $SelectedPower, enable: $SelectedPower_picker)
            }
            if inventorySpeed_picker {
                Reader_Picker(picker: Array(1...255), title: "Select Speed", label: "Speed", geometry: geometry, Selected: $inventorySpeed_Selected, enable: $inventorySpeed_picker)
            }
            if DataBlock_picker{
                Reader_Picker(picker: ["RESERVED", "EPC", "TAG ID", "USER DATA"],title: "Select DataBlock", label: "DataBlock", geometry: geometry, Selected: $DataBlock_Selected, enable: $DataBlock_picker)
            }
            if DataStart_picker{
                Reader_Picker(picker: Array(0...255),title: "Select Data Start", label: "Data Start", geometry: geometry, Selected: $DataStart_Selected, enable: $DataStart_picker)
            }
            if DataLen_picker{
                Reader_Picker(picker: Array(0...255),title: "Select Data Lenght", label: "Data Lenght", geometry: geometry, Selected: $DataLen_Selected, enable: $DataLen_picker)
            }
        }
    }
}

struct ReaderSetting: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    var geometry : GeometryProxy
    @State var Outpower_feedback : Int?
    let Baudrate : [String] = ["9600bps", "19200bps", "38400bps", "115200bps"]
    let Baudrate_cmd : [UInt8] = [0x01, 0x02 , 0x03, 0x04]
    let Outpower : [Int] = [20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    @State var ErrorStr = [String]()
//    @State var SelectedBaudrate = 3
//    @State var SelectedBaudrate_picker = false
//    @State var SelectedPower = 13
//    @State var SelectedPower_picker = false
    @Binding var SelectedBaudrate : Int
    @Binding var SelectedBaudrate_picker : Bool
    @Binding var SelectedPower : Int
    @Binding var SelectedPower_picker : Bool
    var body: some View {
//        GeometryReader{ geometry in
            ZStack{
                VStack(alignment: .center){
//                    Text("Reader Setting")
//                        .bold()
//                        .font(.largeTitle)
//                        .padding()
                    HStack{
                        Text("Reset Reader")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            let cmd = reader.cmd_reset()
//                            ble.cmd2reader(cmd: cmd)
//                            reader.Btye_Recorder(defined: 1, byte: cmd)
//                            var feedback = [UInt8]()
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
                        Text("\(Baudrate[SelectedBaudrate])")
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                SelectedBaudrate_picker = true
                            }
                        Button(action: {
                            let cmd : [UInt8] = reader.cmd_set_baudrate(baudrate_para: Baudrate_cmd[SelectedBaudrate])
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
                        Text("\(Outpower[SelectedPower])dBm")
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                SelectedPower_picker = true
                            }
                        Button(action: {
                            let cmd : [UInt8] = reader.cmd_set_output_power(output_power: Outpower[SelectedPower])
//                            ble.cmd2reader(cmd: cmd)
//                            reader.Btye_Recorder(defined: 1, byte: cmd)
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
//                            ble.cmd2reader(cmd: cmd)
//                            reader.Btye_Recorder(defined: 1, byte: cmd)
//                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//                                let reader_feedback = ble.reader2BLE()
//                                Outpower_feedback = reader.feedback_get_output_power(feedback: reader_feedback)
//                            }
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
                ForEach (0..<ErrorStr.count){ index in
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
        Timer.scheduledTimer(withTimeInterval: 0, repeats: true){timer in
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
                        ErrorStr.append(Error)
                    }
                    else if feedback[3] == 0x77 {
                        Outpower_feedback = reader.feedback_get_output_power(feedback: feedback)
                    }
                }
                ble.ValueUpated_2A68 = false
                readState = true
            }
            counter += 1
            if counter > 200 || readState{
                print(counter)
                timer.invalidate()
            }
        }
    }
}

struct ReaderInventory: View{
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    var geometry : GeometryProxy
    let speed = Array(1...255)
//    @State var Selected = 254
//    @State var picker = false
    @Binding var Selected : Int
    @Binding var picker : Bool
//    @State var isInventory = false
    @Binding var isInventory : Bool
    @State var Inventory_button_str = "Start"
    @State var Buffer_button_str = "Read"
    @State var Buffer_button_Bool = false
    @State var Realtime_Inventory_Toggle = false
    @State var ErrorString = "nil"
//    @State var Error_str_Buffer : [String] = []
    @State var ErrorStr : String = ""
    var body: some View {
//        GeometryReader { geometry in
            ZStack{
                VStack(alignment: .center){
                    Toggle(isOn: $Realtime_Inventory_Toggle) {
                        Text("Realtime Inventory")
                            .font(.headline)
                    }
                    Divider()
                    HStack{
                        Text("Inventory Speed:")
                            .font(.headline)
                        Spacer()
                        Text("\(speed[Selected])")
                            .font(.headline)
                            .frame(width: 60, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                picker = true
                            }
                        Button(action: {
                            isInventory.toggle()
                            if !Realtime_Inventory_Toggle{
                                EnableInventory(cmd: reader.cmd_inventory(inventory_speed: UInt8(speed[Selected])))
                            }
                            else {
                                EnableInventory(cmd: reader.cmd_real_time_inventory(inventory_speed: UInt8(speed[Selected])))
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
//                        .disabled(Realtime_Inventory_Toggle || reader.tagsCount <= 0 || isInventory)
                    }
                    .frame(height: 30, alignment: .center)
//                    Invetroy_Buffer_list(Error_str: Error_str_Buffer, geometry: geometry).environmentObject(reader)
                    Divider()
//                    Invetroy_Buffer_list(ErrorStr: ErrorStr, geometry: geometry).environmentObject(reader)
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
//            let cmd : [UInt8] = reader.cmd_inventory(inventory_speed: UInt8(speed[Selected]))
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
                        //                    reader.Btye_Recorder(defined: 2, byte: feedback)
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
    var geometry : GeometryProxy
//    @State var DataBlock_picker = false
//    @State var DataBlock_Selected = 1
//    @State var DataStart_picker = false
//    @State var DataStart_Selected = 0
//    @State var DataLen_picker = false
//    @State var DataLen_Selected = 20
    @Binding var DataBlock_picker : Bool
    @Binding var DataBlock_Selected : Int
    @Binding var DataStart_picker : Bool
    @Binding var DataStart_Selected : Int
    @Binding var DataLen_picker : Bool
    @Binding var DataLen_Selected : Int
    @State var ErrorStr : String = ""
    @State var list_show = false
    let DataBlock_str = ["RESERVED", "EPC", "TAG ID", "USER DATA"]
    let DataBlock_byte :[UInt8] = [0x00, 0x01, 0x02, 0x03]
    let byte = Array(0...255)
    var body: some View {
//        GeometryReader{ geometry in
            ZStack{
                VStack(alignment: .center){
//                    Text("Read Tags")
//                        .bold()
//                        .font(.largeTitle)
//                        .padding()
                    HStack{
                        Text("Data Block")
                            .font(.headline)
                        Spacer()
                        Text(DataBlock_str[DataBlock_Selected])
                            .font(.headline)
                            .frame(width: 120, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                DataBlock_picker = true
                            }
                    }
                    .frame(width: geometry.size.width - 20, height: 30)
                    Divider()
                    HStack{
                        Text("Start Address:")
                            .font(.headline)
                        Spacer()
                        Text("\(byte[DataStart_Selected])bit")
                            .font(.headline)
                            .frame(width: 60, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                DataStart_picker = true
                            }
                        Divider()
                        Text("Data Len:")
                            .bold()
                            .font(.headline)
                        Spacer()
                        Text("\(byte[DataLen_Selected])bit")
                            .font(.headline)
                            .frame(width: 60, height: 30)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .onTapGesture {
                                DataLen_picker = true
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
                            let cmd : [UInt8] = reader.cmd_data_read(data_block: DataBlock_byte[DataBlock_Selected], data_start: UInt8(byte[DataStart_Selected]), data_len: UInt8(byte[DataLen_Selected]))
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
    var geometry : GeometryProxy
    @State var EPC_picker_trigger : Bool = false
    @State var EPC_Selected : Int = 0
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
                    Text(reader.Tags.isEmpty ? "" : Data(reader.Tags[EPC_Selected].EPC).hexEncodedString())
                        .font(.headline)
                        .frame(height: 30)
                        .frame(maxWidth: 350)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        .onTapGesture {
                            EPC_picker_trigger = (reader.Tags.isEmpty ? false : true)
                        }
                }
                .frame(width: geometry.size.width - 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
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
            .frame(alignment: .center)
        }
        .frame(width: geometry.size.width, height: geometry.size.height - 20, alignment: .center)
    }
    
    func Match_ButtAct(){
        var flag : Int = 0
        var counter : Int = 0
        let EPC : [UInt8] = Array(reader.Tags[EPC_Selected].EPC)
        let cmd_Match : [UInt8] = reader.cmd_EPC_match(setEPC_mode: 0x00, EPC: EPC)
        let cmd_umMatch : [UInt8] = reader.cmd_EPC_match(setEPC_mode: 0x01, EPC: [])
        let cmd_getMatched : [UInt8] = [0xA0, 0x03, 0xFE, 0x86]
//        ble.cmd2reader(cmd: cmd_Match)
        //        reader.Btye_Recorder(defined: 1, byte: cmd_Match)
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){ timer in
            if flag == 0 && MatchState == 0{
                ble.cmd2reader(cmd: cmd_Match)
                reader.Btye_Recorder(defined: 1, byte: cmd_Match)
                MatchState = 1
                flag = 1
            }
            else if flag == 0 && MatchState == 2 {
                ble.cmd2reader(cmd: cmd_umMatch)
                reader.Btye_Recorder(defined: 1, byte: cmd_umMatch)
                MatchState = 1
                flag = 1
            }
            else if flag == 1 && (MatchState == 1 || MatchState == 2) {
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    reader.Btye_Recorder(defined: 2, byte: feedback)
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x85{
                        let ErrorStr = reader.reader_error_code(code: feedback[4])
                        FeedbackStr.append(ErrorStr)
                        flag = (MatchState == 2 ? 4 : 2)
                    }
                    ble.ValueUpated_2A68 = false
                }
            }
            else if flag == 2 && MatchState == 1 {
                ble.cmd2reader(cmd: cmd_getMatched)
                reader.Btye_Recorder(defined: 1, byte: cmd_getMatched)
                MatchState = 1
                flag = 3
            }
            else if flag == 3 && MatchState == 1 {
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
                        flag = 4
                    }
                    ble.ValueUpated_2A68 = false
                }
            }
            counter += 1
            if flag > 3 || counter > 25 {
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
