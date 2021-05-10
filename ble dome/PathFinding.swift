//
//  PathFinding.swift
//  ble dome
//
//  Created by UM on 09/05/2021.
//

import Foundation
import GameplayKit

struct GeoPos: Hashable{
    let Lag : Float
    let Long : Float
}

struct Node: Identifiable, Hashable {
    let id : Int
    let X : Float
    let Y : Float
    let Hazard : [UInt8]
    let Infor : [UInt8]
    let Neighbors : [Int]
    
    
}

var MapDict = [GeoPos : GKGraph]()
var GKNodeDict = [GeoPos : [GKGraphNode]]()

class PathFinding : ObservableObject {
    
    func NodeToGrid(Pos: GeoPos){
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
    
}
