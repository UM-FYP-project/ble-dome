//
//  NavMain.swift
//  ble dome
//
//  Created by UM on 11/05/2021.
//

struct NavButton : Identifiable{
    let id : Int
    let imageStr : String
    let Text : String
}

import SwiftUI
import CoreBluetooth

struct NavMain: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var path : PathFinding
    @State var Floor : Int? = nil
    @State var InformationStr : String = ""
    @State var geoPos : GeoPos? = nil
    @State var AlertState : Bool = false
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
                Image("pin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                Text("Current\nLocation")
                    .font(.title3)
                Spacer()
                VStack{
                    Text("\(InformationStr)")
                        .font(.title3)
                        .frame(height: 40)
                        .frame(maxWidth: 300)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
//                    Spacer()
//                    Text("Outdoor")
//                        .font(.title3)
//                        .frame(height: 40)
//                        .frame(maxWidth: 300)
//                        .background(Color.gray.opacity(0.15))
//                        .cornerRadius(10)
                }
            }
            .frame(width: geometry.size.width - 20, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            ScrollView{
                Spacer()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 50) {
                    ForEach(NavButtons, id: \.id) { navbutton in
                        Button(action: {
                            ButtonPressedNum = navbutton.id
                            AlertState.toggle()
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
            geoPos = GeoPos(Floor: 2, Lag: Float(22.211006), Long: Float(113.55492))
            let fileName = String(geoPos!.Lag) + "," + String(geoPos!.Long)
            path.CSV2Dict(fileName: fileName)
        })
        .alert(isPresented: $AlertState){
            switch ButtonPressedNum {
            case 1:
                return Alert(
                    title: Text("Write Data to Tag"),
                    message: Text("Please Confirm the Data\n\n"),
                    primaryButton:
                        .cancel(),
                    secondaryButton:
                        .default(
                            Text("Confirm to Write"),
                            action: {
//                                WirtetoTag()
                            }
                        )
                )
            default:
                return Alert(
                    title: Text("Write Data to Tag"),
                    message: Text("Please Confirm the Data\n\n"),
                    primaryButton:
                        .cancel(),
                    secondaryButton:
                        .default(
                            Text("Confirm to Write"),
                            action: {
//                                WirtetoTag()
                            }
                        )
                )
            }
        }
    }
    
    func navButton(){
        
    }
    
    func getPosFromBLE(){
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true){timer in
            let Serivce : CBUUID = CBUUID(string: "2A68")
            let Char : CBUUID = CBUUID(string: "5677")
            var Pos = [UInt8]()
            Pos = ble.BLEReadValue(Serivce: Serivce, Characteristic: Char)
            if !Pos.isEmpty{
                if Pos.count > 11 {
                    let floor = Data(Array(Pos[0...1])).withUnsafeBytes({$0.load(as: Int.self)}).bigEndian
                    Floor = floor
                    InformationStr = "\(Pos[2] == 0 ? "Room" : Pos[2] == 1 ? "Restroom" : "Aisle")" +
                        "\(Data(Array(Pos[3...4])).withUnsafeBytes({$0.load(as: Int.self)}))"
                    geoPos = GeoPos(Floor: floor, Lag: Data(Array(Pos[5...8])).withUnsafeBytes({$0.load(as: Float.self)}), Long: Data(Array(Pos[9...12])).withUnsafeBytes({$0.load(as: Float.self)}))
                    let fileName = String(geoPos!.Lag) + "," + String(geoPos!.Long)
                    path.CSV2Dict(fileName: fileName)
                }
            }
//            if !ble.peripherals.isEmpty{
//                if !ble.Peripheral_characteristics.isEmpty{
//                    if let CharIndex = ble.Peripheral_characteristics.firstIndex(where: {$0.Services_UUID == Serivce && $0.Characteristic_UUID == Char}){
//                        Pos = ble.Peripheral_characteristics[CharIndex].value
//                        if Pos.count > 11 {
//                            let floor = Data(Array(Pos[0...1])).withUnsafeBytes({$0.load(as: Int.self)}).bigEndian
//                            Floor = floor
//                            InformationStr = "\(Pos[2] == 0 ? "Room" : Pos[2] == 1 ? "Restroom" : "Aisle")" +
//                                "\(Data(Array(Pos[3...4])).withUnsafeBytes({$0.load(as: Int.self)}))"
//                            geoPos = GeoPos(Floor: floor, Lag: Data(Array(Pos[5...8])).withUnsafeBytes({$0.load(as: Float.self)}), Long: Data(Array(Pos[9...12])).withUnsafeBytes({$0.load(as: Float.self)}))
//                            let fileName = String(geoPos!.Lag) + "," + String(geoPos!.Long)
//                            path.CSV2Dict(fileName: fileName)
//                        }
//                    }
//                }
//            }
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
