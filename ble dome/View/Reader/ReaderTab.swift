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
//                ScrollView {
                    if Selected == 0{
                        ReaderSetting(geometry: geometry)
                            .environmentObject(reader)
                            .environmentObject(readeract)
                    }
                    else if Selected == 1{
                        ScrollView {
                        ReaderInventory(geometry: geometry, isInventory: $readeract.isInventory, Realtime_Inventory_Toggle: $readeract.RealtimeInventory_Toggle)
                            .environmentObject(reader)
                            .environmentObject(readeract)
                        }
                        
                    }
                    else if Selected == 2{
                        ScrollView {
                        ReadTagsData(geometry: geometry)
                            .environmentObject(reader)
                            .environmentObject(readeract)
                        }
                    }
                    else if Selected == 3{
//                        ScrollView {
                        ReaderWriteData(geometry: geometry)
                            .environmentObject(reader)
                            .environmentObject(readeract)
                            .disabled(reader.Tags.isEmpty)
//                        }
                    }
                    else if Selected == 4{
                        ScrollView {
                        RecordMonitor(geometry: geometry)
                            .environmentObject(reader)
                        }
                    }
//                }
            }
        }
    }
}

//struct TagData_Write: View{
//    var geometry : GeometryProxy
//    @EnvironmentObject var ble:BLE
//    @EnvironmentObject var reader:Reader
//    @EnvironmentObject var location : LocationManager
//    @EnvironmentObject var readeract : readerAct
//    @State var funcSelected : Int = 4
//    @State var inforSelected : Int = 4
//    @State var Latitude : Float = 0
//    @State var Longitude : Float = 0
//    @State var writeAlert : Bool = false
//    @State var AlertStr : String = ""
//    @State var StartAdd : Int = 0
//    @State var WriteByteStr : String = ""
//    @State var PasswdStr : String = ""
//    @State var Steps : Int = 0
//    @State var ErrorStr = [String]()
//    let InforStrArray : [String] = ["Stairs","Entrance","Elevator","Crossroad","Straight"]
//    var body: some View {
//        VStack(alignment: .center){
//            HStack{
//                Text("Write Data")
//                    .bold()
//                    .font(.headline)
//                Spacer()
//                Button(action: {
//                    writeAlert = true
//                    if funcSelected == 4{
//                        AlertStr = "Password: \(String(PasswdStr.prefix(8)).hexaData.hexEncodedString())\nFloor: \(readeract.floor == 0 ? "G/F" : "\(readeract.floor)/F")\nInformation: \(InforStrArray[inforSelected])\(inforSelected != 4 ? readeract.Seq < 10 ? "0\(readeract.Seq)" : "\(readeract.Seq)" : "")\n\(inforSelected == 0 ? "Num of Steps: \(Steps)\n" : "")Indoor: \(Float(readeract.Xcoordinate) ?? 0) : \(Float(readeract.Ycoordinate) ?? 0)\nLocation: \(Latitude) : \(Longitude)"
//                    }
//                    else{
//                        AlertStr = "Password: \(PasswdStr.hexaData.hexEncodedString())\nWrite Data to: \(readeract.DataCmdinStr[funcSelected])\nData: \(WriteByteStr.hexaData.hexEncodedString())\nStartAddress: \(StartAdd)"
//                    }
//                }) {
//                    Text("Write")
//                }
//            }
//            .frame(width: geometry.size.width - 20)
//            Picker(selection: $funcSelected, label: Text("DataBL Picker")) {
//                Text("RESERVED").tag(0)
//                Text("EPC").tag(1)
//                Text("TAG ID").tag(2)
//                Text("USER DATA").tag(3)
//                Text("NaviTag").tag(4)
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            Divider()
//            HStack{
//                Text("Password")
//                    .font(.headline)
//                Spacer()
//                TextField("(4 bytes) without 0x and space ", text: $PasswdStr)
//                    .onReceive(Just(PasswdStr), perform: { newValue in
//                        let filtered = newValue.filter { "0123456789ABCDEFabcdef".contains($0) }
//                        if filtered != newValue {
//                            self.PasswdStr = filtered
//                        }
//                        if PasswdStr.count > 7 {
//                            PasswdStr = String(PasswdStr.prefix(8))
//                        }
//                    })
//                    .multilineTextAlignment(.center)
//                    .frame(width:280, height: 30)
//                    .background(Color.gray.opacity(0.15))
//                    .cornerRadius(10)
//            }
//            .frame(width: geometry.size.width - 20)
//            Divider()
//            if funcSelected == 4{
//                NaviTagWrite
//            }
//            else {
//                HStack{
//                    Text("StatAdd")
//                        .font(.headline)
//                    Spacer()
//                    Button(action: {self.StartAdd -= 1}) {
//                        Text("-")
//                            .bold()
//                            .font(.headline)
//                    }
//                    .frame(width: 30)
//                    .disabled(StartAdd < 1)
//                    TextField("", value: $StartAdd, formatter: NumberFormatter())
//                        .onReceive(Just(StartAdd), perform: {_ in
//                            if StartAdd > 255 {
//                                self.StartAdd = 255
//                            }
//                            else if StartAdd < 0 {
//                                self.StartAdd = 0
//                            }
//                        })
//                        .multilineTextAlignment(.center)
//                        .keyboardType(.numbersAndPunctuation)
//                        .frame(maxWidth: 50)
//                    Button(action: {self.StartAdd += 1}) {
//                        Text("+")
//                            .bold()
//                            .font(.headline)
//                    }
//                    .disabled(StartAdd > 255)
//                    .frame(width: 30)
//                }
//                .frame(width: geometry.size.width - 20)
//                Divider()
//                Text("Write Bytes")
//                Divider()
//                TextField("Value in Byte without 0x and Space", text: $WriteByteStr)
//                    .onReceive(Just(WriteByteStr), perform: { newValue in
//                        let filtered = newValue.filter { "0123456789ABCDEFabcdef".contains($0) }
//                        if filtered != newValue {
//                            self.WriteByteStr = filtered
//                        }
//                    })
//                    .multilineTextAlignment(.center)
//                    .frame(width: geometry.size.width - 20, height: 30)
//                    .background(Color.gray.opacity(0.15))
//                    .cornerRadius(10)
//                Divider()
//            }
//        }
//        .alert(isPresented: $writeAlert) {
//            Alert(
//                title: Text("Write Data to Tag"),
//                message: Text("Please Confirm the Data\n\n\(AlertStr)"),
//                primaryButton:
//                    .cancel(),
//                secondaryButton:
//                    .default(
//                        Text("Confirm to Write"),
//                        action: {
//                            WirtetoTag()
//                        }
//                    )
//            )}
//    }
//
//    var NaviTagWrite: some View{
//        VStack(alignment: .center){
//            HStack(){
//                Text("Floor")
//                    .font(.headline)
//                Spacer()
//                Button(action: {readeract.floor -= 1}) {
//                    Text("-")
//                        .bold()
//                        .font(.headline)
//                }
//                .disabled(readeract.floor < -255)
//                .frame(width: 30)
//                TextField("", value: $readeract.floor, formatter: NumberFormatter())
//                    .onReceive(Just(readeract.floor), perform: {_ in
//                        if readeract.floor > 255 {
//                            readeract.floor = 255
//                        }
//                        else if readeract.floor < -255 {
//                            readeract.floor = -255
//                        }
//                    })
//                    .multilineTextAlignment(.center)
//                    .keyboardType(.numbersAndPunctuation)
//                    .frame(maxWidth: 50)
//                Button(action: {readeract.floor += 1}) {
//                    Text("+")
//                        .bold()
//                        .font(.headline)
//                }
//                .disabled(readeract.floor > 255)
//                .frame(width: 30)
//            }
//            .frame(width: geometry.size.width - 20)
//            Divider()
//            VStack{
//                Text("Information")
//                    .font(.headline)
//                Picker(selection: $inforSelected, label: Text("Hazard Picker")) {
//                    Text("Stairs").tag(0)
//                    Text("Entrance").tag(1)
//                    Text("Elevator").tag(2)
//                    Text("Crossroad").tag(3)
//                    Text("Straight").tag(4)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//            }
//            .frame(width: geometry.size.width - 20)
//            Divider()
//            if inforSelected != 4{
//                HStack{
//                    Text("Sequence")
//                        .font(.headline)
//                    Spacer()
//                    Button(action: {readeract.Seq -= 1}) {
//                        Text("-")
//                            .bold()
//                            .font(.headline)
//                    }
//                    .disabled(readeract.Seq < 1)
//                    .frame(width: 30)
//                    Text(readeract.Seq < 10 ? "0\(readeract.Seq)" : "\(readeract.Seq)")
//                        .bold()
//                        .font(.headline)
//                        .frame(width: 30)
//                    Button(action: {readeract.Seq += 1}) {
//                        Text("+")
//                            .bold()
//                            .font(.headline)
//                    }
//                    .frame(width: 30)
//                }
//                .frame(width: geometry.size.width - 20)
//                Divider()
//            }
//            if inforSelected == 0{
//                HStack{
//                    Text("Num of Step")
//                        .font(.headline)
//                    Spacer()
//                    Button(action: {self.Steps -= 1}) {
//                        Text("-")
//                            .bold()
//                            .font(.headline)
//                    }
//                    .disabled(Steps < 1)
//                    .frame(width: 30)
//                    //                    Text("\(Steps)")
//                    //                        .bold()
//                    //                        .font(.headline)
//                    //                        .frame(width: 30)
//                    TextField("", value: $Steps, formatter: NumberFormatter())
//                        .onReceive(Just(Steps), perform: {_ in
//                            if Steps > 255 {
//                                self.Steps = 255
//                            }
//                            else if Steps < 0 {
//                                self.Steps = 0
//                            }
//                        })
//                    Button(action: {self.Steps += 1}) {
//                        Text("+")
//                            .bold()
//                            .font(.headline)
//                    }
//                    .disabled(Steps > 255)
//                    .frame(width: 30)
//                }
//                .frame(width: geometry.size.width - 20)
//                Divider()
//            }
//            Cooradintion
//            ErrorList
//        }
//    }
//
//    var Cooradintion: some View{
//        VStack(alignment: .center){
//            HStack{
//                Text("Location")
//                    .font(.headline)
//                Spacer()
//                Button(action: {
//                    getLocation()
//                }) {
//                    Text("Get")
//                        .bold()
//                        .font(.headline)
//                    Image(systemName: "mappin.and.ellipse")
//                }
//                .frame(width: 60)
//            }
//            .frame(width: geometry.size.width - 20)
//            Divider()
//            HStack{
//                Text("Latitude:")
//                    .font(.headline)
//                Spacer()
//                Text("\(Latitude)")
//                Divider()
//                    .frame(height: 20)
//                Text("Longitude:")
//                    .font(.headline)
//                Spacer()
//                Text("\(Longitude)")
//            }
//            .frame(width: geometry.size.width - 20)
//            Divider()
//            Text("Indoor Cooradination")
//                .font(.headline)
//            HStack{
//                Text("X:")
//                    .font(.headline)
//                Spacer()
//                TextField("X Coordinate", text: $readeract.Xcoordinate)
//                    .keyboardType(.numbersAndPunctuation)
//                    .onReceive(Just(readeract.Xcoordinate), perform: { newValue in
//                        let filtered = newValue.filter { "0123456789.-".contains($0) }
//                        if filtered != newValue {
//                            let float : Float = Float(filtered) ?? 00
//                            readeract.Xcoordinate = String(float)
//                        }
//                    })
//                    .multilineTextAlignment(.center)
//                    .frame(width:150, height: 30)
//                    .background(Color.gray.opacity(0.15))
//                    .cornerRadius(10)
//                Divider()
//                    .frame(height: 30)
//                Text("Y:")
//                    .font(.headline)
//                Spacer()
//                TextField("Y Coordinate", text: $readeract.Ycoordinate)
//                    .keyboardType(.numbersAndPunctuation)
//                    .onReceive(Just(readeract.Ycoordinate), perform: { newValue in
//                        let filtered = newValue.filter { "0123456789.-".contains($0) }
//                        if filtered != newValue {
//                            let float : Float = Float(filtered) ?? 00
//                            readeract.Ycoordinate = String(float)
//                        }
//                    })
//                    .multilineTextAlignment(.center)
//                    .frame(width:150, height: 30)
//                    .background(Color.gray.opacity(0.15))
//                    .cornerRadius(10)
//            }
//            .frame(width: geometry.size.width - 20)
//            Divider()
//        }
//    }
//
//    var ErrorList: some View{
//        VStack{
//            if !ErrorStr.isEmpty {
//                List{
//                    ForEach (0..<ErrorStr.count, id: \.self){ index in
//                        Text(ErrorStr[ErrorStr.count - 1 - index])
//                            .foregroundColor(.red)
//                    }
//                }
//            }
//        }
//    }
//
//    func getLocation() {
//        self.location.start()
//        var counter : Int = 0
//        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
//            Latitude = Float(self.location.lastLocation?.coordinate.latitude ?? 00)
//            Longitude = Float(self.location.lastLocation?.coordinate.longitude ?? 00)
//            counter += 1
//            if location.LocationIsUpdate || counter > 10 {
//                self.location.stop()
//                timer.invalidate()
//                if !(counter > 10){
//                    print("LatitudeInByte: \(Data(Latitude.bytes).hexEncodedString()) LongitudeInByte: \(Data(Longitude.bytes).hexEncodedString())")
//                }
//            }
//        }
//    }
//
//    func WirtetoTag(){
//        var flag : Bool = false
//        var completed : Bool = false
//        var counter : Int = 0
//        var cmd = [UInt8]()
//        let PasswdBytes : [UInt8] = [UInt8](PasswdStr.hexaData)
//        if funcSelected == 4{
//            let infor : [UInt8] = [0x00,0x00,0x00,UInt8(inforSelected)]
//            let coordinate : [UInt8] = (Float(readeract.Xcoordinate) ?? 0).bytes + (Float(readeract.Ycoordinate) ?? 0).bytes + Latitude.bytes + Longitude.bytes + [UInt8(0xEC)]
//            let Data : [UInt8] = [0x4E,0x56] + Array(Int16(readeract.floor).bytes) + infor + [UInt8(readeract.Seq), UInt8(Steps)] + coordinate
//            cmd = reader.cmd_data_write(passwd: PasswdBytes, data_block: UInt8(1), data_start: UInt8(2), data: Data)
//        }
//        else{
//            cmd = reader.cmd_data_write(passwd: PasswdBytes, data_block: readeract.DataCmdinByte[funcSelected], data_start: UInt8(StartAdd), data: [UInt8](WriteByteStr.hexaData))
//        }
//        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){timer in
//            if !flag {
//                ble.cmd2reader(cmd: cmd)
//                reader.Btye_Recorder(defined: 1, byte: cmd)
//                flag = true
//            }
//            if ble.ValueUpated_2A68{
//                let feedback = ble.reader2BLE()
//                if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x82{
//                    if feedback[1] != 4 {
//                        ErrorStr.append("Write Tag Succeeded")
//                        readeract.MatchState = 0
//                    }
//                    else {
//                        ErrorStr.append(reader.reader_error_code(code: feedback[4]))
//                    }
//                    completed = true
//                }
//                ble.ValueUpated_2A68 = false
//            }
//            counter += 1
//            if counter > 30 || completed {
//                timer.invalidate()
//            }
//        }
//    }
//
//}

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


//struct ReaderTab_Previews: PreviewProvider {
//    //    @State var floor = 0
//    static var previews: some View {
//        Group {
//            //            ReaderTab()
//            GeometryReader {geometry in
//                TagData_Write(geometry: geometry)
//                    .environmentObject(readerAct())
//                //                Reader_WriteData(geometry: geometry)
//                //            ReaderInventory()
//                //                ReaderSetting(geometry: geometry)
//                //                ReaderInventory()
//                //ReadTags_data()
//            }
//        }
//    }
//}

