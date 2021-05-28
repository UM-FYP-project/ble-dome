//
//  NavMain.swift
//  ble dome
//
//  Created by UM on 11/05/2021.
//

import SwiftUI
import CoreBluetooth

struct NavMain: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var path : PathFinding
    @EnvironmentObject var nav : navValue
    @EnvironmentObject var speech : Speech
    @State var StartPathFollow = false
    @State var ButtonPressedNum : Int = 0
    let NavButtons : [NavButton] = [
        NavButton(id: 0, imageStr: "door", Text: "Entrance"),
        NavButton(id: 1, imageStr: "room", Text: "Room"),
        NavButton(id: 2, imageStr: "lavatory", Text: "Restroom"),
        NavButton(id: 3, imageStr: "stairs", Text: "Stair"),
        NavButton(id: 4, imageStr: "elevator", Text: "Elevator"),
    ]
    let BLSize : CGFloat = 125
    var geometry : GeometryProxy
    var body: some View {
        VStack{
            HStack{
//                DirectionViewLink
                HStack{
                    Image("pin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                    Text("Current\nLocation")
                        .font(.title3)
                }
                .accessibility(label: Text("Current Location"))
                .accessibilityElement(children: .combine)
                Spacer()
                VStack{
                    Text("\(nav.CurrentLocation != nil ? "\(nav.CurrentLocation!.Floor == 0 ? "G/F" : "\(nav.CurrentLocation!.Floor)/F")|\(nav.CurrentLocation!.InformationStr)" : "")")
                        .font(.title3)
                        .frame(height: 40)
                        .frame(maxWidth: 300)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                }
                .accessibility(label: Text("\(nav.CurrentLocation != nil ? "On \(nav.CurrentLocation!.Floor) Floor At \(nav.CurrentLocation!.InformationStr)" : "No Data")"))
            }
            .frame(width: geometry.size.width - 20, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            ScrollView{
                Spacer()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 50) {
                    ForEach(NavButtons, id: \.id) { navbutton in
                        Button(action: {
//                            print("1")
                            if nav.geoPos != nil {
//                                print("2")
                                ButtonPressedNum = navbutton.id
                                navButton(PressNum : &ButtonPressedNum)
                                if navbutton.id == 1 {
//                                    AlertState.toggle()
                                    nav.RoomPicker_Enable = true
                                }
                            }
                            else {
                                ButtonPressedNum = 15
                                nav.AlertState.toggle()
                            }
                        }){
                            VStack{
                                Image(navbutton.imageStr)
                                    .resizable()
                                    .scaledToFit()
                                Text(navbutton.Text)
                                    .font(.title2)
                            }
                            .frame(width: BLSize, height: BLSize)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color.white.opacity(0.15)).shadow(radius: 3))
                        }
                    }
                }
                Spacer()
                DirectionViewLink
            }
        }
        .frame(maxWidth: geometry.size.width)
        .onAppear(perform: {
            getPosFromBLE()
        })
        .alert(isPresented: $nav.AlertState){
            switch ButtonPressedNum {
            case 0,1,2,3,4:
                return Alert(
                    title: Text(nav.AlertStr),
//                    message: Text("\(nav.AlertStr)"),
                    primaryButton:
//                        .cancel()
                        .default(
                            Text("Start Navigation"),
                            action: {
                                StartPathFollow = true
                                nav.RoomPicker_Enable = false
                            }
                        )
                    ,
                    secondaryButton:
                        .cancel()
                )
            case 10,11,12,13,14:
                let Str = ["Entrance", "Room", "Restroom", "Stair", "Elevator"]
                return Alert(
                    title: Text("No \(Str[ButtonPressedNum % 10]) in Nearby")
//                    message: Text("Press OK")
                )
            case 15:
                return Alert(
                    title: Text("Please Find the Paving Frist")
//                    message: Text("Press OK")
                )
            default:
                return Alert(
                    title: Text("Press OK"),
                    message: Text("Press OK")
                )
            }
        }
    }
    
    func navButton(PressNum : inout Int){
        var toStr : String = ""
        switch PressNum {
        case 0:
            toStr = "Entrance"
        case 2:
            toStr = "Restroom"
        case 3:
            toStr = "Stair"
        case 4:
            toStr = "Elevator"
        default:
            break
        }
        if PressNum != 1 {
            if nav.geoPos != nil && nav.CurrentLocation != nil{
//                print("Pos \(geoPos), CurrentLocation \(CurrentLocation)")
                let Nodes : [Node] = NodesDict[nav.geoPos!] ?? []
//                print(Nodes)
                if !Nodes.isEmpty{
                    var AllNode = path.FindNodes(Pos: nav.geoPos!, to: toStr)
                    if PressNum == 0 {
                        AllNode = AllNode.filter({Nodes[$0].InformationStr == nav.CurrentLocation!.InformationStr})
                    }
                    if !AllNode.isEmpty{
                        let StartNode = Nodes.firstIndex(where: {$0.XY == nav.CurrentLocation!.XY})
                        let NearestNode = path.FindNearest(Pos: nav.geoPos!, from: StartNode!, to: AllNode)
                        let shortestPath : [Node] = path.getPath(Pos: nav.geoPos!, from: StartNode!, to: NearestNode!).1
                        if !shortestPath.isEmpty{
                            guard let EstimatedTime = path.PathEstimate(Path: shortestPath) else { return }
                            let Hours = EstimatedTime / 3600
                            let Minutes = (EstimatedTime % 3600) / 60
                            let Seconds = (EstimatedTime % 3600) % 60
                            let TimeStr = "\(Hours > 0 ? "\(Hours)H " : "")" + "\(Hours > 0 || Minutes > 0 ? "\(Minutes)M " : "")" + "\(Seconds > 0 ? "\(Seconds)S" : "")"
//                            nav.AlertStr = "Navigate to Nearest \(toStr) - \(NearestNode!)\n" + "Estimated Distance \(ceil(Double(EstimatedTime) / 0.85))\n" + "Estimated Time: \(TimeStr)\n"
                            nav.AlertStr = "Navigate to Nearest \(toStr) - \(NearestNode!)\n" + "Distance \(ceil(Double(EstimatedTime) / 0.85))\n"
    //                        print(nav.AlertStr)
                            nav.Current_ShortestPath = shortestPath
                            nav.AlertState.toggle()
                        }
                        else {
                            PressNum += 10
                            print(PressNum)
                            nav.AlertState.toggle()
                        }
                    }
                    else{
                        PressNum += 10
                        print(PressNum)
                        nav.AlertState.toggle()
                    }
                }
            }
        }
        else{
            let Nodes = NodesDict[nav.geoPos!] ?? []
            if !Nodes.isEmpty && nav.CurrentLocation != nil{
                let NearIndexs = path.FindNodes(Pos: nav.geoPos!, to: "Entrance")
                let FiletedIndexs = NearIndexs.filter({Nodes[$0].InformationStr != nav.CurrentLocation!.InformationStr})
                if !FiletedIndexs.isEmpty{
                    nav.RoomsList.removeAll()
                    let FiletedNodes = FiletedIndexs.map({Nodes[$0]})
                    for node in FiletedNodes{
                        if let StartNode = Nodes.firstIndex(where: {$0.XY == nav.CurrentLocation!.XY}){
                            let ShortPath = path.getPath(Pos: nav.geoPos!, from: StartNode, to: node.id).1
                            if !ShortPath.isEmpty{
                                let RoomStr : [String : String] = ["ROOM20071":"Multimedia Room", "ROOM20072":"Exhibition Room", "ROOM20073":"Chemistry Room"]
                                if let roomstr = RoomStr[node.InformationStr.uppercased()] {
                                    nav.RoomsList.append(Room(id: nav.RoomsList.count, RoomStr: roomstr, Path: ShortPath))
                                }
                            }
                        }
                    }
                    if !nav.RoomsList.isEmpty{
                        nav.RoomPicker_Enable = true
                    }
                    else{
                        PressNum += 10
                        print(PressNum)
                        nav.AlertState.toggle()
                    }
                }
                else {
                    PressNum += 10
                    print(PressNum)
                    nav.AlertState.toggle()
                }
            }
        }
    }
    
    var DirectionViewLink: some View {
        VStack{
            if !ble.peripherals.isEmpty && !(ble.peripherals.filter({$0.State == 2}).count < 1){
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }
                NavigationLink(
                    destination:
                        DirectionView(geometry: geometry,ShortestPath: $nav.Current_ShortestPath)
                        .environmentObject(ble)
                        .environmentObject(reader)
                        .environmentObject(path)
                        .environmentObject(speech),
                    isActive: $StartPathFollow,
                    label: {
                        EmptyView()
                    })
            }
        }
    }
    
    func getPosFromBLE(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){timer in
            let Serivce : CBUUID = CBUUID(string: "2A68")
            let Char : CBUUID = CBUUID(string: "5677")
            var Pos = [UInt8]()
            Pos = ble.BLEReadValue(Serivce: Serivce, Characteristic: Char)
            if !Pos.isEmpty{
                if Pos.count > 11 {
                    let Floor = Int(Data(Array(Pos[0...1])).withUnsafeBytes({$0.load(as: UInt16.self)}).bigEndian)
                    let X = Data(Array(Pos[5...8])).withUnsafeBytes({$0.load(as: Float.self)})
                    let Y = Data(Array(Pos[9...12])).withUnsafeBytes({$0.load(as: Float.self)})
                    let Lat : Float = Data(Array(Pos[13...16])).withUnsafeBytes({$0.load(as: Float.self)})
                    let Long : Float = Data(Array(Pos[17...20])).withUnsafeBytes({$0.load(as: Float.self)})
                    nav.CurrentLocation = NavChar(Floor: Floor, Information: Array(Pos[2...4]), XY: [X, Y])
                    nav.geoPos = GeoPos(Floor: Floor, geoPos: [Lat, Long])
                    if nav.geoPosUpdated {
                        var Nodes = NodesDict[nav.geoPos!]
                        if Nodes == nil {
                            let fileName = String(nav.geoPos!.geoPos[0]) + "," + String(nav.geoPos!.geoPos[1])
                            path.CSV2Dict(fileName: fileName)
                            Nodes = NodesDict[nav.geoPos!] ?? []
                        }
                        nav.geoPosUpdated = false
                    }
//                    let fileName = String(geoPos!.geoPos[0]) + "," + String(geoPos!.geoPos[1])
//                    path.CSV2Dict(fileName: fileName)
                }
            }
        }
    }
}


struct NavMain_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            NavMain(geometry: geometry)
        }
    }
}
