//
//  RoomPicker.swift
//  ble dome
//
//  Created by UM on 18/05/2021.
//

import SwiftUI

struct RoomPicker: View {
//    @Binding var Enable : Bool
    var geometry : GeometryProxy
    @EnvironmentObject var path : PathFinding
    var body: some View {
        VStack{
            VStack{
                Text("Room Selection")
                    .bold()
                    .font(.title2)
                Text("Navigate to Selected Room")
            }
            .padding()
            .clipped()
            Divider()
            Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                Text("Close")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
//            .padding()
            .frame(width: geometry.size.width - 60, height: 50)

        }
        .background(RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(UIColor.systemGray6)).shadow(radius: 1))
        .frame(maxWidth: geometry.size.width - 60, maxHeight: geometry.size.height - 300)
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

    }
}

struct RoomPicker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            RoomPicker(geometry: geometry)
                .environmentObject(PathFinding())
        }
        
    }
}
