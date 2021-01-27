//
//  ContentView.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var ble = BLE()
    @State var button_state = false
    var body: some View {
        VStack{
            HStack{
                Text("Scanner")
                    .multilineTextAlignment(.leading)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer()
                if button_state == false{
                    Button(action: {
                        self.ble.scan_devices()
                        button_state = true
                    }) {
                        Text("Scan")
                            .font(.title2)
                    }
                }
                else{
                    Button(action: {
                        self.ble.stopscan_device()
                        button_state = false
                    }) {
                        Text("Stop Scanning")
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            if ble.isBluetoothON && button_state{
                List {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Content")/*@END_MENU_TOKEN@*/
                }
            }
            else if button_state == false{
                Text("Please Tap Scan")
                    .font(.title)
                    .bold()
                    .frame(width:UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 115, alignment: .center)
            }
            else{
                Text("Please Turn On Bluetooth")
                    .font(.title)
                    .bold()
                    .frame(width:UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 115, alignment: .center)
            }
        }
        .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height - 60)
        }
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}


