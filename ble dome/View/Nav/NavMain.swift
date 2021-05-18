//
//  NavMain.swift
//  ble dome
//
//  Created by UM on 11/05/2021.
//

import SwiftUI
import CoreBluetooth

struct NavButton : Identifiable{
    let id : Int
    let imageStr : String
    let Text : String
}

struct NavChar {
    let Floor : Int
    let Information : [UInt8]
    let XY : [Float]
    var InformationStr : String {
        let InformationStrArray : [String] = ["Room","Restroom","Aisle"]
        let SeqInt : Int = Int(Data(Array(Information[1...2])).withUnsafeBytes({$0.load(as: UInt16.self)}).bigEndian)
        let Str : String = InformationStrArray[Int(Information[0])] + "\(SeqInt)"
        return Str
    }
}

struct NavMain: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var path : PathFinding
    @State var RoomList = [String]()
    @State var CurrentLocation : NavChar?
    @State var geoPosUpdated : Bool = false
    @State var geoPos : GeoPos? = nil {
        willSet {
            if newValue != geoPos {
                geoPosUpdated = true
            }
        }
    }
    @State var AlertState : Bool = false
    @State var ButtonPressedNum : Int = 0
    @State var AlertStr : String = ""
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
                Image("pin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                Text("Current\nLocation")
                    .font(.title3)
                Spacer()
                VStack{
                    Text("\(CurrentLocation != nil ? "\(CurrentLocation!.Floor == 0 ? "G/F" : "\(CurrentLocation!.Floor)/F")\t|\t\(CurrentLocation!.InformationStr)" : "")")
                        .font(.title3)
                        .frame(height: 40)
                        .frame(maxWidth: 300)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                }
            }
            .frame(width: geometry.size.width - 20, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            ScrollView{
                Spacer()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 50) {
                    ForEach(NavButtons, id: \.id) { navbutton in
                        Button(action: {
                            if geoPos != nil {
                                ButtonPressedNum = navbutton.id
                                navButton(PressNum : ButtonPressedNum)
//                                if navbutton.id != 1 {
//                                    AlertState.toggle()
//                                }
                            }
                            else {
                                ButtonPressedNum = 10
                                AlertState.toggle()
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
                                            .foregroundColor(Color.white.opacity(0.3)).shadow(radius: 3))
                        }
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: geometry.size.width)
        .onAppear(perform: {
            getPosFromBLE()
        })
        .alert(isPresented: $AlertState){
            switch ButtonPressedNum {
            case 0,2,3,4:
                return Alert(
                    title: Text("Navigation"),
                    message: Text("\(AlertStr)"),
                    primaryButton:
                        .cancel(),
                    secondaryButton:
                        .default(
                            Text("Start Navigation"),
                            action: {
//                                WirtetoTag()
                            }
                        )
                )
            case 10:
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
    
    func navButton(PressNum : Int){
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
                AlertStr = "Navigate to Nearest \(toStr)\n" + "Estimated Distance \(ceil(Double(EstimatedTime) / 0.85))" + "Estimated Time: \(TimeStr)\n"
                AlertState.toggle()
            }
        }
        else{
            
        }
    }
    
    func getPosFromBLE(){
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true){timer in
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
                    CurrentLocation = NavChar(Floor: Floor, Information: Array(Pos[2...4]), XY: [X, Y])
                    geoPos = GeoPos(Floor: Floor, geoPos: [Lat, Long])
                    if geoPosUpdated {
                        var Nodes = NodesDict[geoPos!]
                        if Nodes == nil {
                            let fileName = String(geoPos!.geoPos[0]) + "," + String(geoPos!.geoPos[1])
                            path.CSV2Dict(fileName: fileName)
                            Nodes = NodesDict[geoPos!]!
                            if Nodes != nil && CurrentLocation != nil{
                                let FiletedNodes =  Nodes!.filter({$0.InformationStr != CurrentLocation!.InformationStr && $0.HazardStr.uppercased().contains(String("Entrance").uppercased())})
                                for node in FiletedNodes{
                                    RoomList.append(node.InformationStr)
                                }
                            }
                            
                        }
                        geoPosUpdated = false
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
