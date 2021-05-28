//
//  RoutineTest.swift
//  ble dome
//
//  Created by UM on 16/05/2021.
//

import SwiftUI
import Combine
import CoreBluetooth

struct RoutineTest: View {
    var geometry : GeometryProxy
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader : Reader
    @EnvironmentObject var path : PathFinding
    @EnvironmentObject var speech : Speech
    @State var Routintrigger : Bool = false
    @State var Navtrigger : Bool = false
    @State var ViewSelected : Int = 1
    @State var ListSelected : Int = 0
    @State var StartNode : Int = 0
    @State var EndNode : Int = 0
    @State var ShortestPath = [Node]() {
        willSet{
            if newValue.isEmpty{
//                Speech("Arrival the Destination")
            }
        }
    }
    @State var ArrowDrg : Float = 0 {
        willSet{
            let ArrowDrgText = newValue == 180 || newValue == -180 ? "Turn Back" : newValue < 0 ? "Turn Left at Crossroad" : newValue > 0 ? "Turn Right at Crossroad" : "Go Stright"
            let Serivce : CBUUID = CBUUID(string: "2A68")
            let Char : CBUUID = CBUUID(string: "4D6F")
            let Mode = newValue == 180 || newValue == -180 ? 3 : newValue < 0 ? 1 : newValue > 0 ? 2 : 0
            let sendByte : UInt8 = UInt8(2 * 10 + Mode)
            if speech.isFinish{
                ble.BLEWrtieValue(Serivce: Serivce, Characteristic: Char, ByteData: [sendByte])
                speech.Stop()
                speech.Say(ArrowDrgText)
            }
            
        }
    }
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                    .frame(height : 30)
                Picker(selection: $ViewSelected, label: Text("Reader Picker")) {
                    Text("Routine").tag(0)
                    Text("Navigation").tag(1)
//                    Text("Log").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: geometry.size.width - 20)
                if ViewSelected == 0 {
                    RoutineView
                }
                else if  ViewSelected == 1{
                    NavigationView
                }
//                else{
//                    NavTagLogView
//                }
            }
            .frame(width: geometry.size.width - 20)
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
    
//    var NavTagLogView: some View{
//        VStack{
//            if !path.NavTagLogs.isEmpty{
//                ScrollView{
//                    ForEach (0..<path.NavTagLogs.count) { index in
//                        let Log = path.NavTagLogs[path.NavTagLogs.count - index - 1]
//                        HStack{
//                            Text(Log.Time)
//                            Divider()
//                            Text("\(Log.NodeID)")
//                            Text("\(Log.navtag.XY[0]) : \(Log.navtag.XY[1])")
//                            Text("RSSI: \(Log.navtag.RSSI)")
//                        }
//
//                    }
//
//                }
//                .frame(maxHeight: geometry.size.height - 80)
//            }
//            Divider()
//            Button(action: {
//                path.NavTagLogs.removeAll()
//            }) {
//                Text("Clear Log")
//                    .font(.headline)
//            }
//            .frame(width: geometry.size.width - 20, height: 30, alignment: .center)
//            Spacer()
//        }
//    }
    
    var NavigationView: some View {
        VStack{
            Text("Navigation")
                .font(.headline)
            .frame(height: 30)
            Divider()
            HStack{
                Text("Map")
                    .font(.headline)
                Spacer()
                Text("\(!path.ExistedList.isEmpty ? path.ExistedList[path.geoSelected].PosStr : "")")
                    .font(.headline)
                    .frame(width: 300, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                    .onTapGesture {
                        path.geoPicker = true
                    }
            }
            Divider()
            HStack{
                Button(action: {
                    ShortestPath = path.getPath(Pos: path.ExistedList[path.geoSelected], from: StartNode, to: EndNode).1
//                    print("\(StartNode) - \(EndNode) | \(ShortestPath)")
                }) {
                    Text("Get Path")
                        .font(.headline)
                }
                .disabled(StartNode == EndNode)
                Spacer()
                Text("Start")
                Spacer()
                TextField("Start Node", value: $StartNode, formatter: NumberFormatter())
                    .onReceive(Just(StartNode), perform: {_ in
                        if StartNode < 0 {
                            self.StartNode = 0
                        }
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .frame(maxWidth: 75)
                    .frame(height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                Divider()
                Text("End")
                Spacer()
                TextField("End Node", value: $EndNode, formatter: NumberFormatter())
                    .onReceive(Just(EndNode), perform: {_ in
                        if EndNode < 0 {
                            self.EndNode = 0
                        }
                    })
                    .multilineTextAlignment(.center)
                    .keyboardType(.numbersAndPunctuation)
                    .frame(maxWidth: 75)
                    .frame(height: 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
            }
            .frame(height: 30)
            Divider()
            HStack{
                Text("Path:")
                    .font(.headline)
                Spacer()
                if !ShortestPath.isEmpty{
                    ScrollView{
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]){
                            ForEach (0..<ShortestPath.count, id: \.self){ index in
                                Text("[\(ShortestPath[index].id)]\(index != ShortestPath.count - 1 ? ">" : "")")
                            }
                        }
                        .frame(maxWidth: geometry.size.width - 60)
                    }
                }
                else{
                    Text("No Path")
                }
                Spacer()
            }
            .frame(maxHeight: 90)
            Divider()
            Direction
            Spacer()
        }
    }
    
    var Direction: some View{
        VStack{
            Button(action: {
                Navtrigger.toggle()
                path.isNaving.toggle()
                if Navtrigger{
//                    EnableRoutine()
                    EnableNav()
                }
            }) {
                Text("\(Navtrigger ? "Navigation Stop" : "Navigation Start")")
                    .bold()
                    .frame(width: 300, height: 30)
            }
            .disabled(ShortestPath.isEmpty)
            .frame(height: 30)
            Divider()
            Spacer()
            if Navtrigger {
                Image(systemName: "location.north.line.fill")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(Double(ArrowDrg)))
                    .foregroundColor(Color(UIColor.systemTeal))
                    .frame(width: geometry.size.width - 100, height: geometry.size.width - 100)
            }
            Spacer()
        }
    }
    
    var RoutineView: some View {
        VStack{
            HStack{
                Text("Routine")
                    .font(.headline)
                Spacer()
                Button(action: {
                    Routintrigger.toggle()
                        path.isNaving.toggle()
                    if Routintrigger{
                        EnableRoutine()
                    }
                }) {
                    Text("\(Routintrigger ? "Stop" : "Start")")
                        .bold()
                }
            }
            .frame(height: 30)
            Divider()
            HStack{
                Text("TagCount")
                    .font(.headline)
                Spacer()
                Text("\(path.tagsCount)")
            }
            .frame(height: 30)
            Divider()
            Picker(selection: $ListSelected, label: Text("Tags")) {
                Text("Tags").tag(0)
                Text("TagsData").tag(1)
                Text("NavTags").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: geometry.size.width - 20)
            Divider()
            if ListSelected == 0 {
                TagsList
            }
            else if ListSelected == 1 {
                TagsDataList
            }
            else if ListSelected == 2 {
                NavTagsList
            }
            Spacer()
            
        }
    }
    
    var TagsList: some View {
        VStack{
            Text("Tags")
                .font(.headline)
                .frame(height: 30)
            Divider()
            if !path.Tags.isEmpty {
                List(path.Tags) { tag in
                    //                ScrollView {
                    //                    ForEach (0..<path.Tags.count, id: \.self){ index in
//                    let tag = path.Tags[index]
                    let PCstr = Data(tag.PC).hexEncodedString()
                    let EPCstr = tag.EPCStr
                    let CRCstr = Data(tag.CRC).hexEncodedString()
//                    let NavTag : NavTag? = reader.TagtoNav(Tag:tag, TagData: nil)
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
    }
    
    var TagsDataList: some View {
        VStack{
            Text("TagsData")
                .font(.headline)
                .frame(height: 30)
            Divider()
            if !path.TagsData.isEmpty {
                List(path.TagsData) { TagData in
                    let PCstr = Data(TagData.PC).hexEncodedString()
                    let CRCstr = Data(TagData.CRC).hexEncodedString()
                    let EPCStr = Array(TagData.DataBL[0...11]) == TagData.EPC ? "" : Data(TagData.EPC).hexEncodedString() + "\n"
                    let Datastr = Data(TagData.DataBL).hexEncodedString()
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
                        }
                    }
                }
            }
        }
    }
    
    var NavTagsList: some View {
        VStack{
            Text("NavTags")
                .font(.headline)
                .frame(height: 30)
            Divider()
            if !NavTags.isEmpty {
                List(NavTags) { navtag in
                    HStack{
                        Text("\(navtag.id + 1)")
//                        Text("\(navtag.RSSI)")
                            .frame(width: 20)
                        Divider()
                        VStack(alignment: .leading){
                            Text("Floor: \(navtag.Floor)/F\t\tHazard: \(navtag.HazardStr)\nInformation: \((navtag.InformationStr))")
                            if !navtag.XY.isEmpty {
                                Text("X:\(navtag.XY[0])\t\tY:\(navtag.XY[1])")
                            }
                            if !navtag.geoPos.isEmpty {
                                Text("Lag:\(navtag.geoPos[0])\t\tLong:\(navtag.geoPos[1])")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func EnableNav(){
        path.FlagSendCmd = true
        path.RoutineFlow = 0
        path.Tags = []
        path.TagsData = []
        NavTags = []
        path.tagsCount = 0
        ArrowDrg = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
            if ble.peripherals.filter({$0.State == 2}).count < 1 {
                Navtrigger = false
                path.isNaving = false
            }
            getFeedBeck()
            let funcFeedback = path.PathFollowing(NavTags: &NavTags, ShortestPath: ShortestPath)
            ShortestPath = funcFeedback.0
            ArrowDrg = funcFeedback.1 ?? ArrowDrg
            if ShortestPath.isEmpty{
                Navtrigger = false
                path.isNaving = false
            }
            if !Navtrigger || !path.isNaving{
                Navtrigger = false
                timer.invalidate()
            }
        }
    }
    
    func EnableRoutine(){
        path.FlagSendCmd = true
        path.RoutineFlow = 0
        path.Tags = []
        path.TagsData = []
        NavTags = []
        path.tagsCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
            if ble.peripherals.filter({$0.State == 2}).count < 1 {
                Routintrigger = false
                path.isNaving = false
            }
            getFeedBeck()
            if !Routintrigger || !path.isNaving{
                Routintrigger = false
                timer.invalidate()
            }
        }
    }
    
    func getFeedBeck() {
        if ble.ValueUpated_2A68{
            let feedback = ble.reader2BLE()
            if !feedback.isEmpty{
                if feedback[0] == 0xA0 && feedback[2] == 0xFE{
                    if feedback[3] == 0x80  || feedback[3] == 0x90 || feedback[3] == 0x81 || feedback[3] == 0x93 {
                        FeedBackAction (Feedbcak: feedback)
                    }
                }
            }
            ble.ValueUpated_2A68 = false
        }
    }
    
    func FeedBackAction(Feedbcak : [UInt8]){
        if !Feedbcak.isEmpty {
            switch Feedbcak[3] {
            case 0x80:
                    reader.Byte_Recorder(defined: 2, byte: Feedbcak)
                    let funcFeeback = reader.feedback_Inventory(feedback: Feedbcak)
                    path.tagsCount = funcFeeback.0
            case 0x90:
                let funcFeeback = reader.feedback2Tags(feedback: Feedbcak, Tags: path.Tags, TagsData: path.TagsData, Sorted: false)
                    if funcFeeback.0 == "nil"{
                        path.Tags = funcFeeback.1
                }
            case 0x81:
                let funcFeeback = reader.feedback2Tags(feedback: Feedbcak, Tags: path.Tags, TagsData: path.TagsData, Sorted: false)
                    if funcFeeback.0 == "nil"{
                        path.TagsData = funcFeeback.2
                    }
                    if !path.TagsData.isEmpty{
                        for tagdata in path.TagsData {
                            if let navtag = reader.TagtoNav(Tag: nil, TagData: tagdata){
                                let date = Date()
                                let format = DateFormatter()
                                format.dateFormat = "HH:mm:ss"
                                let timestamp = format.string(from: date)
                                path.NavTagLogs.append(NavTagLog(id: path.NavTagLogs.count, navtag: navtag, Time: timestamp))
                                if NavTags.filter({$0.CRC == navtag.CRC}).count < 1{
                                        NavTags.append(navtag)
                                }
                                else{
                                    if let index = NavTags.firstIndex(where: {$0.CRC == navtag.CRC}) {
                                        NavTags[index].RSSI = navtag.RSSI
                                    }
                                }
                            }
                        }
                    }
            case 0x93:
                    reader.Byte_Recorder(defined: 2, byte: Feedbcak)
                if NavTags.count > 2 {
                    path.Tags.removeAll()
                    path.TagsData.removeAll()
                    NavTags.removeAll()
                }
                    path.tagsCount = 0
            default:
                break
            }
        }
    }
}

//struct RoutineTest_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            RoutineTest(geometry: geometry)
//                .environmentObject(BLE())
//                .environmentObject(Reader())
//                .environmentObject(PathFinding())
//        }
////        RoutineTest()
//    }
//}
