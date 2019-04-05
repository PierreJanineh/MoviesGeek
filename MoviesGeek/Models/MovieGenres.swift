//
//  MovieGenres.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 04/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import Foundation

/**
 Enum for holding different entity type names (CoreData Models)
*/
enum EntityTypes: String {
    case Movie = "Movie"
    
    static let getAll = [Movie]
}
