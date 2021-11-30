//
//  TabView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/27/21.
//

import SwiftUI

struct TabContainerView: View {
    var body: some View {
        
        TabView {
            TestView()
                .tabItem {
//                    Image(systemName: "speedometer")
                    Text("Test")
                    
                }
            SessionView()
                .tabItem {
//                    Image(systemName: "list.bullet.rectangle.fill")
                    Text("Sessions")
                }
        }
    }
}

//struct TabView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabView()
//    }
//}
