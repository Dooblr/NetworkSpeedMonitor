//
//  DataFunctions.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/26/21.
//

import CoreData
import SwiftUI

class DataViewModel: ObservableObject {
    
    let container = PersistenceController.shared.container
    @Published var savedEntities: [SessionEntity] = []
    
    init(){
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading CoreData: \(error)")
            } else {
                print("Successfully loaded CoreData")
            }
        }
        fetchContent()
    }
    
    func fetchContent()  {
        let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching \(error)")
        }
    }
    
    func addItem(speedCollection:[[Date:Float]], speedExpected:Float) {

        // Create a new CoreData entity
        let newItem = SessionEntity(context: container.viewContext)
        
        // Set the expected speed for the session
        newItem.speedExpected = speedExpected
        
        // Set the [Date:Float] network speeds dict for CoreData entry
        newItem.speedCollection = speedCollection
        
        // Average all values in passed networkSpeeds
        var networkSpeedsArray:[Float] = []
        for item in speedCollection {
            guard item.values.first != nil else {
                continue
            }
            networkSpeedsArray.append(item.values.first!)
        }
        let networkSpeedAverage = HelperFuctions.arrayAverage(networkSpeedsArray)
        // Set entity's network speed average
        newItem.speedAverage = networkSpeedAverage

        // Save data and re-fetch
        DispatchQueue.main.async {
            self.saveData()
        }
    }

    func deleteItem(id: ObjectIdentifier) {
        for entity in savedEntities {
            if entity.id == id {
                container.viewContext.delete(entity)
            }
        }
        saveData()
    }
    
    func deleteAll() {
        for entity in savedEntities {
            container.viewContext.delete(entity)
        }
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchContent()
        } catch let error {
            print("Error saving. \(error)")
        }
    }
}
