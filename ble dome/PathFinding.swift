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
    let geoPos : [Float]
    
    var PosStr : String {
        return "\(Floor == 0 ? "G/F" : "\(Floor)/F") | \(geoPos[0]) : \(geoPos[1])"
    }
}

struct Node: Identifiable, Hashable{
    let id : Int
    var Floor : Int
    let XY : [Float]
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
var NavTags = [NavTag]()

class PathFinding : ObservableObject {
    @Published var isNaving : Bool = false
    @Published var FlagSendCmd:  Bool = false
    @Published var RoutineFlow : Int = 0
    @Published var tagsCount :  Int = 0
    @Published var Tags = [tag]()
    @Published var TagsData = [tagData]()
    @Published var ExistedList = [GeoPos]()
    @Published var ExistedStr = [String]()
    @Published var geoPicker : Bool = false
    @Published var geoSelected : Int = 0
    @Published var NavTagLogs = [NavTagLog]()
    
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
        let HazardStrArray : [String] = ["Stairs","Entrance","Elevator","Crossroad","Straight"]
        let InformationStrArray : [String] = ["Room","Restroom","Aisle"]
        var data = readDataFromCSV(fileName: fileName, fileType: "csv")
        if data != nil{
            data = cleanRows(file: data!)
            let csvRows = csv(data: data!).compactMap({$0}).filter({$0.contains("") == false})
            for index in 1..<csvRows.count{
                let csvRow = csvRows[index]
                    let id : Int = Int(csvRow[0])!
                    let Floor : Int = Int(csvRow[1])!
                    let XY : [Float] = [Float(csvRow[7])!,Float(csvRow[8])!]
                    let geoPos : [Float] = [Float(csvRow[9])!,Float(csvRow[10])!]
                    let Hazard : UInt8 = UInt8(HazardStrArray.map({$0.uppercased()}).firstIndex(of: csvRow[2].uppercased())!)
                    let HazardSeq : [UInt8] = Int16(csvRow[3])!.bytes
                    let Addtional : UInt8 = UInt8(csvRow[4])!
                    let HazardArr : [UInt8] = [Hazard] + HazardSeq + [Addtional]
                    let Information : UInt8 = UInt8(InformationStrArray.map({$0.uppercased()}).firstIndex(of: csvRow[5].uppercased())!)
                    let InformationSeq : [UInt8] = Int16(csvRow[6])!.bytes
                    let InformationArr : [UInt8] = [Information] + InformationSeq
                    let Neighbors : [Int] = csvRow[11].components(separatedBy: ";").compactMap{Int($0)}
                    let node = Node(id: id, Floor: Floor, XY: XY, Hazard: HazardArr, Information: InformationArr, Neighbors: Neighbors)
                    let geo = GeoPos(Floor: Floor, geoPos: geoPos)
    //                print("\(id) | Floor: \(Floor)/F |XY: \(XY) | Pos: \(geoPos) | \(HazardArr) | \(InformationArr) | \(Neighbors)")
                    Nodes.append(node)
                    if !Pos.contains(geo) {
                        Pos.append(geo)
                    }
            }
        }
        if !(Nodes.isEmpty) && !(Pos.isEmpty){
            for pos in Pos {
                let NewNodes = Nodes.filter({$0.Floor == pos.Floor})
                NodesDict[pos] = NewNodes
                NodesToGrid(Pos: pos)
            }
        }
    }
    
    
    
    func NodesToGrid(Pos: GeoPos){
        let Nodes : [Node] = NodesDict[Pos] ?? []
        if !Nodes.isEmpty {
            let Grid = GKGraph()
            var GridNodes = [GKGraphNode]()
            for node in Nodes{
                GridNodes.append(GKGraphNode2D(point: vector_float2(node.XY[0], node.XY[1])))
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
            ExistedList.append(Pos)
            ExistedStr.append(Pos.PosStr)
            MapDict[Pos] = Grid
            GKNodeDict[Pos] = GridNodes
        }
    }
    
    func getPath(Pos: GeoPos, from: Int, to: Int) -> ([GKGraphNode2D], [Node]){
        var path = [GKGraphNode2D]()
        var NodesPath = [Node]()
        if MapDict[Pos] != nil && GKNodeDict[Pos] != nil {
            path = MapDict[Pos]!.findPath(from: GKNodeDict[Pos]![from], to: GKNodeDict[Pos]![to]) as! [GKGraphNode2D]
            let pathPoints: [vector_float2] = path.map{$0.position}
            if NodesDict[Pos] != nil{
                for point in pathPoints{
                    for node in NodesDict[Pos]!{
                        if node.XY[0] == point.x && node.XY[1] == point.y {
                            NodesPath.append(node)
                        }
                    }
                }
            }
            return (path, NodesPath)
        }
        return ([], [])
    }
    
    func FindNodes(Pos: GeoPos, to Item: String) -> [Int]{
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
    func FindNearest(Pos: GeoPos, from: Int ,to Items: [Int]) -> Int? {
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
    
    func PathEstimate(Path ShortestPath: [Node]) -> Int?{
    //    let Nodes : [Node] = NodesDict[Pos] ?? []
    //    var Direction = [Int]() // 0 : Forward, 1 : Backward, 2 : Leftward,,  3 : Rightward,
        var Distance : Double = 0
        if !ShortestPath.isEmpty{
            for index in 0..<ShortestPath.count - 1{
                let InterceptX : Float = ShortestPath[index + 1].XY[0] - ShortestPath[index].XY[0]
                let InterceptY : Float = ShortestPath[index + 1].XY[1] - ShortestPath[index].XY[1]
                Distance = Double(sqrt(pow(InterceptX, 2) + pow(InterceptY, 2)))
            }
            return Int(ceil(Distance * 0.85))
        }
        return nil
    }
    
    var HistoryPath = [Node]()
    var WrongPath = [NavTag]()

    func PathFollowing(NavTags: inout [NavTag], ShortestPath: [Node]) -> ([Node], Float?){
        if !NavTags.isEmpty && ShortestPath.count > 0 {
            print("Start")
//            if let currentTag = NavTags.max(by: {$0.RSSI < $1.RSSI}) {
//            var currentTag : NavTag?
//            if NavTags.filter({})
            var currentTag : NavTag?
            for node in ShortestPath {
                if let index = NavTags.firstIndex(where: {$0.XY == node.XY}){
                    currentTag = NavTags[index]
                    break
                }
                else{
                    currentTag = NavTags[NavTags.count - 1]
                }
            }
//            let currentTag = NavTags[NavTags.count - 1]
            if let CurrentTag = currentTag {
                print("got currentTag")
                let InterceptX : Float = CurrentTag.XY[0] - ShortestPath[0].XY[0]
                let InterceptY : Float = CurrentTag.XY[1] - ShortestPath[0].XY[1]
                let Distance = Double(sqrt(pow(InterceptX, 2) + pow(InterceptY, 2)))
                var UpdatedPath = ShortestPath
                if !ShortestPath.filter({$0.XY == CurrentTag.XY}).isEmpty{
                    print("On the Path")
                    WrongPath.removeAll()
                    if let NewStart = ShortestPath.firstIndex(where: {$0.XY == CurrentTag.XY}) {
                        UpdatedPath = Array(ShortestPath[(NewStart)...(ShortestPath.count - 1)])
                        HistoryPath.append(ShortestPath[NewStart])
                        print("Update Path and Store to History")
                    }
                    UpdatedPath = UpdatedPath.filter({$0.XY != CurrentTag.XY})
                    NavTags.removeAll()
                    if UpdatedPath.isEmpty{
                        HistoryPath.removeAll()
                    }
                    return (UpdatedPath, 0)
                }
                else{
                    if Distance > abs(1){
                        print("Distance > 0.5")
                        let Pos = GeoPos(Floor: CurrentTag.Floor, geoPos: CurrentTag.geoPos)
                        if let Nodes : [Node] = NodesDict[Pos] {
                            print("get Nodes")
                            if let Start = Nodes.firstIndex(where: {$0.Floor == CurrentTag.Floor && $0.XY == CurrentTag.XY}) {
                                print("get  Start Nodes")
                                let NewPath = getPath(Pos: Pos, from: Nodes[Start].id, to: ShortestPath[ShortestPath.count - 1].id).1
                                if WrongPath.count > 1{
                                    print("Wrong Path redierction")
                                    let FilteredWrongPath = WrongPath.filter({$0.XY != CurrentTag.XY})
                                    let PerivousNode = FilteredWrongPath[FilteredWrongPath.count - 1]
                                    let PreictTag = [Float(CurrentTag.XY[0] + CurrentTag.XY[0] - PerivousNode.XY[0]), Float(CurrentTag.XY[1] + CurrentTag.XY[1] - PerivousNode.XY[1])]
                                    let Direction = PathDirection(Current: CurrentTag.XY, Facing: PreictTag, Target: ShortestPath[0].XY)
        //                            WrongPath.removeAll()
                                    NavTags.removeAll()
                                    return (NewPath, Direction)
                                }
        //                        return (NewPath, nil)
                            }
                        }
                    }
                    if HistoryPath.count > 1{
                        print("HistoryPath.count > 1 ")
                        WrongPath.removeAll()
                        let FilteredHistoryPath = HistoryPath.filter({$0.XY != CurrentTag.XY})
                        let PerivousNode = FilteredHistoryPath[FilteredHistoryPath.count - 1]
                        let PreictTag = [Float(CurrentTag.XY[0] + CurrentTag.XY[0] - PerivousNode.XY[0]), Float(CurrentTag.XY[1] + CurrentTag.XY[1] - PerivousNode.XY[1])]
                        let Direction = PathDirection(Current: CurrentTag.XY, Facing: PreictTag, Target: ShortestPath[0].XY)
                        print("Direction: \(Direction) | \(Direction == 180 || Direction == -180 ? "Turn Back" : Direction < 0 ? "Turn Left" : Direction > 0 ? "Turn Right" : "Go Stright") | \(Direction)")
                        NavTags.removeAll()
                        return (ShortestPath, Direction)
                    }
                    else {
                        print("WrongPath")
                        if WrongPath.filter({$0.CRC == CurrentTag.CRC && $0.XY == CurrentTag.XY}).count < 1{
                            WrongPath.append(CurrentTag)
                        }
                        NavTags.removeAll()
                        return (ShortestPath, nil)
                    }
                }
            }
        }
        return (ShortestPath, nil)
    }

    
    func PathDirection(Current : [Float], Facing : [Float], Target: [Float]) -> Float{
        let FacingCart = [Float(Current[0] - Facing[0]), Float(Current[1] - Facing[1])]
        let FacingPolar = [Float(sqrt(pow(FacingCart[0],2) + pow(FacingCart[1],2))), atan( FacingCart[1] / FacingCart[0] ) * 180 / Float.pi]
        let TargetCart = [Float(Current[0] - Target[0]), Float(Current[1] - Target[1])]
        let TargetPolar = [Float(sqrt(pow(TargetCart[0],2) + pow(TargetCart[1],2))), atan( TargetCart[1] / TargetCart[0] ) * 180 / Float.pi]
        let DirectionPolar = [FacingPolar[0] - TargetPolar[0], FacingPolar[1] - TargetPolar[1]]
        let Direction = DirectionPolar[1]
        return Direction
    }
}


