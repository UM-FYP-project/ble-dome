//
//  DirectionView.swift
//  ble dome
//
//  Created by UM on 18/05/2021.
//

import SwiftUI
import CoreBluetooth
//import CoreBluetooth

struct DirectionView: View {
    var geometry : GeometryProxy
    @Binding var ShortestPath : [Node]
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader : Reader
    @EnvironmentObject var path : PathFinding
    @EnvironmentObject var speech : Speech
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var ArrowDrg : Float = 0 {
        willSet{
            let ArrowDrgText = newValue == 180 || newValue == -180 ? "Turn Back" : newValue < 0 ? "Turn Left at Crossroad" : newValue > 0 ? "Turn Right at Crossroad" : "Go Straight"
            let Serivce : CBUUID = CBUUID(string: "2A68")
            let Char : CBUUID = CBUUID(string: "4D6F")
            let Mode = newValue == 180 || newValue == -180 ? 3 : newValue < 0 ? 1 : newValue > 0 ? 2 : 0
            let sendByte : UInt8 = UInt8(3 * 10 + Mode)
            if speech.isFinish{
                ble.BLEWrtieValue(Serivce: Serivce, Characteristic: Char, ByteData: [sendByte])
                speech.Stop()
                speech.Say(ArrowDrgText)
            }
        }
    }
    @State var Navtrigger : Bool = false
    var body: some View {
        VStack(alignment: .center){
            VStack(alignment: .center){
                HStack{
                    Text("Path:")
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
                .padding()
                Divider()
                HStack{
                    Spacer()
                    Image(systemName: "location.north.line.fill")
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(Double(ArrowDrg)))
                        .foregroundColor(Color(UIColor.systemTeal))
                        .frame(width: geometry.size.width - 100, height: geometry.size.width - 100)
                    Spacer()
                }
                .padding()
                Divider()
            }
            .accessibility(hidden: true)
            Spacer()
            Button(action: {
                Navtrigger.toggle()
                path.isNaving.toggle()
                if Navtrigger{
                    EnableNav()
                }
                speech.Stop()
                speech.Say("\(Navtrigger ? "Navigation Start" : "Navigation Stop")")
            }) {
                Text("\(Navtrigger ? "Navigation Stop" : "Navigation Start")")
                    .bold()
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(width: 300, height: 30)
                    .accessibility(sortPriority: Navtrigger ? 0 : 1)
            }
            .accessibilitySortPriority(2)
            .disabled(ShortestPath.isEmpty)
            .frame(height: 30)
            Divider()
            Button(action: {
                Navtrigger = false
                path.isNaving = false
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel Navigation")
                    .bold()
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(width: 300, height: 30)
            }
            .disabled(ShortestPath.isEmpty)
            .frame(height: 30)
            Divider()
            Spacer()
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
                self.presentationMode.wrappedValue.dismiss()
                speech.Stop()
                speech.Say("Arrival the Destination")
            }
            
            if !Navtrigger || !path.isNaving{
                Navtrigger = false
                path.isNaving = false
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
                let funcFeeback = reader.feedback2Tags(feedback: Feedbcak, Tags: path.Tags, TagsData: path.TagsData, Sorted: false)
//                    path.RoutineFlow += 1
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
//                                    if !path.HistoryPath.isEmpty{
//                                        if path.HistoryPath.filter({$0.XY == navtag.XY}).count < 1{
//                                            NavTags.append(navtag)
//                                        }
//                                    }
//                                    else{
                                        NavTags.append(navtag)
//                                    }
                                }
                                else{
                                    if let index = NavTags.firstIndex(where: {$0.CRC == navtag.CRC}) {
                                        NavTags[index].RSSI = navtag.RSSI
                                    }
                                }
                            }
                        }
//                        NavTags.sort{($0.RSSI >= $1.RSSI)}
//                        if Navtrigger {
//                            if !path.passedHistory.isEmpty{
//                                let CRCArr = path.passedHistory.compactMap({$0.CRC})
//                                NavTags.filter({!CRCArr.contains($0.CRC)})
//                            }
//                        }
//                        for index in 0..<NavTags.count{
//                            NavTags[index].id = index
//                        }
                    }
            case 0x93:
                    reader.Byte_Recorder(defined: 2, byte: Feedbcak)
//                if path.Tags.count > 5 {
//                    path.Tags.removeAll()
//                }
//                if path.TagsData.count > 5 {
//                    path.TagsData.removeAll()
//                }
//                path.Tags.removeAll()
//                path.TagsData.removeAll()
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

// 
