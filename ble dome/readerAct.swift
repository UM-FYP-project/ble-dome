//
//  readerAct.swift
//  ble dome
//
//  Created by UM on 13/04/2021.
//

import Foundation

class readerAct: ObservableObject{
    @Published var isInventory = false // Reader Inverntorying or not
    @Published var RealtimeInventory_Toggle = false // Reader Inverntorying in Realtime or not
    @Published var MatchState : Int = 0// 0: Match, 1: Matching, 2: Matched, 3: UnMactching
    // Reader Setting Picker
    let BaudrateCmdinStr : [String] = ["9600bps", "19200bps", "38400bps", "115200bps"]
    let BaudrateCmdinByte : [UInt8] = [0x01, 0x02 , 0x03, 0x04]
    let Outpower : [Int] = [20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    @Published var SelectedBaudrate = 3
    @Published var SelectedBaudrate_picker = false
    @Published var SelectedPower = 13
    @Published var SelectedPower_picker = false
    // Reader inventory Picker
//    let inventorySpeed = Array(1...255)
//    @Published var inventorySpeed_Selected = 254
//    @Published var inventorySpeed_picker = false
    @Published var inventorySpeed = 255
    // Reader Data Picker
    let DataCmdinStr = ["RESERVED", "EPC", "TAG ID", "USER DATA"]
    let DataCmdinByte :[UInt8] = [0x00, 0x01, 0x02, 0x03]
//    let DataByte = Array(0...255)
    @Published var DataBlock_picker = false
    @Published var DataBlock_Selected = 1
    @Published var DataStart = 2
    @Published var DataLen = 22
//    @Published var DataStart_picker = false
//    @Published var DataStart_Selected = 2
//    @Published var DataLen_picker = false
//    @Published var DataLen_Selected = 20
    //EPC match Picker
    @Published var EPC_picker = false
    @Published var EPC_Selected = 0
    //Write tag
    @Published var Xcoordinate : String = "0.0"
    @Published var Ycoordinate : String = "0.0"
    @Published var floor : Int = 0
    @Published var Seq : UInt = 0
}
