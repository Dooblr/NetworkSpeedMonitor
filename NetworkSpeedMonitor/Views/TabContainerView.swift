//
//  TabView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/27/21.
//

import SwiftUI

struct TabContainerView: View {
    
    @EnvironmentObject var testViewModel:TestViewModel
    
    var body: some View {
        
        TabView {
            TestView()
                .tabItem {
                    Text("Test")
                    
                }
            SessionView()
                .tabItem {
                    Text("Sessions")
                }
        }
        .frame(minWidth:350, minHeight:400)
    }
}

//struct TabView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabView()
//    }
//}
