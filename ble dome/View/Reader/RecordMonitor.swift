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
        ZStack{
            VStack{
                if !reader.BytesRecord.isEmpty {
                    ForEach (0..<reader.BytesRecord.count, id: \.self){ index in
                        let record = reader.BytesRecord[reader.BytesRecord.count - 1 - index ]
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
            }
            .frame(width: geometry.size.width - 20)
        }
        .frame(width: geometry.size.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
}

