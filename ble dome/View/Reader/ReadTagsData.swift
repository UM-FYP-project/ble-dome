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
    @EnvironmentObject var readerconfig : ReaderConfig
    var geometry : GeometryProxy
    @State var ErrorStr : String = "nil"
    @State var list_show = false
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                HStack{
                    Text("Data Block")
                        .font(.headline)
                    Spacer()
                    Text(readerconfig.DataCmdinStr[readerconfig.DataBlock_Selected])
                        .font(.headline)
                        .frame(width: 120, height: 30)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                        .onTapGesture {
                            readerconfig.DataBlock_picker = true
                        }
                }
                .frame(width: geometry.size.width - 20, height: 30)
                Divider()
                HStack{
                    Text("Start Address:")
                        .font(.headline)
                    Spacer()
                    Button(action: {self.readerconfig.DataStart -= 1}) {
                        Image(systemName: "minus")
                    }
                    .padding()
                    .frame(width: 30, height: 30)
                    .disabled(readerconfig.DataStart < 1)
                    TextField("", value: $readerconfig.DataStart, formatter: NumberFormatter())
                        .onReceive(Just(readerconfig.DataStart), perform: {_ in
                            if readerconfig.DataStart > 255 {
                                self.readerconfig.DataStart = 255
                            }
                            else if readerconfig.DataStart < 0 {
                                self.readerconfig.DataStart = 0
                            }
                        })
                        .multilineTextAlignment(.center)
                        .keyboardType(.numbersAndPunctuation)
                        .frame(maxWidth: 50)
                    Button(action: {self.readerconfig.DataStart += 1}) {
                        Image(systemName: "plus")
                    }
                    .disabled(readerconfig.DataStart > 255)
                    .padding()
                    .frame(width: 30, height: 30)
                }
                .frame(width: geometry.size.width - 20, height: 30)
                Divider()
                HStack{
                    Text("Data Len:")
                        .bold()
                        .font(.headline)
                    Spacer()
                    Button(action: {self.readerconfig.DataLen -= 1}) {
                        Image(systemName: "minus")
                    }
                    .padding()
                    .frame(width: 30, height: 30)
                    .disabled(readerconfig.DataLen < 1)
                    TextField("", value: $readerconfig.DataLen, formatter: NumberFormatter())
                        .onReceive(Just(readerconfig.DataLen), perform: {_ in
                            if readerconfig.DataLen > 255 {
                                self.readerconfig.DataLen = 255
                            }
                            else if readerconfig.DataLen < 0 {
                                self.readerconfig.DataLen = 0
                            }
                        })
                        .multilineTextAlignment(.center)
                        .keyboardType(.numbersAndPunctuation)
                        .frame(maxWidth: 50)
                    Button(action: {self.readerconfig.DataLen += 1}) {
                        Image(systemName: "plus")
                    }
                    .disabled(readerconfig.DataLen > 255)
                    .padding()
                    .frame(width: 30, height: 30)
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
                    .disabled(!(readerconfig.tagsCount > 0))
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
                if ErrorStr != "nil" {
                    Text(ErrorStr)
                        .foregroundColor(.red)
                }
                if !readerconfig.TagsData.isEmpty {
                    ForEach(0..<readerconfig.TagsData.count, id: \.self ){ index in
                        let TagData = readerconfig.TagsData[index]
                        let PCstr = Data(TagData.PC).hexEncodedString()
                        let CRCstr = Data(TagData.CRC).hexEncodedString()
                        let EPCStr = Array(TagData.DataBL[0...11]) == TagData.EPC ? "" : Data(TagData.EPC).hexEncodedString() + "\n"
                        let Datastr = Data(TagData.DataBL).hexEncodedString()
                        let NavTag : NavTag? = reader.TagtoNav(Tag:nil, TagData: TagData)
                        HStack{
                            Text("\(TagData.id + 1)")
                                .frame(width: 20)
                            Divider()
                            VStack(alignment: .leading){
                                Text("\(EPCStr)\(Datastr)")
                                    .font(.headline)
                                HStack{
                                    Text("PC:\(PCstr)")
                                    Text("CRC:\(CRCstr)")
                                    Text("Len:\(Int(TagData.DataLen))")
                                    Text("RSSI:\(TagData.RSSI)")
                                }
                                if NavTag != nil {
                                    Text("Floor: \(NavTag!.Floor)/F\t\tHazard: \(NavTag!.HazardStr)\nInformation: \((NavTag!.InformationStr))")
                                    Text("X:\(NavTag!.XY[0])\t\tY:\(NavTag!.XY[1])")
                                    if !NavTag!.geoPos.isEmpty {
                                        Text("Lag:\(NavTag!.geoPos[0])\t\tLong:\(NavTag!.geoPos[1])")
                                    }
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
        let cmd : [UInt8] = reader.cmd_data_read(data_block: readerconfig.DataCmdinByte[readerconfig.DataBlock_Selected], data_start: UInt8(readerconfig.DataStart), data_len: UInt8(readerconfig.DataLen))
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){timer in
            if !flag {
                ble.cmd2reader(cmd: cmd)
                reader.Byte_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            if ble.ValueUpated_2A68{
                let feedback = ble.reader2BLE()
                if !feedback.isEmpty{
                    if feedback[0] == 0xA0 && feedback[2] == 0xFE && feedback[3] == 0x81{
                        let funcfeeback = reader.feedback2Tags(feedback: feedback, Tags : readerconfig.Tags, TagsData : readerconfig.TagsData, Sorted: true)
                        ErrorStr = funcfeeback.0
                        readerconfig.TagsData = funcfeeback.2
                        completed = true
                    }
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
