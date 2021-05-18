//
//  DirectionView.swift
//  ble dome
//
//  Created by UM on 18/05/2021.
//

import SwiftUI

struct DirectionView: View {
    var geometry : GeometryProxy
    var body: some View {
        Image(systemName: "location.north.line.fill")
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(0))
            .foregroundColor(Color(UIColor.systemTeal))
            .frame(width: geometry.size.width - 100, height: geometry.size.width - 100)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
}

struct DirectionView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DirectionView(geometry :geometry)
        }
        
    }
}
