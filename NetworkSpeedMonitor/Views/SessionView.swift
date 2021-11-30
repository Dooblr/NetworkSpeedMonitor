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
    
    var body: some View {
        VStack {
            List {
                ForEach(dataModel.savedEntities, id:\.self) { session in
                    
                    let dates = getStartAndEndDates(session: session)
                    let startDate = dates.startDate
                    let endDate = dates.endDate
                    
                    HStack {
                        VStack (alignment: .leading) {
                            Text(("Start date: \(startDate)"))
                            Text(("End date: \(endDate)"))
                            Text("Average speed: \(String(format:"%.2f",session.speedAverage)) Mb/s")
                            Text("Expected speed: \(String(format:"%.0f",session.speedExpected)) Mb/s")
                        }
                        
                        Spacer()

                        Button {
                            dataModel.deleteItems(id: session.id)
                            isShowingDeleteSessionAlert = false
                        } label: {
                            Text("Delete")
                        }
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(5)
                    }
                    Divider()
                }
            }
            
            // Export all data to file
            Button {
                let text = "text text text"
                let dialogue = NSSavePanel()
                dialogue.nameFieldLabel = "Name of file to save"
                dialogue.nameFieldStringValue = "test.txt"
                dialogue.canCreateDirectories = true
                dialogue.isFloatingPanel = true
                dialogue.begin { result in
                    if result == .OK {
                        do {
                            guard let url = dialogue.url else {
                                return
                            }
                            try text.write(to: url, atomically: false, encoding: .utf8)
                            
                        } catch {
                            fatalError("Couldn't save the file - \(error.localizedDescription)")
                        }
                    }
                }
            } label: {
                Text("Export data to file")
            }
            
            // Delete all
            Group {
                if isShowingDeleteAllAlert == false {
                    Button {
                        isShowingDeleteAllAlert = true
                    } label: {
                        Text("Delete all sessions")
                    }
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


extension String {
    // Get the filename from a string
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    // Get the file extension from a String
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
func writeFile(outputFile: String, stringData:String){
    // Split the file extension and filename
    let fileExtension = outputFile.fileExtension()
    let fileName = outputFile.fileName()
    
    // Get the fileURL
    let fileURL = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let outputFile = fileURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
    
    // Save the data
    guard let data = stringData.data(using:.utf8) else {
        print("Unable to convert string to data")
        return
    }
    
    do {
        try data.write(to: outputFile)
        print("data written: \(data)")
    } catch {
        print(error.localizedDescription)
    }
}

func writeFile2() {
    // File name
    let fileName = "Test"
    let DocumentDirectoryURL = try! FileManager.default.url(for: .desktopDirectory,
                                                         in: .userDomainMask,
                                                         appropriateFor: nil,
                                                         create: true)
    // File path
    let fileURL = DocumentDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("txt")
    print("File Path: \(fileURL.path)")
    
    // Content to write to file
    let writeString = "Write this text to the file in Swift"
    
    // Write to the file or catch any error
    do {
        try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
    } catch let error as NSError {
        print("Failed to write to URL")
        print(error)
    }
    
    // Read
    var readString = ""
    do {
        readString = try String(contentsOf: fileURL)
    } catch {
        print("Failed to read file")
        print(error)
    }
    print("Contents of the file \(readString)")
}


struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
