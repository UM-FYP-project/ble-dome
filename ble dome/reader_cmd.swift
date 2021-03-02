//
//  reader_cmd.swift
//  ble dome
//
//  Created by UM on 22/02/2021.
//

import Foundation
import CoreBluetooth

let address : UInt8 = 0xFE


struct byte_record: Identifiable{
    let id : Int
    let Time : Double
    let Time_string : String
    let Defined : Int
    let Byte : [UInt8]
}

struct tag: Identifiable{
    let id : Int
    let EPC_Len : UInt8
    let EPC : [UInt8]
    let EPC_str : String
    var RSSI_byte : UInt8
    var RSSI_int : Int
    var Count : Int
    var Data_Len : UInt8?
    var Data : [UInt8]
}

var Byte_Record = [byte_record]()

class Reader: NSObject, ObservableObject{
    @Published var Tags = [tag]()
    @Published var Realtime_Tags = [tag]()
    @Published var tagsCount : Int = 0
    
    func cmd_reset () -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x03, address, 0x70, 0xEF]
        Tags.removeAll()
        return cmd
    }

    func cmd_set_baudrate (baudrate_para:UInt8) -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x04, address, 0x71, baudrate_para]
        return cmd
    }
    
    func cmd_set_output_power (output_power:Int) -> [UInt8]{
        let power_uint8 = UInt8(output_power)
        let cmd : [UInt8] = [0xA0, 0x04, address, 0x76, power_uint8]
        return cmd
    }
    
    func cmd_get_output_power () -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x03, address, 0x77]
        return cmd
    }
    
    func cmd_set_freq_region (Spec_region:UInt8, Start_freq:UInt8, End_freq:UInt8) -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x06, address, 0x78, Spec_region, Start_freq, End_freq]
        return cmd
    }
    
    func cmd_get_freq_region () -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x03, address, 0x79]
        return cmd
    }

    func cmd_set_alert_mode (alert_mode:UInt8) -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x04, address, 0x7A, alert_mode]
        return cmd
    }
    
    func cmd_inventory (inventory_speed:UInt8) -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x04, address, 0x80, inventory_speed]
        return cmd
    }
    
    func cmd_data_read (data_block:UInt8, data_start:UInt8, data_len:UInt8) -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x06, address, 0x81, data_block, data_start, (data_len / 2)]
        return cmd
    }
    
    func cmd_data_write (data_block:UInt8, data_start:UInt8, data:[UInt8]) -> [UInt8]{
        let cmd_len : UInt8 = 0x07 + UInt8(data.count)
        let data_len : UInt8 = UInt8(data.count / 2)
        let cmd : [UInt8] = [0xA0, cmd_len, address, 0x82, data_block, data_start, data_len] + data
        return cmd
    }
    
    func cmd_data_lock (data_password:[UInt8], data_locktype:UInt8, data_block:UInt8) -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x09, address, 0x83, data_password[0], data_password[1], data_password[2], data_password[3], data_block, data_locktype]
        return cmd
    }
    
    func cmd_kill_password (data_password:[UInt8]) -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x07, address, 0x84, data_password[0], data_password[1], data_password[2], data_password[3]]
        return cmd
    }
    
    func cmd_EPC_match (setEPC_mode:UInt8, EPC:[UInt8]) -> [UInt8]{
        let cmd_len : UInt8 = 0x06 + UInt8(EPC.count)
        let EPC_len : UInt8 = UInt8(EPC.count / 2)
        let cmd : [UInt8] = [0xA0, cmd_len, address, 0x85, setEPC_mode, EPC_len] + EPC
        return cmd
    }
    
    func cmd_real_time_inventory (inventory_speed:UInt8) -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x04, address, 0x89, inventory_speed]
        return cmd
    }
    
    func cmd_get_inventory_buffer () -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x03, address, 0x90]
        return cmd
    }
    
    func cmd_getandclear_inventory_buffer () -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x03, address, 0x91]
        return cmd
    }
    
    func cmd_inventory_buffer_count () -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x03, address, 0x92]
        return cmd
    }
    
    func cmd_clear_inventory_buffer () -> [UInt8]{
        let cmd : [UInt8] = [0xA0, 0x03, address, 0x93]
        Tags.removeAll()
        return cmd
    }

    func reader_error_code(code:UInt8) -> String{
        let error_code : [UInt8:String] = [
            0x10:"Command Success",
            0x11:"Command Fail",
            0x20:"MCU reset error",
            0x21:"Turn on CW error",
            0x22:"Antenna is missing",
            0x23:"Write Flash error",
            0x24:"Read Flash error",
            0x25:"Set Output power error",
            0x31:"Error occurred when inventory",
            0x32:"Error occurred when read",
            0x33:"Error occurred when write",
            0x34:"Error occurred when lock",
            0x35:"Error occurred when kill",
            0x36:"There is no tag to be operated",
            0x37:"Tag Inventoried but access failed",
            0x38:"Buffer is empty",
            0x40:"Access failed or Wrong password",
            0x41:"Invalid Parameter",
            0x42:"WordCnt is too long",
            0x43:"MemBank out of Range",
            0x44:"Lock region out of range",
            0x45:"LockType out of range",
            0x46:"Invaild reader address",
            0x47:"Antenna_ID out of range",
            0x48:"Output power out of range",
            0x49:"Frequency region out of range",
            0x4A:"Baud rate out of rage",
            0x4B:"Buzzer behavior out rage",
            0x4C:"EPC match is too long",
            0x4D:"EPC match length wrong",
            0x4E:"Invalid EPC match mode",
            0x4F:"Invalid frequency rage",
            0x50:"Failed to receive RN16 from tag",
            0x51:"Invalid DRM mode",
            0x52:"PLL can not lock",
            0x53:"No response from RF chip",
            0x54:"Can't achieve desired output power level",
            0x55:"Can't authenticate firmware copyright",
            0x56:"Spectrum requlation wrong",
            0x57:"Output power is too low"
        ]
        return error_code[code] ?? "nil"
    }
        
    func reader_freq(freq:Any) -> Any {
        var return_var : Any?
        let freq_code : [Float:UInt8] = [
            865:0x0,865.5:0x1,866:0x2,866.5:0x3,867:0x4,867.5:0x5,868:0x6,902:0x7,902.5:0x8,903:0x9,
            903.5:0xA,904:0xB,904.5:0xC,905:0xD,905.5:0xE,906:0xF,
            906.5:0x10,907:0x11,907.5:0x12,908:0x13,908.5:0x14,909:0x15,909.5:0x16,910:0x17,910.5:0x18,911:0x19,
            911.5:0x1A,912:0x1B,912.5:0x1C,913:0x1D,913.5:0x1E,914:0x1F,
            914.5:0x20,915:0x21,915.5:0x22,916:0x23,916.5:0x24,917:0x25,917.5:0x26,918:0x27,918.5:0x28,919:0x29,
            919.5:0x2A,920:0x2B,920.5:0x2C,921:0x2D,921.5:0x2E,922:0x2F,
            922.5:0x30,923:0x31,923.5:0x32,924:0x33,924.5:0x34,925:0x35,925.5:0x36,926:0x37,926.5:0x38,927:0x39,
            927.5:0x3A,928:0x3B
        ]
        if  freq is Float{
            let key = freq as! Float
            return_var = freq_code[key] as Any
        }
        else if freq is UInt8{
            let Dict = freq as! UInt8
            return_var = freq_code.findKey(forValue: Dict) as Any
        }
        return return_var!
    }
    
    func feedback_get_output_power(feedback:[UInt8]) -> Int{
        var outpower : Int = 0
        if feedback.count > 4 {
            if feedback[1] == 0x04 && feedback[3] == 0x77{
                outpower = Int(feedback[4])
            }
        }
        return outpower
    }
    
    func feedback_Inventory(feedback:[UInt8]) -> (Int, String){
        var tagcount = 0
        var Error_String = "nil"
        if feedback.count > 5 {
            if feedback[1] == 0x0C && feedback[3] == 0x80{
                tagcount = Int(feedback[5] * UInt8(Int(100)) + feedback[6])
            }
            else if feedback[1] == 0x04 && feedback[3] == 0x80{
                Error_String = reader_error_code(code: feedback[4])
            }
        }
        return (tagcount, Error_String)
    }
    
    
    func feedback_Tags(feedback:[UInt8]) -> [String]{
        var Error_String = [String]()
        var feedback2D = [[UInt8]]()
        for var index in 0..<feedback.count {
            if feedback[index] == 0xA0 && feedback[index + 2] == 0xFE{
                var feedbackof2D = [UInt8]()
                feedbackof2D.append(contentsOf: feedback[index...(Int(feedback[index + 1]) + 1 + index)])
                feedback2D.append(feedbackof2D)
                //print("\(feedback2D.count)| BufferLen:\(Int(feedback[index + 1]) + 2) | \(Data(feedbackof2D).hexEncodedString())")
                index += (Int(feedback[index + 1]) + 1)
            }
        }
        for Index in 0..<feedback2D.count {
            if feedback2D[Index].count > 5 {
                if feedback2D[Index][1] != 0x04 && feedback2D[Index][3] == 0x90{
                    Btye_Recorder(defined: 2, byte: feedback2D[Index])
                    var EPC = [UInt8]()
                    let EPC_Len = feedback2D[Index][6]
                    EPC.append(contentsOf: feedback2D[Index][7...(Int(EPC_Len) + 6)])
                    let EPC_str = Data(EPC).hexEncodedString()
                    let RSSI_btye = feedback2D[Index][(Int(EPC_Len) + 7)]
                    let Count = Int(feedback2D[Index][Int(EPC_Len) + 9])
                    if Tags.filter({$0.EPC == EPC}).count < 1{
                        let Tag = tag(id: Tags.count, EPC_Len: EPC_Len, EPC: EPC, EPC_str: EPC_str, RSSI_byte
                                        : RSSI_btye, RSSI_int: Int(RSSI_btye) - 130, Count: Count, Data_Len: nil, Data: [])
                        Tags.append(Tag)
                        print(Tag)
                    }
                    else{
                        if let index = Tags.firstIndex(where: {$0.EPC == EPC}){
                            Tags[index].Count = Count
                            Tags[index].RSSI_byte = RSSI_btye
                            Tags[index].RSSI_int = Int(RSSI_btye) - 130
                        }
                    }
                }
                else if feedback[1] == 0x04 && feedback2D[Index][3] == 0x90 {
                    Error_String.append(reader_error_code(code: feedback[4]))
                }
                if feedback2D[Index][1] != 0x04 && feedback2D[Index][3] == 0x81{
                    Btye_Recorder(defined: 2, byte: feedback2D[Index])
                    var EPC = [UInt8]()
                    var ReadData = [UInt8]()
                    let totalData_len = feedback2D[Index][6]
                    let ReadData_len = feedback2D[Index][(Int(feedback2D[Index][1]) - 2)]
                    let EPC_Len = totalData_len - ReadData_len
                    EPC.append(contentsOf: feedback2D[Index][7...(Int(EPC_Len) + 6)])
                    ReadData.append(contentsOf: feedback2D[Index][(Int(EPC_Len) + 7)...(Int(totalData_len + 6))])
                    if let index = Tags.firstIndex(where: {$0.EPC == EPC}){
                        Tags[index].Data_Len = ReadData_len
                        Tags[index].Data = ReadData
                        print(Tags[index])
                    }
                }
            }
        }
        return Error_String
    }

    func Btye_Recorder(defined: Int, byte:[UInt8]){
        if Byte_Record.count > 30 {
            Byte_Record.removeAll()
        }
        let current_time = Date()
        let millis : Double = current_time.timeIntervalSince1970
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "(Z'Z')MM-dd_'T'HH:mm:ss.SSS"
        let time_string = formatter.string(from: current_time)
        let record = byte_record(id: Byte_Record.count, Time: millis, Time_string: time_string, Defined: defined, Byte: byte)
        Byte_Record.append(record)
        print("T_\(millis)_\(byte)")
    }
}

extension Dictionary where Value: Equatable {
    func findKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

extension BLE{
    func cmd2reader(cmd:[UInt8]) {
        let reader_serivce : CBUUID = CBUUID(string: "0x2A68")
        let reader_write_char : CBUUID = CBUUID(string: "0x7269")
        let connected_state = 2
        let CmdData : Data = Data(cmd)
        print("*****Send Cmd to Reader*****")
        if let char_index = Peripheral_characteristics.firstIndex(where: {$0.Services_UUID == reader_serivce && $0.Characteristic_UUID == reader_write_char}){
            if let peripheral_index = peripherals.firstIndex(where: {$0.name == Peripheral_characteristics[char_index].name && $0.State == connected_state}){
                writeValue(value: CmdData, characteristic: Peripheral_characteristics[char_index].Characteristic, peripheral: peripherals[peripheral_index].Peripheral)
            }
        }
        Reader().Btye_Recorder(defined: 1, byte: cmd)
    }
    
    func reader2BLE(record: Bool) -> [UInt8]{
        let reader_serivce : CBUUID = CBUUID(string: "2A68")
        let reader_write_char : CBUUID = CBUUID(string: "726F")
        var feedback = [UInt8]()
        if let char_index = Peripheral_characteristics.firstIndex(where: {$0.Services_UUID == reader_serivce && $0.Characteristic_UUID == reader_write_char}){
            feedback = Peripheral_characteristics[char_index].value
        }
        if record{
            print("*****Reader Feedback*****")
            Reader().Btye_Recorder(defined: 2, byte: feedback)
        }
        return feedback
    }
}