//
//  RoomPicker.swift
//  ble dome
//
//  Created by UM on 18/05/2021.
//

import SwiftUI

struct RoomPicker: View {
    var geometry : GeometryProxy
    var geoPos : GeoPos
    var CurrentLocation : NavChar
    @Binding var Enable : Bool
    var RoomsList : [Room]
    @Binding var AlertStr : String
    @Binding var AlertState : Bool
    @EnvironmentObject var path : PathFinding
//    @EnvironmentObject var nav : navValue
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
            RoomScrollList
                .frame(width: geometry.size.width - 100)
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
            ScrollView{
                if !RoomsList.isEmpty{
                    ForEach (0..<RoomsList.count) { index in
                        let theRoom = RoomsList[index]
                        RoomButtom(geometry: geometry, theRoom: theRoom, geoPos: geoPos, CurrentLocation: CurrentLocation, AlertStr: $AlertStr, AlertState: $AlertState)
                    }
                }
            }
        .background(RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(UIColor.systemGray5)).shadow(radius: 1))
    }
}

struct RoomButtom: View {
    var geometry : GeometryProxy
    let theRoom: Room
    let geoPos : GeoPos
    let CurrentLocation : NavChar
    @Binding var AlertStr : String
    @Binding var AlertState : Bool
    @EnvironmentObject var path : PathFinding
    @EnvironmentObject var nav : navValue
    var body: some View {
        VStack{
            Button(action: {
//                if geoPos != nil && CurrentLocation != nil{
                if let EstimatedTime = path.PathEstimate(Path: theRoom.Path){
                    let Hours = EstimatedTime / 3600
                    let Minutes = (EstimatedTime % 3600) / 60
                    let Seconds = (EstimatedTime % 3600) % 60
                    let TimeStr = "\(Hours > 0 ? "\(Hours)H " : "")" + "\(Hours > 0 || Minutes > 0 ? "\(Minutes)M " : "")" + "\(Seconds > 0 ? "\(Seconds)S" : "")"
                    AlertStr = "Navigate to Nearest \(theRoom.RoomStr)\n" + "Estimated Distance \(ceil(Double(EstimatedTime) / 0.85))" + "Estimated Time: \(TimeStr)\n"
                    nav.Current_ShortestPath = theRoom.Path
                    AlertState.toggle()
                }
            }) {
                Text(theRoom.RoomStr)
                    .foregroundColor(Color(UIColor.label))
                    .bold()
                    .accessibility(label: Text("\(theRoom.RoomStr) Tap to Navigate"))
                    .frame(width: geometry.size.width - 100 , height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            Divider()
                .frame(width: geometry.size.width - 100)
        }
        
    }
}

//struct RoomPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            RoomPicker(geometry: geometry)
//                .environmentObject(PathFinding())
//        }
//        
//    }
//}
