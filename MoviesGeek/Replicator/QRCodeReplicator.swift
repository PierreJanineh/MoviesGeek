//
//  QRCodeReplicator.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 05/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import UIKit
/**
 QRCode Replicator handles reading and parsing JSON data received from reading QRCodes and calls the Core Data Stack,
 (via MovieAPI) to actually create Core Data Entities.
 */
class QRCodeReplicator: ReplicatorProtocol {
    
    fileprivate var movieAPI: MovieAPI!
    
    //Utilize Singleton pattern by instanciating Replicator only once.
    class var sharedInstance: QRCodeReplicator {
        struct Singleton {
            static let instance = QRCodeReplicator()
        }
        
        return Singleton.instance
    }
    
    init() {
        self.movieAPI = MovieAPI.sharedInstance
    }
    
    /**
     Pull movie data from a given Remote resource, posts a notification to update
     datasource of a given/listening ViewController/UITableView.
     */
    func fetchData() {
        
    }
    
    func processData(_ jsonResult: Any?) {
        let jsonString = jsonResult as! String
        var jsonResult: AnyObject!
        do {
            jsonResult = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as AnyObject
        } catch let fetchError as NSError {
            print("pull error: \(fetchError.localizedDescription)")
        }
        
        if let movieList = jsonResult as? AnyObject {
            let movieItem: Dictionary<String, AnyObject> = movieList as! Dictionary<String, AnyObject>
            let title = String(describing: movieItem["title"])
            
            //Call Movie API to persist Movie list to Datastore
            if !movieAPI.movieExists(title) {
                movieAPI.saveMovie(movieItem)
            }
        }
        NotificationCenter.default.post(name: Notification.Name.updateMoviesTableData, object: nil)
    }
    
    
}
