//
//  RoutineTest.swift
//  ble dome
//
//  Created by UM on 16/05/2021.
//

import SwiftUI
import Combine

struct RoutineTest: View {
    var geometry : GeometryProxy
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader : Reader
    @EnvironmentObject var path : PathFinding
    @State var Routintrigger : Bool = false
    @State var Navtrigger : Bool = false
    @State var ViewSelected : Int = 1
    @State var ListSelected : Int = 0
    @State var StartNode : Int = 0
    @State var EndNode : Int = 0
    @State var ShortestPath = [Node]()
    @State var ArrowDrg : Float = 0
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                    .frame(height : 25)
                Picker(selection: $ViewSelected, label: Text("Reader Picker")) {
                    Text("Routine").tag(0)
                    Text("Navigation").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: geometry.size.width - 20)
                if ViewSelected == 0 {
                    RoutineView
                }
                else {
                    NavigationView
                }
            }
            .frame(width: geometry.size.width - 20)
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
    
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
                    ForEach (0..<ShortestPath.count, id: \.self){ index in
                        Text("[\(ShortestPath[index].id)]\(index != ShortestPath.count - 1 ? "->" : "")")
                    }
                }
                else{
                    Text("No Path")
                }
                Spacer()
            }
            .frame(maxHeight: 60)
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
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
            if ble.peripherals.filter({$0.State == 2}).count < 1 {
                Navtrigger = false
                path.isNaving = false
            }
            getFeedBeck()
            let funcFeedback = path.PathDirection(NavTags: NavTags, ShortestPath: ShortestPath)
            ShortestPath = funcFeedback.0
            ArrowDrg = funcFeedback.1 ?? 0
            if !Navtrigger || !path.isNaving || ShortestPath.isEmpty{
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
//                    path.RoutineFlow += 1
                    reader.Byte_Recorder(defined: 2, byte: Feedbcak)
                    let funcFeeback = reader.feedback_Inventory(feedback: Feedbcak)
                    path.tagsCount = funcFeeback.0
            case 0x90:
                    let funcFeeback = reader.feedback2Tags(feedback: Feedbcak, Tags: path.Tags, TagsData: path.TagsData)
//                    path.RoutineFlow += 1
                    if funcFeeback.0 == "nil"{
                        path.Tags = funcFeeback.1
                }
            case 0x81:
                    let funcFeeback = reader.feedback2Tags(feedback: Feedbcak, Tags: path.Tags, TagsData: path.TagsData)
                    if funcFeeback.0 == "nil"{
                        path.TagsData = funcFeeback.2
                    }
                    if !path.TagsData.isEmpty{
                        for tagdata in path.TagsData {
                            guard let navtag = reader.TagtoNav(Tag: nil, TagData: tagdata) else { return }
                            if NavTags.filter({$0.CRC == navtag.CRC}).count < 1{
                                NavTags.append(navtag)
                            }
                            else{
                                if let index = NavTags.firstIndex(where: {$0.CRC == navtag.CRC}) {
                                    NavTags[index].RSSI = navtag.RSSI
                                }
                            }
                        }
                        NavTags.sort{($0.RSSI >= $1.RSSI)}
                        for index in 0..<NavTags.count{
                            NavTags[index].id = index
                        }
                    }
            case 0x93:
                    reader.Byte_Recorder(defined: 2, byte: Feedbcak)
                if path.Tags.count > 5 {
                    path.Tags.removeAll()
                }
                if path.TagsData.count > 5 {
                    path.TagsData.removeAll()
                }
                if NavTags.count > 5 {
                    NavTags.removeAll()
                }
                    path.tagsCount = 0
            default:
                break
            }
        }
    }
}

struct RoutineTest_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            RoutineTest(geometry: geometry)
                .environmentObject(BLE())
                .environmentObject(Reader())
                .environmentObject(PathFinding())
        }
//        RoutineTest()
    }
}
