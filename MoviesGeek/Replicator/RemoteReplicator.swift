//
//  RemoteReplicator.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 05/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import UIKit
/**
 Remote Replicator handles reading and parsing JSON data received from URL reading and calls the Core Data Stack,
 (via MovieAPI) to actually create Core Data Entities.
 */
class RemoteReplicator: ReplicatorProtocol {
    
    fileprivate var movieAPI: MovieAPI!
    let url = "http://api.androidhive.info/json/movies.json"
    
    //Utilize Singleton pattern by instanciating Replicator only once.
    class var sharedInstance: RemoteReplicator {
        struct Singleton {
            static let instance = RemoteReplicator()
        }
        
        return Singleton.instance
    }
    
    init() {
        self.movieAPI = MovieAPI.sharedInstance
    }
    
    /**
     Pull movie data from a given QRCode resource, posts a notification to update
     datasource of a given/listening ViewController/UITableView.
     
     - Parameter completion: The Completion if needed, nil otherwise.
     */
    func fetchData() {
        guard let url = URL(string: url) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            self.processData(dataResponse)
        }
        task.resume()
    }
    
    /**
     Process data from a given resource Movie objects and assigning and calling the Movie API to persist Movies to the datastore.
     
     - Parameter jsonResult: The JSON content to be parsed and stored to Datastore.
     - Parameter completion: The Completion if needed, nil otherwise.
     - Returns: Void
     */
    func processData(_ jsonResult: Any?) {
        let jsonData = jsonResult as! Data
        var jsonResult: AnyObject!
        do {
            jsonResult = try JSONSerialization.jsonObject(with: jsonData) as AnyObject
        } catch let fetchError as NSError {
            print("pull error: \(fetchError.localizedDescription)")
        }
        
        if let movieList = jsonResult as? [AnyObject] {
            for movie in movieList {
                let movieItem: Dictionary<String, AnyObject> = movie as! Dictionary<String, AnyObject>
                let title = String(describing: movieItem["title"])
                
                //Call Movie API to persist Movie list to Datastore
                if !movieAPI.movieExists(title) {
                    movieAPI.saveMovie(movieItem)
                }
                
            }
        }
        NotificationCenter.default.post(name: Notification.Name.setStateLoading, object: nil)
    }
    

}
