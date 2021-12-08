//
//  ContentViewModel.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/26/21.
//

import Foundation

class TestViewModel: ObservableObject {
    
    let dataModel = DataViewModel()
    
    // Toggles opening a window
    @Published var sessionWindowIsOpen = false
    
    // MARK: - Test Settings
    
    // Expected network speed in Mb/s
    @Published var speedExpected = 100
    
    // Mutable timer counter
    var testCount = 0
    
    // Number of tests
    @Published var hoursToTest = 24
    
    lazy var testTotal = 360 * hoursToTest
    
    // Seconds between tests
    var testFrequency = 10
    
    let testURL = "https://upload.wikimedia.org/wikipedia/commons/a/a6/Brandenburger_Tor_abends.jpg"
    //"https://g.foolcdn.com/image/?url=https%3A//g.foolcdn.com/editorial/images/654166/shiba-inu-shib-doge-dogecoin-token-coin-cryptocurrency-digital-blockchain-technology-invest-getty.jpg&w=2000&op=resize"
    
    // MARK: - Data
    
    // Dict to hold network speeds to be averaged with key as a Date
    var speedCollection:[Date:Float] = [:]
    
    // Current average during test
    @Published var networkAverage:Float?
    
    
    // MARK: - Toggles
    
    // Toggle on while running
    @Published var sessionIsRunning = false
    
    private var signalStopTest = false
    
    
    // MARK: - Functions
    
    func runTest(){
        
        // Inform view that test has begun
        self.sessionIsRunning = true
        
        // Start a timer to run network speed tests
        Timer.scheduledTimer(withTimeInterval: Double(testFrequency), repeats: true) { timer in
            
            // Stop test if stop signal has been received
            if self.signalStopTest == true {
                // Kill timer running test
                timer.invalidate()
                // Reset stop test signal
                self.signalStopTest = false
                // Exit test
                return
            }
            
            // Increment counter limit
            self.testCount += 1
            
            // Single snapshot of the network speed
            let speedSnapshot = self.testSpeed()
            print("Speed snapshot: \(speedSnapshot) Mb/sec")
            
            // Add speed snapshot to network speeds array
            self.speedCollection.updateValue(speedSnapshot.first!.value, forKey: speedSnapshot.first!.key)
            
            // Create a new float array to average network speeds
            var tempNetworkSpeeds:[Float] = []
            for (_,value) in self.speedCollection {
                tempNetworkSpeeds.append(value)
            }
            
            // Average network speeds
            self.networkAverage = HelperFuctions.arrayAverage(tempNetworkSpeeds)
//            print("Average speed: \(self.networkAverage!) Mb/sec \n")
            
            // End timer and print final result
            if self.testCount == self.testTotal {
                timer.invalidate()
//                print("Finished")
//                print("Final Average speed: \(self.networkAverage!) Mb/sec")
                
                self.sessionIsRunning = false
            }
        }
    }
    
    // Runs one test and returns a dict of date and speed
    func testSpeed() -> [Date:Float]  {
        
        // Create a dispatch group
        let group = DispatchGroup()
        
        // Get individual test start time
        let startTime = Date()
        var networkSpeed:Float?
        
        // Get url of some data
        let url = URL(string: self.testURL)
        let request = URLRequest(url: url!,
                                 cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData,
                                 timeoutInterval: Double.infinity)
        
        group.enter()
        URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let data = data, error == nil else { return }
            
            // Get length of data in megabits
            let length  = Float( (response?.expectedContentLength)!) / 125000.0

            // Get time elapsed to complete download
            let elapsed = Float( Date().timeIntervalSince(startTime))

            // Network speed is the quotient of length and time elapsed
            let speed = length/elapsed

            // Set class variable to result
            networkSpeed = speed
            
            // Signal dispatch to return network speed result
            group.leave()
        }.resume()
        
        group.wait()
        
        return [startTime:networkSpeed!]
    }
    
    func stopTest(){
        
        // Only add a CoreData object if data has been collected
        if !self.speedCollection.isEmpty {
            // Create a CoreData entity with the speed collection and expected network speed
            self.createSession(speedCollection: self.speedCollection,
                               speedExpected: Float(self.speedExpected))
        }
        
        // Signals the test timer to stop
        self.signalStopTest = true
        
        // Tells view items that session has stopped
        self.sessionIsRunning = false
        
        // Resets the in-memory network speeds
        self.speedCollection = [:]
        
        // Reset published average
        self.networkAverage = nil
        
    }
    
    // Creates a CoreData Session with a Dict[Date:Speed/Float]
    func createSession(speedCollection: [Date:Float], speedExpected:Float) {
        self.dataModel.addItem(speedCollection: speedCollection,
                               speedExpected: speedExpected)
    }
}
