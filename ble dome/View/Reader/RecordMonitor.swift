//
//  RecordMonitor.swift
//  ble dome
//
//  Created by UM on 07/05/2021.
//

import SwiftUI

struct RecordMonitor: View {
    @EnvironmentObject var reader:Reader
    var geometry : GeometryProxy
    var body: some View {
        //        GeometryReader{ geometry in
//        ZStack{
            VStack{
                VStack{
                    Text("*BLUE is Sent Data")
                        .foregroundColor(.blue)
                    Spacer()
                    Text("*RED is Received Data")
                        .foregroundColor(.red)
                }
                .frame(width: geometry.size.width - 20)
                if !BytesRecord.isEmpty {
                    ForEach (0..<BytesRecord.count, id: \.self){ index in
                        let record = BytesRecord[BytesRecord.count - 1 - index ]
                        let byteStr = Data(record.Byte).hexEncodedString()
                        HStack{
                            Text("\(record.Time):")
                            Spacer()
                            Text(byteStr)
                                .foregroundColor(record.Defined == 1 ? .blue : .red)
                        }
                        Divider()
                    }
                }
                Spacer()
                Divider()
                Button(action: {
                    BytesRecord.removeAll()
                }) {
                    Text("Clear Log")
                        .font(.headline)
                }
                .frame(width: geometry.size.width - 20, height: 30, alignment: .center)
                Spacer()
            }
            .frame(width: geometry.size.width - 20)
//        }
//        .frame(width: geometry.size.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
}

