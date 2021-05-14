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
    var body: some View {
        ZStack() {
            VStack{
                Spacer()
                    .frame(height : 10)
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
                        ScrollView {
                        ReaderWriteData(geometry: geometry)
                            .environmentObject(reader)
                            .environmentObject(readeract)
                            .disabled(reader.Tags.isEmpty)
                        }
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

//struct Reader_Picker: View{
//    var picker : [Any]
//    var title : String
//    var label : String
//    var geometry : GeometryProxy
//    @Binding var Selected : Int
//    @Binding var enable : Bool
//    var body: some View {
//        let picker_text : [String] = picker.compactMap {String(describing: $0)}
//        VStack{
//            VStack(alignment: .center){
//                Text(title)
//                    .font(.headline)
//                    .padding()
//                Picker(selection: self.$Selected, label: Text(label)) {
//                    ForEach(picker_text.indices) { (index) in
//                        Text("\(picker_text[index])")
//                    }
//                }
//                .padding()
//                .clipped()
//            }
//            Divider()
//            VStack{
//                Button(action: {self.enable = false}) {
//                    Text("OK")
//                        .bold()
//                        .font(.headline)
//                }
//                .padding()
//            }
//        }
//        .background(RoundedRectangle(cornerRadius: 10)
//                        .foregroundColor(Color(UIColor.systemGray6)).shadow(radius: 1))
//        .frame(maxWidth: geometry.size.width - 30)
//        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
//    }
//}


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

