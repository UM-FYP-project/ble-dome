//
//  ReaderSetting.swift
//  ble dome
//
//  Created by UM on 07/05/2021.
//

import SwiftUI

struct ReaderSetting: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @EnvironmentObject var readeract : readerAct
    var geometry : GeometryProxy
    @State var Outpower_feedback : Int?
    @State var ErrorStr = [String]()
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                HStack{
                    Text("Reset Reader")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        let cmd = reader.cmd_reset()
                        cmdtransitor(cmd: cmd)
                    }) {
                        Text("Reset")
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }
                .frame(width: geometry.size.width - 20)
                Divider()
                HStack{
                    Text("Set Baudrate")
                        .font(.headline)
                    Spacer()
                    Text("\(readeract.BaudrateCmdinStr[readeract.SelectedBaudrate])")
                        .font(.headline)
                        .frame(width: 120, height: 30)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                        .onTapGesture {
                            readeract.SelectedBaudrate_picker = true
                        }
                    Button(action: {
                        let cmd : [UInt8] = reader.cmd_set_baudrate(baudrate_para: readeract.BaudrateCmdinByte[readeract.SelectedBaudrate])
                        //                            var feedback = [UInt8]()
                        cmdtransitor(cmd: cmd)
                        //                            ble.cmd2reader(cmd: cmd)
                        //                            reader.Btye_Recorder(defined: 1, byte: cmd)
                    }) {
                        Text("Set")
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }
                .frame(width: geometry.size.width - 20)
                Divider()
                HStack{
                    Text("Set Power")
                        .font(.headline)
                        .frame(width: 120, height: 30,alignment: .leading)
                    Spacer()
                    Text("\(readeract.Outpower[readeract.SelectedPower])dBm")
                        .font(.headline)
                        .frame(width: 120, height: 30)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                        .onTapGesture {
                            readeract.SelectedPower_picker = true
                        }
                    Button(action: {
                        let cmd : [UInt8] = reader.cmd_set_output_power(output_power: readeract.Outpower[readeract.SelectedPower])
                        cmdtransitor(cmd: cmd)
                    }) {
                        Text("Set")
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }
                .frame(width: geometry.size.width - 20)
                Divider()
                HStack{
                    Text("Get Power")
                        .font(.headline)
                        .frame(width: 120, height: 30,alignment: .leading)
                    Spacer()
                    if Outpower_feedback != nil {
                        Text(ble.peripherals.filter({$0.State == 2}).count < 1 ? "" : "\(Outpower_feedback!)dBm")
                            .frame(width: 120, height: 30, alignment: .center)
                            .font(.headline)
                    }
                    else{
                        Text("")
                            .frame(width: 120, height: 30, alignment: .center)
                    }
                    Button(action: {
                        let cmd : [UInt8] = reader.cmd_get_output_power()
                        cmdtransitor(cmd: cmd)
                    }) {
                        Text("Get")
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }
                .frame(width: geometry.size.width - 20)
                Divider()
                ErrorList
                Spacer()
            }
            //                .frame(width: geometry.size.width - 20)
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
    
    var ErrorList: some View {
        List{
            if !ErrorStr.isEmpty{
                ForEach (0..<ErrorStr.count, id: \.self){ index in
                    Text(ErrorStr[ErrorStr.count - 1 - index])
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    func cmdtransitor(cmd: [UInt8]){
        var flag : Bool = false
        var readState : Bool = false
        var counter : Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){timer in
            if !flag{
                ble.cmd2reader(cmd: cmd)
                reader.Btye_Recorder(defined: 1, byte: cmd)
                flag = true
            }
            if ble.ValueUpated_2A68{
                print("ValueUpated_2A68")
                let feedback = ble.reader2BLE()
                reader.Btye_Recorder(defined: 2, byte: feedback)
                if feedback[0] == 0xA0 && feedback[2] == 0xFE {
                    if feedback[3] == 0x70 || feedback[3] == 0x71 || feedback[3] == 0x76{
                        let Error = reader.reader_error_code(code: feedback[Int(feedback[1])])
                        if ErrorStr.count > 5 {
                            ErrorStr.removeAll()
                        }
                        ErrorStr.append(feedback[3] == 0x70 ? "Reset:" + Error : feedback[3] == 0x71 ? "SetBaudrate:" + Error : "SetPower:" + Error)
                    }
                    else if feedback[3] == 0x77 {
                        Outpower_feedback = reader.feedback_get_output_power(feedback: feedback)
                    }
                    readState = true
                }
                ble.ValueUpated_2A68 = false
            }
            counter += 1
            if counter > 20 || readState{
                timer.invalidate()
            }
        }
    }
}
