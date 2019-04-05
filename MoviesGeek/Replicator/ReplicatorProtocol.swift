//
//  Replicator.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 05/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import Foundation

//Methods that must be implemented by every class that extends it.
protocol ReplicatorProtocol {
    func fetchData()
    func processData(_ jsonResult: Any?)
}
