//
//  Movie.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 04/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import Foundation
import CoreData

/**
 Enum for Movie Entity member fields
*/
enum MovieAttributes:String {
    case
    title       = "title",
    image       = "image",
    rating      = "rating",
    releaseYear = "releaseYear",
    genre       = "genre"
    
    static let getAll = [
        title,
        image,
        rating,
        releaseYear,
        genre
    ]
}

@objc(Movie)

/**
 The Core Data Model: Movie
*/
class Movie: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var image: String
    @NSManaged var rating: Double
    @NSManaged var releaseYear: Int16
    @NSManaged var genre: [String]
}
