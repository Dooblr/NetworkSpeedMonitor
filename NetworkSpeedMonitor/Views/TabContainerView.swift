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
//        .frame(width:350, height:800)
        .frame(minWidth:350, minHeight:500)
    }
}

//struct TabView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabView()
//    }
//}
