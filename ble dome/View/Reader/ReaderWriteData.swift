//
//  ReaderWriteData.swift
//  ble dome
//
//  Created by UM on 07/05/2021.
//

import SwiftUI
import Combine

struct ReaderWriteData: View{
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var readerconfig : ReaderConfig
    @EnvironmentObject var location : LocationManager
    var geometry : GeometryProxy
    @State var EPC_Match_Error : String = ""
    @State var FeedbackStr = [String]()
    @State var funcSelected : Int = 4
    @State var HazardSelected : Int = 4
    @State var RoomSelected : Int = 0
    @State var writeAlert : Bool = false
    @State var fillPasswd : Bool = false
    @State var AlertStr : String = ""
    @State var StartAdd : Int = 0
    @State var WriteByteStr : String = ""
    @State var PasswdStr : String = ""
    @State var Steps : Int = 0
    @State var ErrorStr = [String]()
    let HazardStrArray : [String] = ["Stairs","Entrance","Elevator","Crossroad","Straight"]
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                HStack{
                    Text("Tag")
                        .font(.headline)
                    Spacer()
                    Text(readerconfig.Tags.isEmpty ? "" : readerconfig.Tags[readerconfig.EPC_Selected].EPCStr)
                        .font(.headline)
                        .frame(height: 30)
                        .frame(maxWidth: 350)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                        .onTapGesture {
                            readerconfig.EPC_picker = (readerconfig.Tags.isEmpty ? false : true)
                        }
                        .disabled(readerconfig.MatchState == 2)
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
                        Text(readerconfig.MatchState == 0 ? "Match" : readerconfig.MatchState == 1 ? "Matching" : readerconfig.MatchState == 2 ? "Unmatch" : "Unmatching")
                            .bold()
                    }
                }
                .frame(width: geometry.size.width - 20)
                Divider()
                feedbackStrList
//                TagData_Write(geometry: geometry)
//                ScrollView {
                    WriteDataSection
                        .alert(isPresented: $writeAlert){
                            switch fillPasswd {
                            case false:
                                return Alert(
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
                                )
                            case true:
                                return Alert(
                                    title: Text("Write Data to Tag"),
                                    message: Text("Please Check the Password")
                                )
                            }
                        }
//                        .alert(isPresented: $fillPasswd){
//                            Alert(
//                                title: Text("Write Data to Tag"),
//                                message: Text("Please Check the Password")
//                            )}
//                }
                .disabled(readerconfig.MatchState != 2)
//                Spacer()
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
    
    var WriteDataSection: some View {
        VStack(alignment: .center){
            HStack{
                Text("Write Data")
                    .bold()
                    .font(.headline)
                Spacer()
                Button(action: {
                    writeAlert = true
                    fillPasswd = (PasswdStr.count > 6 ? false : true)
                    if funcSelected == 4{
                        AlertStr = String(
                            "Password: \(String(PasswdStr.prefix(8)).hexaData.hexEncodedString())\n" +
                                "Floor: \(readerconfig.floor == 0 ? "G/F" : "\(readerconfig.floor)/F")" +
                            ": (\(Data(Array(Int16(readerconfig.floor).bytes)).hexEncodedString()))\n" +
                                "Hazard\n\(HazardStrArray[HazardSelected])\(HazardSelected != 4 ? readerconfig.Seq < 10 ? "0\(readerconfig.Seq)" : "\(readerconfig.Seq)" : "")\(HazardSelected == 0 ? "Num of Steps: \(Steps)" : "")" +
                                ": (\(Data([UInt8(HazardSelected)]).hexEncodedString()), \(Data(Int16(readerconfig.Seq).bytes).hexEncodedString()), \(Data([UInt8(Steps)]).hexEncodedString()))\n" +
                                "Place\n\(RoomSelected == 0 ? "Room" : RoomSelected == 1 ? "Restroom" : "Aisle")\(readerconfig.RoomSeq)" + ": (\(Data([UInt8(RoomSelected)]).hexEncodedString()), \(Data(Int16(readerconfig.RoomSeq).bytes).hexEncodedString()))\n" +
                                "Indoor\nX:\(Float(readerconfig.Xcoordinate) ?? 0) : (\(Data((Float(readerconfig.Xcoordinate) ?? 0).bytes).hexEncodedString()))\nY: \(Float(readerconfig.Ycoordinate) ?? 0) : (\(Data((Float(readerconfig.Ycoordinate) ?? 0).bytes).hexEncodedString()))\n" +
                                "Location\nLat:\(readerconfig.LatitudeStr) : (\(Data((Float(readerconfig.LatitudeStr) ?? 0).bytes).hexEncodedString()))\nLong:\(readerconfig.LongitudeStr) : (\(Data((Float(readerconfig.LongitudeStr) ?? 0).bytes).hexEncodedString())) "
                        )
                    }
                    else{
                        AlertStr = String(
                            "Password: \(PasswdStr.hexaData.hexEncodedString())\n" +
                            "Write Data to: \(readerconfig.DataCmdinStr[Int(funcSelected)])\n" +
                            "Data: \(WriteByteStr.hexaData.hexEncodedString())\nStartAddress: \(StartAdd)"
                        )

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
                        Image(systemName: "minus")
                    }
                    .padding()
                    .frame(width: 30, height: 30)
                    .disabled(StartAdd < 1)
                    TextField("Start Address", value: $StartAdd, formatter: NumberFormatter())
                        .onReceive(Just(StartAdd), perform: {_ in
                            if StartAdd > 255 {
                                self.StartAdd = 255
                            }
                            else if StartAdd < 0 {
                                self.StartAdd = 0
                            }
                        })
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 50)
                    Button(action: {self.StartAdd += 1}) {
                        Image(systemName: "plus")
                    }
                    .disabled(StartAdd > 255)
                    .padding()
                    .frame(width: 30, height: 30)
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
    }
    
    var NaviTagWrite: some View{
        VStack(alignment: .center){
            HStack(){
                Text("Floor")
                    .font(.headline)
                Spacer()
                Button(action: {readerconfig.floor -= 1}) {
                    Image(systemName: "minus")
                }
                .disabled(readerconfig.floor < -255)
                .frame(width: 30)
                TextField("Floor", value: $readerconfig.floor, formatter: NumberFormatter())
                    .onReceive(Just(readerconfig.floor), perform: {_ in
                        if readerconfig.floor > 255 {
                            readerconfig.floor = 255
                        }
                        else if readerconfig.floor < -255 {
                            readerconfig.floor = -255
                        }
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .frame(maxWidth: 50)
                Button(action: {readerconfig.floor += 1}) {
                    Image(systemName: "plus")
                }
                .disabled(readerconfig.floor > 255)
                .frame(width: 30)
            }
            .frame(width: geometry.size.width - 20)
            Divider()
            VStack{
                Text("Hazard")
                    .font(.headline)
                Picker(selection: $HazardSelected, label: Text("Hazard Picker")) {
                    Text("Stairs").tag(0)
                    Text("Entrance").tag(1)
                    Text("Elevator").tag(2)
                    Text("Crossroad").tag(3)
                    Text("Straight").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .frame(width: geometry.size.width - 20)
            Cooradintion
            if HazardSelected != 4{
                HStack{
                    Text("Seq")
                        .font(.headline)
                    Spacer()
                    Button(action: {readerconfig.Seq -= 1}) {
                        Image(systemName: "minus")
                    }
                    .disabled(readerconfig.Seq < 1)
                    .padding()
                    .frame(width: 30, height: 30)
//                    Text(readerconfig.Seq < 10 ? "0\(readerconfig.Seq)" : "\(readerconfig.Seq)")
//                        .bold()
//                        .font(.headline)
//                        .frame(width: 30)
                    TextField("Hazard Seq", value: $readerconfig.Seq, formatter: NumberFormatter())
                        .onReceive(Just(Steps), perform: {_ in
                            if readerconfig.Seq > 32767 {
                                readerconfig.Seq = 32767
                            }
                        })
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                    Button(action: {readerconfig.Seq += 1}) {
                        Image(systemName: "plus")
                    }
                    .padding()
                    .frame(width: 30, height: 30)
                    if HazardSelected == 0 || HazardSelected == 2{
                        Spacer()
                        Divider()
                        Text("Steps")
                            .font(.headline)
                        Spacer()
                        Button(action: {self.Steps -= 1}) {
                            Image(systemName: "minus")
                        }
                        .disabled(Steps < 1)
                        .padding()
                        .frame(width: 30, height: 30)
                        TextField("Steps of the Stair", value: $Steps, formatter: NumberFormatter())
                            .onReceive(Just(Steps), perform: {_ in
                                if Steps > 255 {
                                    self.Steps = 255
                                }
                                else if Steps < 0 {
                                    self.Steps = 0
                                }
                            })
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 50)
                        Button(action: {self.Steps += 1}) {
                            Image(systemName: "plus")
                        }
                        .disabled(Steps > 255)
                        .padding()
                        .frame(width: 30, height: 30)
                    }
                }
                .frame(width: geometry.size.width - 20)
                Divider()
            }
            RoomView
            ErrorList
            Spacer()
        }
    }
    
    var RoomView: some View{
        VStack(alignment: .center){
            HStack{
                Text("Place")
                Picker(selection: $RoomSelected, label: Text("Room Picker")) {
                    Text("Room").tag(0)
                    Text("W.C.").tag(1)
                    Text("Aisle").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                Button(action: {readerconfig.RoomSeq -= 1}) {
                    Image(systemName: "minus")
                }
                .disabled(readerconfig.RoomSeq < 1)
                .padding()
                .frame(width: 30, height: 30)
                TextField("Room Seq", value: $readerconfig.RoomSeq, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .onReceive(Just(Steps), perform: {_ in
                        if readerconfig.RoomSeq > 32767 {
                            readerconfig.RoomSeq = 32767
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width: 50)
                Button(action: {readerconfig.RoomSeq += 1}) {
                    Image(systemName: "plus")
                }
                .disabled(Steps > 255)
                .padding()
                .frame(width: 30, height: 30)
            }
            
        }
        .frame(width: geometry.size.width - 20)
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
                Text("Lat:")
                    .font(.headline)
                Spacer()
//                Text("\(readerconfig.Latitude)")
                TextField("Latitude", text: $readerconfig.LatitudeStr)
                    .keyboardType(.numbersAndPunctuation)
                    .onReceive(Just(readerconfig.LatitudeStr), perform: { newValue in
                        let filtered = newValue.filter { "0123456789.-".contains($0) }
                        if filtered != newValue {
                            let float : Float = Float(filtered) ?? 00
                            readerconfig.LatitudeStr = String(float)
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width:100, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                Divider()
                    .frame(height: 20)
                Text("Long:")
                    .font(.headline)
                Spacer()
//                Text("\(readerconfig.Longitude)")
                TextField("Longitude", text: $readerconfig.LongitudeStr)
                    .keyboardType(.numbersAndPunctuation)
                    .onReceive(Just(readerconfig.LongitudeStr), perform: { newValue in
                        let filtered = newValue.filter { "0123456789.-".contains($0) }
                        if filtered != newValue {
                            let float : Float = Float(filtered) ?? 00
                            readerconfig.LongitudeStr = String(float)
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width:100, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
            }
            .frame(width: geometry.size.width - 20)
            Divider()
            Text("Indoor Cooradination")
                .font(.headline)
            HStack{
                Text("X:")
                    .font(.headline)
                Spacer()
                TextField("X Coordinate", text: $readerconfig.Xcoordinate)
                    .keyboardType(.numbersAndPunctuation)
                    .onReceive(Just(readerconfig.Xcoordinate), perform: { newValue in
                        let filtered = newValue.filter { "0123456789.-".contains($0) }
                        if filtered != newValue {
                            let float : Float = Float(filtered) ?? 00
                            readerconfig.Xcoordinate = String(float)
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width:100, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                Divider()
                    .frame(height: 30)
                Text("Y:")
                    .font(.headline)
                Spacer()
                TextField("Y Coordinate", text: $readerconfig.Ycoordinate)
                    .keyboardType(.numbersAndPunctuation)
                    .onReceive(Just(readerconfig.Ycoordinate), perform: { newValue in
                        let filtered = newValue.filter { "0123456789.-".contains($0) }
                        if filtered != newValue {
                            let float : Float = Float(filtered) ?? 00
                            readerconfig.Ycoordinate = String(float)
                        }
                    })
                    .multilineTextAlignment(.center)
                    .frame(width:100, height: 30)
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
    
    func Match_ButtAct(){
        var CmdState : Int = 0
        var counter : Int = 0
        let EPC : [UInt8] = Array(readerconfig.Tags[readerconfig.EPC_Selected].EPC)
        let cmd_Match : [UInt8] = reader.cmd_EPC_match(setEPC_mode: 0x00, EPC: EPC)
        let cmd_umMatch : [UInt8] = reader.cmd_EPC_match(setEPC_mode: 0x01, EPC: [])
        let cmd_getMatched : [UInt8] = [0xA0, 0x03, 0xFE, 0x86]
        //        ble.cmd2reader(cmd: cmd_Match)
        //        reader.Btye_Recorder(defined: 1, byte: cmd_Match)
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){ timer in
            if CmdState == 0 && readerconfig.MatchState == 0{ // Send Match Cmd
                ble.cmd2reader(cmd: cmd_Match)
                reader.Btye_Recorder(defined: 1, byte: cmd_Match)
                readerconfig.MatchState = 1
                CmdState = 1
            }
            else if CmdState == 0 && readerconfig.MatchState == 2 { // Send UnMatch Cmd
                ble.cmd2reader(cmd: cmd_umMatch)
                reader.Btye_Recorder(defined: 1, byte: cmd_umMatch)
                readerconfig.MatchState = 3
                CmdState = 1
            }
            else if CmdState == 1 && (readerconfig.MatchState == 1 || readerconfig.MatchState == 3) { // Matching or UmMactching for waiting feedback
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    reader.Btye_Recorder(defined: 2, byte: feedback)
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x85{
                        if feedback[1] == 0x04 {
                            if feedback[4] != 0x10{
                                let ErrorStr = reader.reader_error_code(code: feedback[4])
                                FeedbackStr.append(ErrorStr)
                                CmdState = 4
                                if readerconfig.MatchState == 1 {
                                    readerconfig.MatchState = 0
                                }
                                else if readerconfig.MatchState == 3{
                                    readerconfig.MatchState = 2
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
            else if CmdState == 2 && (readerconfig.MatchState == 1 || readerconfig.MatchState == 3) { // verify mactching result
                ble.cmd2reader(cmd: cmd_getMatched)
                reader.Btye_Recorder(defined: 1, byte: cmd_getMatched)
                CmdState = 3
            }
            else if CmdState == 3 && (readerconfig.MatchState == 1 || readerconfig.MatchState == 3) {
                if ble.ValueUpated_2A68{
                    let feedback = ble.reader2BLE()
                    reader.Btye_Recorder(defined: 2, byte: feedback)
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x86{
                        if feedback[4] == 0 {
                            if readerconfig.MatchState == 1 {
                                //                                FeedbackStr.append("Matching Complete")
                            }
                            else {
                                FeedbackStr.append("Unmatching EPC Fail")
                            }
                            readerconfig.MatchState = 2
                        }
                        else {
                            if readerconfig.MatchState == 1 {
                                FeedbackStr.append("Matching EPC Fail")
                            }
                            else {
                                //                                FeedbackStr.append("Unmatching Complete")
                            }
                            readerconfig.MatchState = 0
                        }
                        CmdState = 4
                    }
                    ble.ValueUpated_2A68 = false
                }
            }
            counter += 1
            if CmdState > 3 || counter > 30 {
                if counter > 25 && readerconfig.MatchState == 1{
                    FeedbackStr.append("Matching EPC isn't Complete")
                    readerconfig.MatchState = 0
                }
                timer.invalidate()
            }
        }
    }
    
    func getLocation() {
        self.location.start()
        var counter : Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
            readerconfig.Latitude = Float(self.location.lastLocation?.coordinate.latitude ?? 00)
            readerconfig.Longitude = Float(self.location.lastLocation?.coordinate.longitude ?? 00)
            readerconfig.LatitudeStr = String(Float(self.location.lastLocation?.coordinate.latitude ?? 00))
            readerconfig.LongitudeStr = String(Float(self.location.lastLocation?.coordinate.longitude ?? 00))
            counter += 1
            if location.LocationIsUpdate || counter > 10 {
                self.location.stop()
                timer.invalidate()
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
//            let Hazard : [UInt8] = [UInt8(HazardSelected)] + Array(Int16(readerconfig.Seq).bytes) + [UInt8(Steps)]
            let Information : [UInt8] = [UInt8(HazardSelected)] + Array(Int16(readerconfig.Seq).bytes) + [UInt8(Steps)] + [UInt8(RoomSelected)] + Array(Int16(readerconfig.RoomSeq).bytes)
//            let Infor : [UInt8] = Hazard + Information
            let Coordinate : [UInt8] = (Float(readerconfig.Xcoordinate) ?? 0).bytes + (Float(readerconfig.Ycoordinate) ?? 0).bytes + (Float(readerconfig.LatitudeStr) ?? 0).bytes  + (Float(readerconfig.LongitudeStr) ?? 0).bytes
            let Data : [UInt8] = [0x4E,0x56] + Array(Int16(readerconfig.floor).bytes) + Information + Coordinate + [0xEC]
            cmd = reader.cmd_data_write(passwd: PasswdBytes, data_block: UInt8(1), data_start: UInt8(2), data: Data)
        }
        else{
            cmd = reader.cmd_data_write(passwd: PasswdBytes, data_block: readerconfig.DataCmdinByte[Int(funcSelected)], data_start: UInt8(StartAdd), data: [UInt8](WriteByteStr.hexaData))
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
                Match_ButtAct()
            }
        }
    }
}

//struct ReaderWriteData_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//
//        }
//    }
//}
