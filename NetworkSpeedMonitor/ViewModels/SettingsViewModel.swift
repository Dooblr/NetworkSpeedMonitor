//
//  ContentViewModel.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/26/21.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    // MARK: - Test Settings
    
    // Expected network speed in Mb/s
    @Published var expectedSpeed = 100
    
    // Mutable timer counter
    var testCount = 0
    
    // Number of tests
    @Published var hoursToTest = 24
    
    lazy var testTotal = 360 * hoursToTest
    
    // Seconds between tests
    var testFrequency = 10
    
    
    // MARK: - Data
    
    // Array to hold network speeds to be averaged
    var networkSpeeds:[String:Float] = [:]
    
    // Current average during test
    @Published var networkAverage:Float?
    
    
    // MARK: - Toggles
    
    // Toggle on while running
    @Published var sessionIsRunning = false
    
    var signalStopTest = false
    
    
    // MARK: - Functions
    
    func runTest(){
        
        self.sessionIsRunning = true
        
        Timer.scheduledTimer(withTimeInterval: Double(testFrequency), repeats: true) { timer in
            
            if self.signalStopTest == true {
                timer.invalidate()
                self.signalStopTest = false
                return
            }
            
            // Increment counter limit
            self.testCount += 1
            
            // Single snapshot of the network speed
            let speedSnapshot = self.testSpeed()
            print("Speed snapshot: \(speedSnapshot) Mb/sec")
            
            // Add speed snapshot to network speeds array
            self.networkSpeeds.updateValue(speedSnapshot.first!.value, forKey: speedSnapshot.first!.key)
            
            // Create a new float array to average network speeds
            var tempNetworkSpeeds:[Float] = []
            for (_,value) in self.networkSpeeds {
                tempNetworkSpeeds.append(value)
            }
            
            // Average network speeds
            self.networkAverage = self.arrayAverage(tempNetworkSpeeds)
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
    
    func stopTest(){
        self.signalStopTest = true
        self.sessionIsRunning = false
        self.networkSpeeds = [:]
    }
    
    func arrayAverage(_ floatArray:[Float]) -> Float{
        let sumArray = floatArray.reduce(0, +)
        
        let avgArrayValue = sumArray / Float(floatArray.count)
        
        return avgArrayValue
    }
    
    // Runs one test and returns a dict of date and speed
    func testSpeed() -> [String:Float]  {
        
        // Create a dispatch group
        let group = DispatchGroup()
        
        // Get individual test start time
        let startTime = Date()
        var networkSpeed:Float?
        
        // Get url of some data
        let url = URL(string: "https://g.foolcdn.com/image/?url=https%3A//g.foolcdn.com/editorial/images/654166/shiba-inu-shib-doge-dogecoin-token-coin-cryptocurrency-digital-blockchain-technology-invest-getty.jpg&w=2000&op=resize")
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
        
        return [startTime.description:networkSpeed!]
    }
}
