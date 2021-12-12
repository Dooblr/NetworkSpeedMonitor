//
//  WindowView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 12/7/21.
//

import SwiftUI
import SwiftUICharts

struct WindowView: View {
    
    // The session from which data will be pulled to populate graph
    var session: SessionEntity
    
//    var chartProtocol:CTLineBarChartDataProtocol.XLabels = ["1","2","3"]
    
    var body: some View {
        
        VStack {
            
            // Create a SwiftUICharts dataset from the supplied session data
            let data = getData(session)
            
            LineChart(chartData: data)
                .xAxisGrid(chartData: data)
                .yAxisGrid(chartData: data)
                .xAxisLabels(chartData: data)
                .yAxisLabels(chartData: data,
                             formatter: numberFormatter,
                             colourIndicator: .style(size: 12))
                .infoBox(chartData: data)
                .headerBox(chartData: data)
                .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible())])
                .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                .padding(.horizontal)
            
            // Close window button
            Button {
                NSApplication.shared.keyWindow?.close()
            } label: {
                Text("Close")
            }
            .padding(.vertical)

        }
        .frame(minWidth:500,minHeight:400)
        .padding()
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    // Takes a CoreData session and returns a LineChartData instance to populate the graph window
    func getData(_ session:SessionEntity) -> LineChartData {
        
        // Create an array for data points
        var dataPoints:[LineChartDataPoint] = []
        
        // Loop through session
        for item in session.speedCollection! {
            
            // Format the date
            let date = HelperFuctions.formatDate(date: item.keys.first!, format: "hh:mm")
            
            // Create linechart data point
            let sessionPoint = LineChartDataPoint(value: Double(item.values.first!),
                                                  xAxisLabel: date,
                                                  description: nil,
                                                  date: nil,
                                                  pointColour: nil)
            // Append to data point array
            dataPoints.append(sessionPoint)
        }
        
        // Downsample data points if over 100
        if dataPoints.count > 100 {
            dataPoints = dataPoints.evenlySpaced(length: 100)
        }
        
        // Default to using data for label source
        var labelSource = LabelsFrom.dataPoint(rotation: .degrees(0))
        
        // Truncate labels if more than 7
        var truncatedxAxisLabels:[String] = []
        if dataPoints.count > 7 {
            labelSource = LabelsFrom.chartData(rotation: .degrees(0))
            for point in dataPoints {
                truncatedxAxisLabels.append(point.xAxisLabel ?? "")
            }
            truncatedxAxisLabels = truncatedxAxisLabels.evenlySpaced(length: 7)
        }
        
        let data = LineDataSet(dataPoints: dataPoints,
                               legendTitle: "Network Speed",
                               pointStyle: PointStyle(),
                               style: LineStyle(lineColour: ColourStyle(colour: .blue), lineType: .curvedLine))
        
        let gridStyle = GridStyle(numberOfLines: 3,
                                   lineColour   : Color(.lightGray).opacity(0.5),
                                   lineWidth    : 1,
                                   dash         : [8],
                                   dashPhase    : 0)
        
        let chartStyle = LineChartStyle(infoBoxPlacement    : .infoBox(isStatic: false),
                                        infoBoxContentAlignment: .vertical,
                                        infoBoxBorderColour : Color.primary,
                                        infoBoxBorderStyle  : StrokeStyle(lineWidth: 1),
                                        
                                        markerType          : .vertical(attachment: .line(dot: .style(DotStyle()))),
                                        
                                        xAxisGridStyle      : gridStyle,
                                        xAxisLabelPosition  : .bottom,
                                        xAxisLabelColour    : Color.primary,
                                        xAxisLabelsFrom     : labelSource,
                                        xAxisTitle          : "Time",
                                        
                                        yAxisGridStyle      : gridStyle,
                                        yAxisLabelPosition  : .leading,
                                        yAxisLabelColour    : Color.primary,
                                        yAxisNumberOfLabels : 7,
                                        
                                        baseline            : .minimumWithMaximum(of: 0),
                                        topLine             : .maximum(of: Double(session.speedExpected)),
                                        
                                        globalAnimation     : .easeOut(duration: 1))
        
        
        // Subtitle is start and end dates
        var subTitle:String {
            let startDate = (session.speedCollection!.first!.keys.first)!
            let endDate = (session.speedCollection!.last!.keys.first)!
            
            let startDateFormatted = HelperFuctions.formatDate(date: startDate, format: "MMM d, yyyy h:mm a")
            let endDateFormatted = HelperFuctions.formatDate(date: endDate, format: "MMM d, yyyy h:mm a")
            
            return "Started: \(startDateFormatted) \nFinished: \(endDateFormatted)"
        }
        
        let chartData = LineChartData(dataSets       : data,
                                      metadata       : ChartMetadata(title: "Network Speed",subtitle: subTitle),
                                      xAxisLabels    : truncatedxAxisLabels,
                                      chartStyle     : chartStyle)
        
//        defer {
//            chartData.touchedDataPointPublisher
//                .map(\.value)
//                .sink { value in
//                    var dotStyle: DotStyle
//                    if value < 10_000 {
//                        dotStyle = DotStyle(fillColour: .red)
//                    } else if value >= 10_000 && value <= 15_000 {
//                        dotStyle = DotStyle(fillColour: .blue)
//                    } else {
//                        dotStyle = DotStyle(fillColour: .green)
//                    }
//                    withAnimation(.linear(duration: 0.5)) {
//                        chartData.chartStyle.markerType = .vertical(attachment: .line(dot: .style(dotStyle)))
//                    }
//                }
//                .store(in: &chartData.subscription)
//        }
        
        return chartData
        
    }
}

//struct WindowView_Previews: PreviewProvider {
//    static var previews: some View {
//        WindowView()
//    }
//}
