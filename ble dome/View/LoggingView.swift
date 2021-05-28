//
//  LoggingView.swift
//  ble dome
//
//  Created by UM on 27/05/2021.
//

import SwiftUI

struct LoggingView: View {
    var geometry : GeometryProxy
    @State var LogSelected = 0
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var path:PathFinding
    var body: some View {
        VStack{
            Spacer()
                .frame(height : 10)
            Picker(selection: $LogSelected, label: Text("Logging Picker")) {
                Text("Bluetooth").tag(0)
                Text("Reader").tag(1)
                Text("Navigation").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: geometry.size.width - 20)
            Divider()
            if LogSelected == 0 {
                BLELogging(geometry: geometry)
                    .environmentObject(ble)
            }
            else if LogSelected == 1 {
                RecordMonitor(geometry: geometry)
                    .environmentObject(reader)
            }
            else if LogSelected == 2 {
                NavTagLogging(geometry: geometry)
                    .environmentObject(path)
            }
        }
    }
}

struct BLELogging: View {
    var geometry : GeometryProxy
//    @EnvironmentObject var path:PathFinding
    @EnvironmentObject var ble:BLE
    var body: some View {
        VStack{
            VStack{
                Text("*BLUE is Sent Data")
                    .foregroundColor(.blue)
                Spacer()
                Text("*RED is Received Data")
                    .foregroundColor(.red)
            }
            .frame(width: geometry.size.width - 20)
            if !ble.bleLog.isEmpty{
                ScrollView{
                    ForEach (0..<ble.bleLog.count) { index in
                        let Log = ble.bleLog[ble.bleLog.count - index - 1]
                        HStack{
                            Text(Log.Time)
                            Divider()
                            Spacer()
                            VStack{
                                Text("\(Log.Services_UUID)-\(Log.Characteristic_UUID)")
                                Divider()
                                Text(Log.valueStr)
                                    .foregroundColor(Log.isWrite ? .blue : .red)
                            }
                        }
                        Divider()
//                        .frame(height: 30)
                    }
                    
                }
//                .frame(maxHeight: geometry.size.height - 80)
            }
            Spacer()
            Divider()
            Button(action: {
                ble.bleLog.removeAll()
            }) {
                Text("Clear Log")
                    .font(.headline)
            }
            .frame(width: geometry.size.width - 20, height: 30, alignment: .center)
            Spacer()
        }
    }
}

struct NavTagLogging: View {
    var geometry : GeometryProxy
    @EnvironmentObject var path:PathFinding
    var body: some View {
        VStack{
            if !path.NavTagLogs.isEmpty{
                ScrollView{
                    ForEach (0..<path.NavTagLogs.count) { index in
                        let Log = path.NavTagLogs[path.NavTagLogs.count - index - 1]
                        HStack{
                            Text(Log.Time)
                            Divider()
                            Spacer()
                            Text("\(Log.NodeID)")
//                            Divider()
                            Text("\(Log.navtag.XY[0]) : \(Log.navtag.XY[1])")
//                            Divider()
                            Text("RSSI: \(Log.navtag.RSSI)")
                        }
                        Divider()
//                        .frame(height: 30)
                    }
                    
                }
//                .frame(maxHeight: geometry.size.height - 80)
            }
            Spacer()
            Divider()
            Button(action: {
                path.NavTagLogs.removeAll()
            }) {
                Text("Clear Log")
                    .font(.headline)
            }
            .frame(width: geometry.size.width - 20, height: 30, alignment: .center)
            Spacer()
        }
    }
}

//struct LoggingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoggingView()
//    }
//}
