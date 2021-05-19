//
//  RoomPicker.swift
//  ble dome
//
//  Created by UM on 18/05/2021.
//

import SwiftUI

struct RoomPicker: View {
    @State var Enable : Bool = false
    var geometry : GeometryProxy
    @State var RoomList = [String]()
    @State var geoPos : GeoPos?
    @State var CurrentLocation : NavChar?
    @State var AlertStr : String = ""
    @State var AlertState : Bool = false
    @EnvironmentObject var path : PathFinding
    var body: some View {
        VStack{
            VStack{
                Text("Room Selection")
                    .bold()
                    .font(.title2)
                Text("Navigate to Selected Room")
            }
            .padding()
            .clipped()
            Divider()
            Button(action: {
                self.Enable = false
            }) {
                Text("Close")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
//            .padding()
            .frame(width: geometry.size.width - 60, height: 50)

        }
        .background(RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(UIColor.systemGray6)).shadow(radius: 1))
        .frame(maxWidth: geometry.size.width - 60, maxHeight: geometry.size.height - 300)
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

    }
    
    var RoomScrollList : some View {
        VStack{
            ScrollView{
                if !RoomList.isEmpty{
                    ForEach (0..<RoomList.count) { index in
                        let RoomStr = RoomList[index]
                        RoomButtom(geometry: geometry, RoomStr: RoomStr)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(UIColor.systemGray5)).shadow(radius: 1))
    }
}

struct RoomButtom: View {
    var geometry : GeometryProxy
    var RoomStr : String
    @State var geoPos : GeoPos?
    @State var CurrentLocation : NavChar?
    @State var AlertStr : String = ""
    @State var AlertState : Bool = false
    @EnvironmentObject var path : PathFinding
    var body: some View {
        VStack{
            Button(action: {
                if geoPos != nil && CurrentLocation != nil{
                    guard let Nodes : [Node] = NodesDict[geoPos!] else { return }
                        let AllNode = path.FindNodes(Pos: geoPos!, to: "Entrance")
                    guard let StartNode = Nodes.firstIndex(where: {$0.XY == CurrentLocation!.XY}) else { return }
                    guard let NearestNode = path.FindNearest(Pos: geoPos!, from: StartNode, to: AllNode) else { return }
                    let shortestPath : [Node] = path.getPath(Pos: geoPos!, from: StartNode, to: NearestNode).1
                    guard let EstimatedTime = path.PathEstimate(Path: shortestPath) else { return }
                    let Hours = EstimatedTime / 3600
                    let Minutes = (EstimatedTime % 3600) / 60
                    let Seconds = (EstimatedTime % 3600) % 60
                    let TimeStr = "\(Hours):\(Minutes):\(Seconds)"
                    AlertStr = "Navigate to Nearest \(RoomStr)\n" + "Estimated Distance \(ceil(Double(EstimatedTime) / 0.85))" + "Estimated Time: \(TimeStr)\n"
                    AlertState.toggle()
                }
            }) {
                Text(RoomStr)
                    .foregroundColor(Color(UIColor.label))
                    .bold()
                    .accessibility(label: Text("RoomStr Tap to Navigate"))
            }
        }
    }
}

struct RoomPicker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            RoomPicker(geometry: geometry)
                .environmentObject(PathFinding())
        }
        
    }
}
