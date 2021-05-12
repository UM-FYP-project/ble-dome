//
//  NavMain.swift
//  ble dome
//
//  Created by UM on 11/05/2021.
//

import SwiftUI

struct NavMain: View {
    @EnvironmentObject var ble:BLE
    @EnvironmentObject var reader:Reader
    @State private var Information = [UInt8]()
    @State private var geoPos = [UInt8]()
    var geometry : GeometryProxy
    var body: some View {
        VStack{
            HStack{
                Image("pin")
                    .resizable()
                    .scaledToFit()
                Text("Location:")
                    .font(.title3)
                Spacer()
                Text("Indoor")
                    .font(.title3)
                    .frame(width: 100, height: 40)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                Spacer()
                Text("Outdoor")
                    .font(.title3)
                    .frame(width: 100, height: 40)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
            }
            .frame(width: geometry.size.width - 20, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Spacer()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 50) {
                VStack{
                    Image("door")
                        .resizable()
                        .scaledToFit()
                    Text("Entrance")
                        .font(.title2)
                }
                .frame(width: 150, height: 150)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 3))
                VStack{
                    Image("room")
                        .resizable()
                        .scaledToFit()
                    Text("Room")
                        .font(.title2)
                }
                .frame(width: 140, height: 140)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 3))
                VStack{
                    Image("lavatory")
                        .resizable()
                        .scaledToFit()
                    Text("Restroom")
                        .font(.title2)
                }
                .frame(width: 140, height: 140)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 3))
                VStack{
                    Image("stairs")
                        .resizable()
                        .scaledToFit()
                    Text("Stair")
                        .font(.title2)
                }
                .frame(width: 140, height: 140)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 3))
                VStack{
                    Image("elevator")
                        .resizable()
                        .scaledToFit()
                    Text("Elevator")
                        .font(.title2)
                }
                .frame(width: 140, height: 140)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.white.opacity(0.8)).shadow(radius: 3))
            }
            Spacer()
        }
        .onAppear(perform: {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Code@*/ /*@END_MENU_TOKEN@*/
        })
    }
    
    func getPosFromBLE(){
        
    }
}

struct NavMain_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            NavMain(geometry: geometry)
        }
    }
}
