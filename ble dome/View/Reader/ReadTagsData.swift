//
//  ReadTagsData.swift
//  ble dome
//
//  Created by UM on 07/05/2021.
//

import SwiftUI
import Combine

struct ReadTagsData: View {
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
