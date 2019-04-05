//
//  MovieAPI.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 04/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import Foundation
import CoreData

/**
 Movie API contains the endpoints to Create/Read/Update/Delete Movies.
 */
class MovieAPI {
    
    fileprivate let persistenceService: PersistenceService!
    fileprivate var mainContextInstance: NSManagedObjectContext!
    
    fileprivate let title = "\(MovieAttributes.title)"
    fileprivate let image = "\(MovieAttributes.image)"
    fileprivate let rating = "\(MovieAttributes.rating)"
    fileprivate let releaseYear = "\(MovieAttributes.releaseYear)"
    fileprivate let genre = "\(MovieAttributes.genre)"
    
    //Utilize Singleton pattern by instanciating MovieAPI only once.
    class var sharedInstance: MovieAPI {
        struct Singleton {
            static let instance = MovieAPI()
        }
        
        return Singleton.instance
    }
    
    init() {
        self.persistenceService = PersistenceService.sharedInstance
        self.mainContextInstance = persistenceService.getMainContextInstance()
    }
    
    // MARK: Create
    
    /**
     Create a single Movie item, and persist it to Datastore via Worker(minion),
     that synchronizes with Main context.
     
     - Parameter movieDetails: <Dictionary<String, AnyObject> A single Movie item to be persisted to the Datastore.
     */
    func saveMovie(_ movieDetails: Dictionary<String, AnyObject>) {
        //Minion Context worker with Private Concurrency type.
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Create new Object of Movie entity
        let movieItem = NSEntityDescription.insertNewObject(forEntityName: EntityTypes.Movie.rawValue,
                                                            into: minionManagedObjectContextWorker) as! Movie
        

        //Assign field values
        for (key, value) in movieDetails {
            for attribute in MovieAttributes.getAll {
                if (key == attribute.rawValue) {
                    movieItem.setValue(value, forKey: key)
                }
            }
        }
        
        //Save current work on Minion workers
        self.persistenceService.saveWorkerContext(minionManagedObjectContextWorker)
        
        //Save and merge changes from Minion workers with Main context
        self.persistenceService.mergeWithMainContext()
        
        //Post notification to update datasource of a given Viewcontroller/UITableView
        self.postUpdateNotification()
    }
    
    /**
     Create new Movies from a given list, and persist it to Datastore via Worker(minion),
     that synchronizes with Main context.
     
     - Parameter mociesList: Array<AnyObject> Contains movies to be persisted to the Datastore.
     - Returns: Void
     */
    func saveMoviesList(_ moviesList: Array<AnyObject>) {
        DispatchQueue.global().async {
            
            //Minion Context worker with Private Concurrency type.
            let minionManagedObjectContextWorker: NSManagedObjectContext =
                NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
            minionManagedObjectContextWorker.parent = self.mainContextInstance
            
            //Create movieEntity, process member field values
            for index in 0..<moviesList.count {
                var movieItem: Dictionary<String, AnyObject> = moviesList[index] as! Dictionary<String, NSObject>
                
                //Create new Object of Movie entity
                let item = NSEntityDescription.insertNewObject(forEntityName: EntityTypes.Movie.rawValue,
                                                               into: minionManagedObjectContextWorker) as! Movie
                
                //Add member field values
                item.setValue(movieItem[self.title], forKey: self.title)
                item.setValue(movieItem[self.image], forKey: self.image)
                item.setValue(movieItem[self.rating], forKey: self.rating)
                item.setValue(movieItem[self.releaseYear], forKey: self.releaseYear)
                item.setValue(movieItem[self.genre], forKey: self.genre)

                //Save current work on Minion workers
                self.persistenceService.saveWorkerContext(minionManagedObjectContextWorker)
            }
            
            //Save and merge changes from Minion workers with Main context
            self.persistenceService.mergeWithMainContext()
            
            //Post notification to update datasource of a given Viewcontroller/UITableView
            DispatchQueue.main.async {
                self.postUpdateNotification()
            }
        }
    }
    
    // MARK: Read
    
    /**
     Retrieves all movie items stored in the persistence layer, default (overridable)
     parameters:
     
     - Parameter sortedByDate: Bool flag to add sort rule: by Year
     - Parameter sortAscending: Bool flag to set rule on sorting: Ascending / Descending year.
     
     - Returns: Array<Movie> with found movies in datastore
     */
    func getAllMovies(_ sortedByDate: Bool = true, sortAscending: Bool = true) -> Array<Movie> {
        var fetchedResults: Array<Movie> = Array<Movie>()
        
        // Create request on Movie entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.Movie.rawValue)
        
        //Create sort descriptor to sort retrieved Movies by Date, ascending
        if sortedByDate {
            let sortDescriptor = NSSortDescriptor(key: releaseYear,
                                                  ascending: sortAscending)
            let sortDescriptors = [sortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        //Execute Fetch request
        do {
            fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) as! [Movie]
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<Movie>()
        }
        
        return fetchedResults
    }
    
    /**
     Retrieve a Movie, found by it's stored UUID.
     
     - Parameter title: title of Movie item to retrieve
     - Returns: Array of Found Movie items, or an empty Array
     */
    func getMovieByTitle(_ title: String) -> Movie? {
        var fetchedResultMovie: Movie?
        
        // Create request on Event entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.Movie.rawValue)
        
        //Add a predicate to filter by eventId
        let findByIdPredicate =
            NSPredicate(format: "title = %@", NSString(string: title))
        fetchRequest.predicate = findByIdPredicate
        
        //Execute Fetch request
        do {
            let fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) as! [Movie]
            fetchRequest.fetchLimit = 1
            
            if fetchedResults.count != 0 {
                fetchedResultMovie =  fetchedResults.first
            }
        } catch let fetchError as NSError {
            print("retrieve single event error: \(fetchError.localizedDescription)")
        }
        
        return fetchedResultMovie
    }
    
    func movieExists(_ title:String) -> Bool {
        
        if getMovieByTitle(title) != nil {
            return true
        }
        return false
    }
    
    // MARK: Delete
    
    /**
     Delete all Movie items from persistence layer.
     */
    func deleteAllMovies() {
        let retrievedItems = getAllMovies()

        //Delete all Movie items from persistance layer
        for item in retrievedItems {
            self.mainContextInstance.delete(item)
        }

        //Save and merge changes from Minion workers with Main context
        self.persistenceService.mergeWithMainContext()

        //Post notification to update datasource of a given Viewcontroller/UITableView
        self.postUpdateNotification()
    }
    
    fileprivate func postUpdateNotification() {
        NotificationCenter.default.post(name: Notification.Name.updateMoviesTableData, object: nil)
    }
}
