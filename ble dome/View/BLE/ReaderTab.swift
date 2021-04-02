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
    @State var Selected = 1
    // Reader Setting Picker
    let Baudrate : [String] = ["9600bps", "19200bps", "38400bps", "115200bps"]
//    let Baudrate_cmd : [UInt8] = [0x01, 0x02 , 0x03, 0x04]
    let Outpower : [Int] = [20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    @State var SelectedBaudrate = 3
    @State var SelectedBaudrate_picker = false
    @State var SelectedPower = 13
    @State var SelectedPower_picker = false
    // Reader inventory Picker
    let inventorySpeed = Array(1...255)
    @State var inventorySpeed_Selected = 254
    @State var inventorySpeed_picker = false
    // Reader Data Picker
    @State var DataBlock_picker = false
    @State var DataBlock_Selected = 1
    @State var DataStart_picker = false
    @State var DataStart_Selected = 0
    @State var DataLen_picker = false
    @State var DataLen_Selected = 20
    let DataBlock_str = ["RESERVED", "EPC", "TAG ID", "USER DATA"]
    let DataBlock_byte :[UInt8] = [0x00, 0x01, 0x02, 0x03]
    let byte = Array(0...255)
    var body: some View {
        GeometryReader{ geometry in
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
                        ReaderInventory(geometry: geometry, Selected: $inventorySpeed_Selected, picker: $inventorySpeed_picker)
                            .environmentObject(reader)
                    }
                    else if Selected == 2{
//                        ReadTags_data(geometry: geometry)
//                            .environmentObject(reader)
                        ReadTags_data(geometry: geometry, DataBlock_picker: $DataBlock_picker, DataBlock_Selected: $DataBlock_Selected, DataStart_picker: $DataStart_picker, DataStart_Selected: $DataStart_Selected, DataLen_picker: $DataLen_picker, DataLen_Selected: $DataLen_Selected)
                            .environmentObject(reader)
                    }
                    else if Selected == 3{
                        //                        Reader_WriteData(geometry: geometry)
                        //                            .environmentObject(reader)
                        //                            .disabled(reader.Tags.isEmpty)
                    }
                    else if Selected == 4{
                        Record_Monitor(geometry: geometry)
                            .environmentObject(reader)
                    }
                }
            }
            .overlay(SelectedBaudrate_picker || SelectedPower_picker || inventorySpeed_picker || DataBlock_picker || DataStart_picker ||  DataLen_picker ? Color.black.opacity(0.6) : nil)
            if SelectedBaudrate_picker == true {
                Reader_Picker(picker: Baudrate,title: "Select Baudrate", label: "Baudrate", geometry: geometry, Selected: $SelectedBaudrate, enable: $SelectedBaudrate_picker)
            }
            if SelectedPower_picker == true{
                Reader_Picker(picker: Outpower,title: "Select Output Power", label: "Output Power", geometry: geometry, Selected: $SelectedPower, enable: $SelectedPower_picker)
            }
            if inventorySpeed_picker {
                Reader_Picker(picker: inventorySpeed, title: "Select Speed", label: "Speed", geometry: geometry, Selected: $inventorySpeed_Selected, enable: $inventorySpeed_picker)
            }
            if DataBlock_picker{
                Reader_Picker(picker: DataBlock_str,title: "Select DataBlock", label: "DataBlock", geometry: geometry, Selected: $DataBlock_Selected, enable: $DataBlock_picker)
            }
            if DataStart_picker{
                Reader_Picker(picker: byte,title: "Select Data Start", label: "Data Start", geometry: geometry, Selected: $DataStart_Selected, enable: $DataStart_picker)
            }
            if DataLen_picker{
                Reader_Picker(picker: byte,title: "Select Data Lenght", label: "Data Lenght", geometry: geometry, Selected: $DataLen_Selected, enable: $DataLen_picker)
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
                            ble.cmd2reader(cmd: cmd)
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
                        Button(action: {ble.cmd2reader(cmd:reader.cmd_set_baudrate(baudrate_para: Baudrate_cmd[SelectedBaudrate]))
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
                            ble.cmd2reader(cmd:
                                            reader.cmd_set_output_power(output_power: Outpower[SelectedPower]))
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
                            ble.cmd2reader(cmd:
                                            reader.cmd_get_output_power())
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                                let reader_feedback = ble.reader2BLE(record: true)
                                Outpower_feedback = reader.feedback_get_output_power(feedback: reader_feedback)
                            }
                        }) {
                            Text("Get")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                    }
                    Divider()
                    Spacer()
                }
                .frame(width: geometry.size.width - 20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
//            .overlay(SelectedBaudrate_picker || SelectedPower_picker ? Color.black.opacity(0.6) : nil)
//            if SelectedBaudrate_picker == true {
//                Reader_Picker(picker: Baudrate,title: "Select Baudrate", label: "Baudrate", geometry: geometry, Selected: $SelectedBaudrate, enable: $SelectedBaudrate_picker)
//            }
//            if SelectedPower_picker == true{
//                Reader_Picker(picker: Outpower,title: "Select Output Power", label: "Output Power", geometry: geometry, Selected: $SelectedPower, enable: $SelectedPower_picker)
//            }
//        }
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
    @State var isInventory = false
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
//                    Toggle(isOn: $Realtime_Inventory_Toggle) {
//                        Text("Realtime Inventory")
//                            .font(.headline)
//                    }
//                    Divider()
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
                            EnableInventory()
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
                            if !Realtime_Inventory_Toggle{
                                Invetroy_Buffer_aciton()
                            }
                            else {
                                
                            }
                        }) {
                            Text(Buffer_button_str)
                                .bold()
                        }
                        .disabled(Realtime_Inventory_Toggle || reader.tagsCount <= 0 || Buffer_button_Bool || isInventory)
                        Divider()
                        Button(action: {
                            ble.cmd2reader(cmd: reader.cmd_clear_inventory_buffer())
                            reader.tagsCount = 0
                        }) {
                            Text("Clear")
                                .bold()
                        }
                        .disabled(Realtime_Inventory_Toggle || reader.tagsCount <= 0 || isInventory)
                    }
                    .frame(height: 30, alignment: .center)
//                    Invetroy_Buffer_list(Error_str: Error_str_Buffer, geometry: geometry).environmentObject(reader)
                    Invetroy_Buffer_list(ErrorStr: ErrorStr, geometry: geometry).environmentObject(reader)
                    Spacer()
                }
                .frame(width: geometry.size.width - 20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
//            .overlay(picker  ? Color.black.opacity(0.3) : nil)
//            if picker {
//                Reader_Picker(picker: speed, title: "Select Speed", label: "Speed", geometry: geometry, Selected: $Selected, enable: $picker)
//            }
//        }
    }
    
    func EnableInventory(){
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true){ timer in
            ble.cmd2reader(cmd: reader.cmd_inventory(inventory_speed: UInt8(speed[Selected])))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                reader.tagsCount = reader.feedback_Inventory(feedback: ble.reader2BLE(record: true)).0
                ErrorString = reader.feedback_Inventory(feedback: ble.reader2BLE(record: false)).1
            }
            if !isInventory {
                timer.invalidate()
            }
        }
    }
    
    func Invetroy_Buffer_aciton(){
        Buffer_button_str = "Reading"
        Buffer_button_Bool = true
        ble.cmd2reader(cmd: reader.cmd_get_inventory_buffer())
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            let reader_feedback = ble.reader2BLE(record: false)
//            Error_str_Buffer = reader.feedback_Tags(feedback: reader_feedback)
            ErrorStr = reader.feedback2Tags(feedback: reader_feedback)
        }
        Buffer_button_str = "Read"
        Buffer_button_Bool = false
    }
    
}

struct Invetroy_Buffer_list: View {
    @EnvironmentObject var reader:Reader
//    let Error_str : [String]
    let ErrorStr : String
    var geometry : GeometryProxy
    var body: some View {
        VStack(alignment: .center){
            Text("Buffer List")
                .font(.headline)
            Divider()
            List {
                if ErrorStr == ""{
                    if !reader.Tags.isEmpty {
                        ForEach(0..<reader.Tags.count){ index in
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
                else {
                    Text(ErrorStr)
                        .foregroundColor(.red)
                }
//                if Error_str.isEmpty {
//                    ForEach(0..<reader.Tags.count, id:\.self){ index in
//                        let tag = reader.Tags[index]
//                        let PC_str = Data(tag.EPC[0...1]).hexEncodedString()
//                        let EPC_str = Data(tag.EPC[2...(Int(tag.EPC_Len) - 3)]).hexEncodedString()
//                        let CRC_str = Data(tag.EPC[(Int(tag.EPC_Len) - 2)...(Int(tag.EPC_Len) - 1)]).hexEncodedString()
//                        HStack{
//                            Text("\(tag.id + 1)")
//                                .frame(width: 15)
//                            Divider()
//                            VStack(alignment: .leading){
//                                Text("\(EPC_str)")
//                                    .font(.headline)
//                                HStack{
//                                    Text("PC:\(PC_str)")
//                                    Text("CRC:\(CRC_str)")
//                                    Text("Len:\(Int(tag.EPC_Len))")
//                                    Text("RSSI:\(tag.RSSI_int)")
//                                }
//                            }
//                        }
//                        //.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                    }
//                }
//                else {
//                    ForEach(0..<Error_str.count, id:\.self){ index in
//                        HStack{
//                            Text("\(index + 1)")
//                                .frame(width: 20)
//                                .foregroundColor(.red)
//                            Divider()
//                            Text(Error_str[index])
//                                .foregroundColor(.red)
//                        }
//                        //.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                    }
//                }
            }
//            .padding(.leading, -10)
            .listStyle(PlainListStyle())
            .frame(width: geometry.size.width, height: geometry.size.height / 2 + 60, alignment: .center)
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
//                Text("Monitor")
//                    .bold()
//                    .font(.largeTitle)
//                    .padding()
//                List{
//                    if !reader.Byte_Record.isEmpty {
//                        ForEach(0..<reader.Byte_Record.count){ index in
//                            let Index = reader.Byte_Record.count - index
//                            let byte_record = reader.Byte_Record[Index]
//                            let byte_str = Data(byte_record.Byte).hexEncodedString()
//                            VStack(alignment: .leading){
//                                Text("\(byte_record.Time_string)")
//                                Text(byte_str)
//                                    .foregroundColor(byte_record.Defined == 1 ? .blue : .red)
//                            }
//                        }
//                    }
//                }
//                .listStyle(PlainListStyle())
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
//    @State var Error_str_Buffer = [String]()
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
                            ble.cmd2reader(cmd: reader.cmd_data_read(data_block: DataBlock_byte[DataBlock_Selected], data_start: UInt8(byte[DataStart_Selected]), data_len: UInt8(byte[DataLen_Selected])))
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                                let reader_feedback = ble.reader2BLE(record: false)
//                                Error_str_Buffer = reader.feedback_Tags(feedback: reader_feedback)
                                ErrorStr = reader.feedback2Tags(feedback: reader_feedback)
//                                list_show = true
                            }
                        }) {
                            Text("Start")
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
                            if !reader.TagsData.isEmpty {
                                ForEach(0..<reader.TagsData.count){ index in
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
                        else {
                            Text(ErrorStr)
                                .foregroundColor(.red)
                        }
//                        if list_show{
//                            if Error_str_Buffer.isEmpty{
//                                ForEach(0..<reader.Tags.count){ index in
//                                    let tag = reader.Tags[index]
//                                    let PC_str = Data(tag.EPC[0...1]).hexEncodedString()
//                                    let EPC_str = Data(tag.EPC[2...(Int(tag.EPC_Len) - 3)]).hexEncodedString()
//                                    let CRC_str = Data(tag.EPC[(Int(tag.EPC_Len) - 2)...(Int(tag.EPC_Len) - 1)]).hexEncodedString()
//                                    let Data_str = Data(tag.Data).hexEncodedString()
//                                    HStack{
//                                        Text("\(tag.id + 1)")
//                                            .frame(width: 20)
//                                        Divider()
//                                        VStack(alignment: .leading){
//                                            Text("\(EPC_str)")
//                                                .font(.headline)
//                                            HStack{
//                                                Text("PC:\(PC_str)")
//                                                Text("CRC:\(CRC_str)")
//                                                Text("EPCLen:\(Int(tag.EPC_Len))")
//                                            }
//                                            Text("\(Data_str)")
//                                                .font(.headline)
//                                            HStack{
//                                                if tag.Data_Len != nil{
//                                                    Text("DataLen:\(Int(tag.Data_Len!))")
//                                                }
//                                                else{
//                                                    Text("DataLen:nil")
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            else {
//                                ForEach(0..<Error_str_Buffer.count){ index in
//                                    Text("Error:\(Error_str_Buffer[index])")
//                                        .foregroundColor(.red)
//                                }
//                            }
//                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(width: geometry.size.width, height: geometry.size.height / 2 + 80)
                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height - 20, alignment: .center)
//            .overlay(DataBlock_picker || DataStart_picker ||  DataLen_picker ? Color.black.opacity(0.6) : nil)
//            if DataBlock_picker{
//                Reader_Picker(picker: DataBlock_str,title: "Select DataBlock", label: "DataBlock", geometry: geometry, Selected: $DataBlock_Selected, enable: $DataBlock_picker)
//            }
//            if DataStart_picker{
//                Reader_Picker(picker: byte,title: "Select Data Start", label: "Data Start", geometry: geometry, Selected: $DataStart_Selected, enable: $DataStart_picker)
//            }
//            if DataLen_picker{
//                Reader_Picker(picker: byte,title: "Select Data Lenght", label: "Data Lenght", geometry: geometry, Selected: $DataLen_Selected, enable: $DataLen_picker)
//            }
//        }
    }
}

struct Reader_WriteData: View{
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @State var EPC_picker_trigger : Bool = false
    @State var EPC_Selected : Int = 0
    @State var EPC_Match_Error : String?
    @State var Match_ButtState : Int = 0
    var geometry : GeometryProxy
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("Tag Matching")
                        .font(.headline)
                    Text(Data(reader.Tags[EPC_Selected].EPC).hexEncodedString())
                        .font(.headline)
                        .frame(height: 30)
                        .frame(maxWidth: 200)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        .onTapGesture {
                            EPC_picker_trigger = true
                        }
                    Button(action: {
                        Match_ButtAct()
                    }){
                        Match_ButtStr
                    }
                }
                .frame(width: geometry.size.width - 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            .frame(alignment: .center)
        }
        .frame(alignment: .center)
    }
    
    func Match_ButtAct(){
        let EPC : [UInt8] = Array(reader.Tags[EPC_Selected].EPC)
        ble.cmd2reader(cmd: reader.cmd_EPC_match(setEPC_mode: 0x00, EPC: EPC))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            let reader_feedback00 = ble.reader2BLE(record: true)
            if reader_feedback00[4] != 0x10 {
                EPC_Match_Error = reader.reader_error_code(code: reader_feedback00[4])
            }
        }
    }
    
    var Match_ButtStr: some View {
        Text("Match")
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
                            .foregroundColor(Color.white.opacity(0.7)).shadow(radius: 1))
            VStack{
                Button(action: {self.enable = false}) {
                    Text("OK")
                        .bold()
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: geometry.size.width - 30)
                .background(RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.white.opacity(0.7)).shadow(radius: 1))
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
