//
//  PersistenceService.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 04/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import Foundation
import CoreData
/**
 Persistence service will delegate to ContextManager to handle Minion-,
 Main- and Master context to merge and save.
 */
class PersistenceService {

    fileprivate var appDelegate: AppDelegate
    fileprivate var mainContextInstance: NSManagedObjectContext
    
    //Singleton to prevent creating more than one instance.
    class var sharedInstance: PersistenceService {
        struct Singleton {
            static let instance = PersistenceService()
        }
        
        return Singleton.instance
    }
    
    init() {
        appDelegate = AppDelegate().sharedInstance()
        mainContextInstance = PersistenceService.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /**
     Get a reference to the Main Context Instance
     
     - Returns: Main NSmanagedObjectContext
     */
    func getMainContextInstance() -> NSManagedObjectContext {
        return self.mainContextInstance
    }
    
    /**
     Save and merge the current work/changes done on the minion workers with Main context.
     
     - Returns: Void
     */
    func mergeWithMainContext() {
        do {
            try self.mainContextInstance.save()
        } catch let saveError as NSError {
            print("synWithMainContext error: \(saveError.localizedDescription)")
        }
    }
    
    /**
     Save the current work/changes done on the worker contexts (the minion workers).
     
     - Parameter workerContext: NSManagedObjectContext The Minion worker Context that has to be saved.
     - Returns: Void
     */
    func saveWorkerContext(_ workerContext: NSManagedObjectContext) {
        //Persist new Movie to datastore (via Managed Object Context Layer).
        do {
            try workerContext.save()
        } catch let saveError as NSError {
            print("save minion worker error: \(saveError.localizedDescription)")
        }
    }
}
