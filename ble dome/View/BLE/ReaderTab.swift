//
//  ReaderTab.swift
//  ble dome
//
//  Created by UM on 08/02/2021.
//

import SwiftUI

struct ReaderTab: View {
    @State var menuButton :Bool = false
    @ObservedObject var reader = Reader()
    @State var Selected = 1
    var body: some View {
        GeometryReader{ geometry in
            ZStack() {
                if Selected == 0{
                    ReaderSetting()
                }
                else if Selected == 1{
                    ReaderInventory()
                }
                Picker(selection: $Selected, label: Text("Reader Picker")) {
                    Text("Setting").tag(0)
                    Text("Inventory").tag(1)
                    Text("Read").tag(2)
                    Text("Write").tag(3)
                    Text("Monitor").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: geometry.size.width - 20)
                .position(x: geometry.size.width / 2, y: 5)
            }
        }
    }
}


struct ReaderSetting: View {
    @EnvironmentObject var ble:BLE
    @ObservedObject var reader = Reader()
    var Baudrate : [String] = ["9600bps", "19200bps", "38400bps", "115200bps"]
    var Baudrate_cmd : [UInt8] = [0x01, 0x02 , 0x03, 0x04]
    var Outpower : [Int] = [20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    @State var Outpower_feedback : Int?
    @State var SelectedBaudrate = 3
    @State var SelectedBaudrate_picker = false
    @State var SelectedPower = 13
    @State var SelectedPower_picker = false
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                VStack(alignment: .center){
                    Text("Reader Setting")
                        .bold()
                        .font(.largeTitle)
                        .padding()
                    List{
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
                                    let reader_feedback = ble.reader2BLE()
                                    Outpower_feedback = reader.feedback_get_output_power(feedback: reader_feedback)
                                }
                            }) {
                                Text("Get")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 10)
            .blur(radius: SelectedBaudrate_picker || SelectedPower_picker ? 2 : 0)
            .overlay(SelectedBaudrate_picker || SelectedPower_picker ? Color.black.opacity(0.6) : nil)
            if SelectedBaudrate_picker == true {
                Reader_Picker(picker: Baudrate,title: "Select Baudrate", label: "Baudrate", Selected: $SelectedBaudrate, enable: $SelectedBaudrate_picker)
            }
            else if SelectedPower_picker == true{
                Reader_Picker(picker: Outpower,title: "Select Output Power", label: "Output Power", Selected: $SelectedPower, enable: $SelectedPower_picker)
            }
        }
    }
}

struct ReaderInventory: View{
    @EnvironmentObject var ble:BLE
    @ObservedObject var reader = Reader()
    let speed = Array(1...255)
    @State var Selected = 254
    @State var picker = false
    @State var isInventory = false
    @State var Inventory_button_str = "Start"
    @State var Realtime_Inventory_Toggle = false
    @State var tagsCount = 0
    @State var ErrorString = "nil"
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                VStack(alignment: .center){
                    Text("Tag Inventory")
                        .bold()
                        .font(.largeTitle)
                        .padding()
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
                            EnableInventory()
                            Inventory_button_str = (isInventory ? "Stop" : "Start")
                        }) {
                            Text(Inventory_button_str)
                                .bold()
                        }
                    }
                    .frame(width: geometry.size.width - 20, height: 30, alignment: .center)
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
                            Text("\(tagsCount) Tags")
                                .font(.headline)
                        }
                    }
                    .frame(width: geometry.size.width - 20, height: 30, alignment: .center)
                    Divider()
                    HStack{
                        Text("Buffer:")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            ble.cmd2reader(cmd: reader.cmd_get_inventory_buffer())
                        }) {
                            Text("Read")
                                .bold()
                        }
                        .disabled(Realtime_Inventory_Toggle || tagsCount <= 0)
                        Divider()
                        Button(action: {
                            ble.cmd2reader(cmd: reader.cmd_clear_inventory_buffer())
                            tagsCount = 0
                        }) {
                            Text("Clear")
                                .bold()
                        }
                        .disabled(Realtime_Inventory_Toggle || tagsCount <= 0)
                    }
                    .frame(width: geometry.size.width - 20, height: 30, alignment: .center)
                    Divider()
                    Invetroy_srcoll(geometry: geometry)
                }
                .frame(width: geometry.size.width - 20, height: geometry.size.height, alignment: .center)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 10)
            }
        }
        .blur(radius: picker  ? 2 : 0)
        .overlay(picker  ? Color.black.opacity(0.6) : nil)
        if picker {
            Reader_Picker(picker: speed, title: "Select Speed", label: "Speed", Selected: $Selected, enable: $picker)
        }
    }
    
    func EnableInventory(){
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true){ timer in
            ble.cmd2reader(cmd: reader.cmd_inventory(inventory_speed: UInt8(speed[Selected])))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                tagsCount = reader.feedback_Inventory(feedback: ble.reader2BLE()).0
                ErrorString = reader.feedback_Inventory(feedback: ble.reader2BLE()).1
            }
            if !isInventory {
                timer.invalidate()
            }
        }
    }
}

struct Invetroy_srcoll: View {
    var geometry : GeometryProxy
    var body: some View {
        HStack{
            Text("PC")
                .font(.headline)
            Divider()
            Text("EPC")
                .font(.headline)
            Spacer()
            Divider()
            Text("CRC")
                .font(.headline)
            Divider()
            Text("RSSI")
                .font(.headline)
        }
        .frame(width: geometry.size.width - 20, height: 30, alignment: .center)
        ScrollView {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
        }
        .frame(width: geometry.size.width - 20, height: geometry.size.height / 2 - 10)
    }
}

struct Reader_Picker: View{
    var picker : [Any]
    var title : String
    var label : String
    @Binding var Selected : Int
    @Binding var enable : Bool
    var body: some View {
        let picker_text : [String] = picker.compactMap {String(describing: $0)}
        GeometryReader{ geometry in
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
}


struct ReaderTab_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReaderTab()
            //ReaderSetting()
            ReaderInventory()
        }
    }
}
