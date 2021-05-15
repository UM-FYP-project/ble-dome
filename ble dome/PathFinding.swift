//
//  PathFinding.swift
//  ble dome
//
//  Created by UM on 09/05/2021.
//

import Foundation
import GameplayKit

struct GeoPos: Hashable{
    let Floor : Int
    let Lag : Float
    let Long : Float
}

struct Node: Identifiable, Hashable {
    let id : Int
    let Floor : Int
    let X : Float
    let Y : Float
    let Hazard : [UInt8]
    let Information : [UInt8]
    let Neighbors : [Int]
    
    var HazardStr : String {
        let HazardStrArray : [String] = ["Stairs","Entrance","Elevator","Crossroad","Straight"]
        let SeqInt : Int = Int(Data(Array(Hazard[1...2])).withUnsafeBytes({$0.load(as: UInt16.self)}).bigEndian)
        let AddtionalStr : String = "\(Hazard[0] == 0 ? "\tStep:\(Int(Hazard[3]))" : Hazard[3] > 0 ? "| \(Int(Hazard[3]))" : "")"
        let Str : String = HazardStrArray[Int(Hazard[0])] + "\(SeqInt)" + AddtionalStr
        return Str
    }
    
    var InformationStr : String {
        let InformationStrArray : [String] = ["Room","Restroom","Aisle"]
        let SeqInt : Int = Int(Data(Array(Information[1...2])).withUnsafeBytes({$0.load(as: UInt16.self)}).bigEndian)
        let Str : String = InformationStrArray[Int(Information[0])] + "\(SeqInt)"
        return Str
    }
}

var MapDict = [GeoPos : GKGraph]()
var NodesDict = [GeoPos : [Node]]()
var GKNodeDict = [GeoPos : [GKGraphNode]]()

class PathFinding : ObservableObject {
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
        else {
            return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    func CSV2Dict(fileName : String){
        var Pos = [GeoPos]()
        var Nodes = [Node]()
        var data = readDataFromCSV(fileName: fileName, fileType: "csv")
        let HazardStrArray : [String] = ["Stairs","Entrance","Elevator","Crossroad","Straight"]
        let InformationStrArray : [String] = ["Room","Restroom","Aisle"]
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        
        for index in 1..<csvRows.count{
            let csvRow = csvRows[index]
            if csvRow[11] == ""{
                break
            }
            else{
                let id : Int = Int(csvRow[0])!
                let Floor : Int = Int(csvRow[1])!
                let X : Float = Float(csvRow[7])!
                let Y : Float = Float(csvRow[8])!
                let Lag : Float = Float(csvRow[9])!
                let Long : Float = Float(csvRow[10])!
                let Hazard : UInt8 = UInt8(HazardStrArray.map({$0.uppercased()}).firstIndex(of: csvRow[2].uppercased())!)
                let HazardSeq : [UInt8] = Int16(csvRow[3])!.bytes
                let Addtional : UInt8 = UInt8(csvRow[4])!
                let HazardArr : [UInt8] = [Hazard] + HazardSeq + [Addtional]
                let Information : UInt8 = UInt8(InformationStrArray.map({$0.uppercased()}).firstIndex(of: csvRow[5].uppercased())!)
                let InformationSeq : [UInt8] = Int16(csvRow[6])!.bytes
                let InformationArr : [UInt8] = [Information] + InformationSeq
                let Neighbors : [Int] = csvRow[11].components(separatedBy: ";").compactMap{Int($0)}
                let node = Node(id: id, Floor: Floor, X: X, Y: Y, Hazard: HazardArr, Information: InformationArr, Neighbors: Neighbors)
                let geo = GeoPos(Floor: Floor, Lag: Lag, Long: Long)
                Nodes.append(node)
                if !Pos.contains(geo) {
                    Pos.append(geo)
                }
            }
        }
        if !(Nodes.isEmpty) && !(Pos.isEmpty){
            for pos in Pos {
                let Floor = pos.Floor
                let FirstIndex = Nodes.firstIndex(where: {$0.Floor == Floor})
                let LastIndex = Nodes.lastIndex(where: {$0.Floor == Floor})
                if FirstIndex != nil && LastIndex != nil {
                    NodesDict[pos] = Array(Nodes[FirstIndex!...LastIndex!])
                    NodesToGrid(Pos: pos)
                }
            }
        }
    }
    
    func NodesToGrid(Pos: GeoPos){
        let Nodes : [Node] = NodesDict[Pos] ?? []
        if !Nodes.isEmpty {
            let Grid = GKGraph()
            var GridNodes = [GKGraphNode]()
            for node in Nodes{
                GridNodes.append(GKGraphNode2D(point: vector_float2(node.X, node.Y)))
            }
            Grid.add(GridNodes)
            for node in Nodes{
                var connection = [GKGraphNode]()
                if !node.Neighbors.isEmpty{
                    for index in node.Neighbors{
                        connection.append(GridNodes[index])
                    }
                    GridNodes[node.id].addConnections(to: connection, bidirectional: true)
                }
            }
            MapDict[Pos] = Grid
            GKNodeDict[Pos] = GridNodes
        }
    }
    
    func getPath(Pos: GeoPos, from: Int, to: Int) -> ([GKGraphNode2D], [Int]){
        var path = [GKGraphNode2D]()
        var pathID = [Int]()
        if MapDict[Pos] != nil && GKNodeDict[Pos] != nil{
            path = MapDict[Pos]!.findPath(from: GKNodeDict[Pos]![from], to: GKNodeDict[Pos]![to]) as! [GKGraphNode2D]
            let pathPoints: [vector_float2] = path.map{$0.position}
            if NodesDict[Pos] != nil{
                for point in pathPoints{
                    for node in NodesDict[Pos]!{
                        if node.X == point.x && node.Y == point.y {
                            pathID.append(node.id)
                        }
                    }
                }
            }
            return (path, pathID)
        }
        return ([], [])
    }
    
    func FindNode(Pos: GeoPos, to Item: String) -> [Int]{
        var Indexs = [Int]()
        let Nodes : [Node] = NodesDict[Pos] ?? []
        if !Nodes.isEmpty{
            for node in Nodes{
                if node.HazardStr.uppercased().contains(Item.uppercased()) {
                    Indexs.append(node.id)
                }
                if node.InformationStr.uppercased().contains(Item.uppercased()) {
                    Indexs.append(node.id)
                }
            }
            return Indexs
        }
        return []
    }
    //
    func FindClosedNode(Pos: GeoPos, from: Int ,to Items: [Int]) -> Int? {
        var Cost : Float = 1000000
        var ClosedNode : Int?
        let Grip : [GKGraphNode] = GKNodeDict[Pos] ?? []
        if !Grip.isEmpty{
            for item in Items {
                if from != item {
                    let cost = Grip[from].cost(to: Grip[item])
                    if Cost > cost {
                        Cost = cost
                        ClosedNode = item
                    }
                }
            }
            if ClosedNode != nil{
                return ClosedNode
            }
        }
        return nil
    }
    
    
}
