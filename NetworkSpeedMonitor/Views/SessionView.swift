//
//  SessionView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/27/21.
//

import SwiftUI

struct SessionView: View {
    
    @EnvironmentObject var dataModel: DataViewModel
    @EnvironmentObject var testModel: TestViewModel
    
    // Toggles delete buttons to "are you sure" before deleting
    @State var isShowingDeleteSessionsAlert = false
    
    // Collection of selected items
    @State var selectedSessions:[SessionEntity] = []
    
    var body: some View {
        VStack {
            
            // MARK: - Session List
            
            List {
                ForEach(dataModel.savedEntities, id:\.self) { session in
                    
                    let dates = getStartAndEndDates(session: session)
                    let startDate = dates.startDate
                    let endDate = dates.endDate
                    
                    HStack {
                        
                        // Check/Uncheck Circle
                        if selectedSessions.contains(session) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
                        } else {
                            Image(systemName: "circle")
                        }
                        
                        // Session Display
                        VStack (alignment: .leading) {
                            Text(("Start date: \(startDate)"))
                            Text(("End date: \(endDate)"))
                            Text("Average speed: \(String(format:"%.2f",session.speedAverage)) Mb/s")
                            Text("Expected speed: \(String(format:"%.0f",session.speedExpected)) Mb/s")
                        }.onTapGesture {
                            if !selectedSessions.contains(session) {
                                selectedSessions.append(session)
                            } else {
                                for (index, searchSession) in selectedSessions.enumerated() {
                                    if searchSession.id == session.id {
                                        selectedSessions.remove(at: index)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            WindowView(session: session)
                                .openInWindow(title: "Network Speed Monitor", sender: self)
                        } label: {
                            Image(systemName: "chart.bar.xaxis")
                                
                        }
                        .padding()
                        .foregroundColor(.white)
                        
                    }
                    Divider()
                }
            }
           
            
            // MARK: - Export & Delete Buttons
            
            VStack {
                // Export all or selected sessions to file
                Button {
                    createReportAndSave()
                } label: {
                    if selectedSessions.isEmpty {
                        Text("Export all data")
                    } else {
                        Text("Export selected data")
                    }
                }
                
                // Delete all
                Group {
                    
                    // All/Selected delete logic
                    if isShowingDeleteSessionsAlert == false {
                        Button {
                            isShowingDeleteSessionsAlert = true
                        } label: {
                            if selectedSessions.isEmpty {
                                Text("Delete all sessions")
                            } else {
                                Text("Delete selected sessions")
                            }
                        }
                        // Style
                        .redAlertButton()
                    } else {
                        // Confirm delete button
                        HStack {
                            if selectedSessions.isEmpty {
                                Button {
                                    dataModel.deleteAll()
                                    isShowingDeleteSessionsAlert = false
                                } label: {
                                    Text("Delete All Sessions?")
                                }
                                // Style
                                .redAlertButton()
                            } else {
                                Button {
                                    for item in selectedSessions {
                                        dataModel.deleteItem(id: item.id)
                                    }
//                                    dataModel.deleteAll()
                                    isShowingDeleteSessionsAlert = false
                                } label: {
                                    Text("Delete Selected Sessions?")
                                }
                                // Style
                                .redAlertButton()
                            }
                            
                            // Cancel button
                            Button {
                                isShowingDeleteSessionsAlert = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
            .disabled(dataModel.savedEntities.isEmpty ? true : false)
            .opacity(dataModel.savedEntities.isEmpty ? 0.3 : 1.0)
            .foregroundColor(.white)
        }.onAppear {
            // Fetches coredata items and updates published sessions to view
            dataModel.fetchContent()
        }
    }
    
    // Uses all or selected sessions to create a text file, then open a save dialogue window
    func createReportAndSave() {
        // Create a blank text variable to write to
        var text = ""
        
        // Use all sessions if none are selected, otherwise export the selected sessions
        let collectionToExport:[SessionEntity]? = selectedSessions.isEmpty ? dataModel.savedEntities : selectedSessions
        
        // Append the export collection to text
        for session in collectionToExport! {
            let dates = getStartAndEndDates(session: session)
            let startDate = dates.startDate
            let endDate = dates.endDate
            text.append("Start date: \(startDate)\n")
            text.append("End date: \(endDate)\n")
            text.append("Average speed: \(String(format:"%.2f",session.speedAverage)) Mb/s \n")
            text.append("Expected speed: \(String(format:"%.0f",session.speedExpected)) Mb/s \n ")
            text.append("----------------------------------\n")
        }
        
        // Create a save panel
        let dialogue = NSSavePanel()
        dialogue.nameFieldLabel = "Name of file to save"
        let formattedDate = HelperFuctions.formatDate(date: NSDate.now, format: "MMM d, yyyy 'at' hh,mm a")
        dialogue.nameFieldStringValue = "Network Speed Test Export \(formattedDate).txt"
        dialogue.canCreateDirectories = true
        dialogue.isFloatingPanel = true
        // Write to new file
        dialogue.begin { result in
            if result == .OK {
                do {
                    guard let url = dialogue.url else {
                        return
                    }
                    try text.write(to: url, atomically: false, encoding: .utf8)
                    
                } catch {
                    fatalError("Error saving file. Error description: \(error.localizedDescription)")
                }
            }
        }
    }

    // Takes a session entity, sorts the network speeds by date, and returns the start and end dates of the test
    func getStartAndEndDates(session:SessionEntity) -> (startDate: String, endDate: String) {
        
        // Create a new dict sorted by time
        let sortedSpeeds = session.speedCollection?.sorted{ $0.key < $1.key }
        
        // Get start date and format
        let startDate = sortedSpeeds?.first?.key
        let startDateFormatted = HelperFuctions.formatDate(date:startDate!,format:"MMM d, yyyy h:mm a")
        
        // Get end date and format
        let endDate = sortedSpeeds?.last?.key
        let endDateFormatted = HelperFuctions.formatDate(date:endDate!,format:"MMM d, yyyy h:mm a")
        
        return (startDateFormatted, endDateFormatted)
    }
}



struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
