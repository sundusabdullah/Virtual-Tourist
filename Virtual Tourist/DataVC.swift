//
//  DataController.swift
//  Virtual Tourist
//
//  Created by sundus on 02/09/1440 AH.
//  Copyright © 1440 sundus. All rights reserved.
//

import Foundation
import CoreData


class DataVC {
    
    let container: NSPersistentContainer

    static let shared = DataVC(modelName: "VirtualTourist")

    var viewContext: NSManagedObjectContext{
        return container.viewContext
    }
    
    var background: NSManagedObjectContext!
    
    init(modelName: String){
        container = NSPersistentContainer(name: modelName)
    }
    
    func config() {
        background = container.newBackgroundContext()
        viewContext.automaticallyMergesChangesFromParent = true
        background.automaticallyMergesChangesFromParent = true
        background.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    

    func load(completionHandler: (() -> Void)? = nil) {
        container.loadPersistentStores() {
            (storeDescription, error) in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            self.autoSave()
            self.config()
            
        }
    }
}
    extension DataVC {
        func autoSave(interval: TimeInterval = 30){
            
            guard interval > 0 else {
                return
            }
            if viewContext.hasChanges{
                try? viewContext.save()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                self.autoSave()
            }
        }
}
    

