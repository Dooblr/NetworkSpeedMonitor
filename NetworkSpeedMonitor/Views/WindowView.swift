//
//  WindowView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 12/7/21.
//

import SwiftUI

struct WindowView: View {
    
    @EnvironmentObject var dataModel:DataViewModel
    
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button {
                NSApplication.shared.keyWindow?.close()
            } label: {
                Text("Close window")
            }

        }
    }
}

struct WindowView_Previews: PreviewProvider {
    static var previews: some View {
        WindowView()
    }
}
