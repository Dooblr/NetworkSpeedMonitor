//
//  DataFunctions.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/26/21.
//

import Foundation
import CoreData
import SwiftUI

class DataModel: ObservableObject {
    
    let container = NSPersistentContainer(name: "SessionData")
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
    
    func addItem() {
        
        let newItem = SessionEntity(context: container.viewContext)
        
        newItem.averageSpeed = 0

        DispatchQueue.main.async {
            self.saveData()
        }
        
    }

    func deleteItems(offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
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
