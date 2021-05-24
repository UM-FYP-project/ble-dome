//
//  NavValue.swift
//  ble dome
//
//  Created by UM on 20/05/2021.
//

import Foundation

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

struct Room : Identifiable {
    let id : Int
    let RoomStr : String
    let Path : [Node]
}

class navValue : ObservableObject{
    @Published var CurrentLocation : NavChar?
    @Published var geoPosUpdated : Bool = false
    @Published var geoPos : GeoPos? = nil {
        willSet {
            if newValue != geoPos {
                geoPosUpdated = true
            }
        }
    }
    
    @Published var Current_ShortestPath = [Node]()
    @Published var RoomPicker_Enable = false
    @Published var RoomsList = [Room]()
    @Published var AlertState : Bool = false
    @Published var AlertStr : String = ""
}

