//
//  CollectionResults.swift
//  StarWars
//
//  Created by LOGIN on 2019-09-29.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation

struct CollectionResults<T: Resource>: Decodable where T: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
    
    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
}
