//
//  AlertPicker.swift
//  ble dome
//
//  Created by UM on 15/05/2021.
//

import SwiftUI

struct AlertPicker: View{
    var picker : [Any]
    var title : String
    var label : String
    var geometry : GeometryProxy
    @Binding var Selected : Int
    @Binding var enable : Bool
    var body: some View {
        let picker_text : [String] = picker.compactMap {String(describing: $0)}
        VStack{
            VStack(alignment: .center){
                Text(title)
                    .font(.headline)
                    .padding()
                Picker(selection: self.$Selected, label: Text(label)) {
                    ForEach(picker_text.indices) { (index) in
                        Text("\(picker_text[index])")
                    }
                }
                .padding()
                .clipped()
            }
            Divider()
            VStack{
                Button(action: {self.enable = false}) {
                    Text("OK")
                        .bold()
                        .font(.headline)
                }
                .padding()
            }
        }
        .background(RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(UIColor.systemGray6)).shadow(radius: 1))
        .frame(maxWidth: geometry.size.width - 30)
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
}


//struct AlertPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        AlertPicker()
//    }
//}
