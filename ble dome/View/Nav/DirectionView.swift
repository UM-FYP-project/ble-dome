//
//  DirectionView.swift
//  ble dome
//
//  Created by UM on 18/05/2021.
//

import SwiftUI

struct DirectionView: View {
    var geometry : GeometryProxy
    @Binding var ShortestPath : [Node]
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader : Reader
    @EnvironmentObject var path : PathFinding
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var ArrowDrg : Float = 0
    @State var Navtrigger : Bool = false
    var body: some View {
        VStack(alignment: .center){
            Spacer()
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
            Button(action: {
                Navtrigger.toggle()
                path.isNaving.toggle()
                if Navtrigger{
                    EnableNav()
                }
            }) {
                Text("\(Navtrigger ? "Navigation Stop" : "Navigation Start")")
                    .bold()
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(width: 300, height: 30)
                    .accessibility(sortPriority: Navtrigger ? 0 : 1)
            }
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
        Speech(Navtrigger ? "Navigation Start" : "Navigation Pause")
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
            if ble.peripherals.filter({$0.State == 2}).count < 1 {
                Speech("Navigation Pause")
                Navtrigger = false
                path.isNaving = false
            }
            getFeedBeck()
            let funcFeedback = path.PathDirection(NavTags: &NavTags, ShortestPath: ShortestPath)
            ShortestPath = funcFeedback.0
            ArrowDrg = funcFeedback.1 ?? ArrowDrg
            Speech(ArrowDrg == 180 || ArrowDrg == -180 ? "Turn Back" : ArrowDrg < 0 ? "Turn Left" : ArrowDrg > 0 ? "Turn Right" : "Go Stright")
            if !Navtrigger || !path.isNaving || ShortestPath.count == 1{
                if (ShortestPath.count == 1){
                    Speech("Navigation Completed")
                    self.presentationMode.wrappedValue.dismiss()
                }
                path.isNaving = false
                Navtrigger = false
//                self.presentationMode.wrappedValue.dismiss()
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

// 
