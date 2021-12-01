//
//  SessionView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/27/21.
//

import SwiftUI

struct SessionView: View {
    
    @EnvironmentObject var dataModel: DataModel
    @EnvironmentObject var testModel: TestViewModel
    
    // Toggles delete buttons to "are you sure" before deleting
    @State var isShowingDeleteAllAlert = false
    @State var isShowingDeleteSessionAlert = false
    
    @State var selectedSessions:[SessionEntity] = []
    
    var body: some View {
        VStack {
            // TODO: Why isn't this updating?
//            if dataModel.savedEntities.isEmpty {
//                Spacer()
//                Text("Run a test to view sessions and export data").font(.title3)
//                Spacer()
//            } else {
                List {
                    ForEach(dataModel.savedEntities, id:\.self) { session in
                        
                        let dates = getStartAndEndDates(session: session)
                        let startDate = dates.startDate
                        let endDate = dates.endDate
                        
                        HStack {
                            
                            if selectedSessions.contains(session) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
                            } else {
                                Image(systemName: "circle")
                            }
                            
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
                                dataModel.deleteItems(id: session.id)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(5)
                        }
                        Divider()
                    }
                }
//            }
            
            HStack {
                // Export all data to file
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
                    
                    if isShowingDeleteAllAlert == false {
                        Button {
                            isShowingDeleteAllAlert = true
                        } label: {
                            Text("Delete all sessions")
                        }
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(5)
                    } else {
                        HStack {
                            Button {
                                dataModel.deleteAll()
                                isShowingDeleteAllAlert = false
                            } label: {
                                Text("Are you sure?")
                            }
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(5)
                            Button {
                                isShowingDeleteAllAlert = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
                }
                .padding()
            }
            .disabled(dataModel.savedEntities.isEmpty ? true : false)
            .opacity(dataModel.savedEntities.isEmpty ? 0.3 : 1.0)
        }
    }
    
    func createReportAndSave() {
        // Create a blank text variable to write to
        var text = ""
        
        // Use all sessions if none are selected, otherwise export the selected sessions
        var collectionToExport:[SessionEntity]?
        if selectedSessions.isEmpty {
            collectionToExport = dataModel.savedEntities
        } else {
            collectionToExport = selectedSessions
        }
        
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
