//
//  ContentView.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/26/21.
//

import SwiftUI
import CoreData

struct TestView: View {

    @EnvironmentObject var testViewModel: TestViewModel
    
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
                                get: { String(testViewModel.speedExpected) },
                                set: { testViewModel.speedExpected = Int($0) ?? 100 }
                        ))
                            .frame(width: 50, height: nil)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .disabled((testViewModel.sessionIsRunning == true) ? true : false)
                        Text("Megabits/s")
                    }
                }
                .padding([.leading])
                
                Group {
                    Text("Test Duration:")
                    HStack {
                        TextField("",
                              text: Binding(
                                get: { String(testViewModel.hoursToTest) },
                                set: { testViewModel.hoursToTest = Int($0) ?? 24 }
                        ))
                            .frame(width: 50, height: nil)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .disabled((testViewModel.sessionIsRunning == true) ? true : false)
                        Text("Hours")
                    }
                }
                .padding([.leading])
                
                if testViewModel.networkAverage != nil {
                    Divider()
                    
                    Text("Average Speed:")
                    let rounded = String(format:"%.2f", testViewModel.networkAverage!)
                    Text("\(rounded) Megabits/s")
                        .font(.title2)
                        .padding(5)
                    
                    Divider()
                } else {
                    Divider()
                    
                    Text("Average Speed:")
                    
                    if testViewModel.speedCollection == [[:]] && testViewModel.sessionIsRunning == true {
                        Text("Starting first test...")
                            .font(.title2)
                            .padding(5)
                    } else {
                        Text("Press start to begin testing")
                            .font(.title2)
                            .padding(5)
                    }
                    
                    Divider()
                }
                
                HStack{
                    Button {
                        testViewModel.runTest()
                    } label: {
                        // Ternary operator for setting text while running
                        Text((testViewModel.sessionIsRunning == false) ? "Start" : "Running")
                    }
                        .padding()
                        // Start button is disabled while running
                        .disabled((testViewModel.sessionIsRunning == true) ? true : false)
                    
                    // Show a progress view while session is running
                    if testViewModel.sessionIsRunning == true {
                        ProgressView()
                    }
                    
                    Button {
                        testViewModel.stopTest()
                    } label: {
                        Text("Stop")
                    }
                    .disabled((testViewModel.sessionIsRunning == false) ? true : false)
                    .padding()
                }
                
                HStack {
                    Spacer()
                    Button {
                        NSApplication.shared.terminate(self)
                    } label: {
                        Text("Quit")
                    }

                }
                
            }
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
