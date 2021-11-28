//
//  ContentView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/26/21.
//

import SwiftUI
import CoreData

struct SettingsView: View {

    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        
        
            VStack (alignment: .center) {
                
                Text("Speed Test Settings")
                    .padding()
                    .font(.title)
                
                Group {
                    Text("Expected network speed:")
                    HStack {
                        TextField("",
                              text: Binding(
                                get: { String(settingsViewModel.expectedSpeed) },
                                set: { settingsViewModel.expectedSpeed = Int($0) ?? 100 }
                        ))
                            .frame(width: 50, height: nil)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.leading)
                        Text("Megabits/s")
                    }
                }
                .padding([.leading, .bottom])
                
                Group {
                    Text("Test Duration:")
                    HStack {
                        TextField("",
                              text: Binding(
                                get: { String(settingsViewModel.hoursToTest) },
                                set: { settingsViewModel.hoursToTest = Int($0) ?? 24 }
                        ))
                            .frame(width: 50, height: nil)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.leading)
                        Text("Hours")
                    }
                }
                .padding([.leading, .bottom])
                
                
                
                if settingsViewModel.networkAverage != nil {
                    Divider()
                    
                    Text("Average Speed:")
                    let rounded = String(format:"%.2f", settingsViewModel.networkAverage!)
                    Text("\(rounded) Megabits/s")
                        .font(.title2)
                        .padding()
                    
                    Divider()
                } else {
                    Divider()
                    
                    Text("Average Speed:")
                    
                    if settingsViewModel.networkSpeeds == [:] && settingsViewModel.sessionIsRunning == true {
                        Text("Starting first test...")
                            .font(.title2)
                            .padding()
                    } else {
                        Text("Click start to begin testing")
                            .font(.title2)
                            .padding()
                    }
                        
                    
                    Divider()
                }
                
                
                HStack{
                    Button {
                        settingsViewModel.runTest()
                    } label: {
                        
                        Text((settingsViewModel.sessionIsRunning == false) ? "Start" : "Running")
                            .opacity((settingsViewModel.sessionIsRunning == false) ? 1 : 0.33)
                            .disabled((settingsViewModel.sessionIsRunning == false) ? false : true)
                    }
//                    .foregroundColor(.white)
                    .padding()
//                    .background(Color.accentColor)
//                    .cornerRadius(8)
                    
                    if settingsViewModel.sessionIsRunning == true {
                        ProgressView()
                    }
                    
                    Button {
                        settingsViewModel.stopTest()
                    } label: {
                        Text("Stop")
                    }
                    .padding()
                }
                
            }
            .frame(width:300, height:450)
            .padding()
    }
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

extension Float {
    func truncate(places : Int) -> Float {
        return Float(floor(pow(10.0, Float(places)) * self)/pow(10.0, Float(places)))
    }
}
