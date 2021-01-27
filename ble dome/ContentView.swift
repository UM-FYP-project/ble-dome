//
//  ContentView.swift
//  ble dome
//
//  Created by UM on 26/01/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var ble = BLE()
    var body: some View {
        VStack{
            HStack{
                Text("Scanner")
                    .multilineTextAlignment(.leading)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer()
                var button_state:Int = 1
                if button_state == 1{
                    Button(action: {
                        self.ble.scan_devices()
                        button_state = 2
                    }) {
                        Text("Scan")
                            .font(.title)
                    }
                }
                else{
                    Button(action: {
                        self.ble.stopscan_device()
                        button_state = 1
                    }) {
                        Text("Stop Scanning")
                            .font(.title)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            if ble.isBluetoothON  {
                List {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Content")/*@END_MENU_TOKEN@*/
                }
            }
            else {
            Text("Please Turn On Bluetooth")
                .font(.title)
                .bold()
                .frame(width:UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 90, alignment: .center)
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


