//
//  WindowView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 12/7/21.
//

import SwiftUI
import SwiftUICharts

struct WindowView: View {
    
//    @EnvironmentObject var dataModel:DataViewModel
    var session: SessionEntity
    
    @State var points:[DataPoint] = []
    
    var body: some View {
        
        let warmUp = Legend(color: .blue, label: "Warm Up", order: 2)

//        let limit = DataPoint(value: 100, label: "LIMIT", legend: warmUp)
        
        VStack {
            
            LineChartView(dataPoints: points)
            
            Button {
                NSApplication.shared.keyWindow?.close()
            } label: {
                Text("Close window")
            }

        }
        .frame(minWidth:500,minHeight:600)
        .onAppear {
            for item in session.speedCollection! {
                let thing = DataPoint.init(value: Double(item.value), label: "\(item.key.description)", legend: warmUp)
                points.append(thing)
            }
        }
    }
}

//struct WindowView_Previews: PreviewProvider {
//    static var previews: some View {
//        WindowView()
//    }
//}
