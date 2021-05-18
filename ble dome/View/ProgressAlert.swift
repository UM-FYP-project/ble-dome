//
//  ProgressAlert.swift
//  ble dome
//
//  Created by UM on 18/05/2021.
//

import SwiftUI

struct ProgressAlert: View {
    var geometry : GeometryProxy
    var body: some View {
        ZStack{
            VStack{
                ProgressView("Loading Path")
                    .frame(width: geometry.size.width - 200, height: geometry.size.width - 200)
                    .background(RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(UIColor.systemGray6)).shadow(radius: 1))
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct ProgressAlert_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ProgressAlert(geometry: geometry)
        }
    }
}
