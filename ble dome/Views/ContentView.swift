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
            Spacer()
            if button_state == false{
                Button(action: {
                self.ble.scan_devices()
                    button_state = true
                }) {
                    Text("Scan")
                        .font(.title2)
                }
                .frame(width:UIScreen.main.bounds.width - 20, height:30)
                
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
        .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 60)
        }
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}


