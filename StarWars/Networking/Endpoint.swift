//
//  Endpoint.swift
//  StarWars
//
//  Created by chirag on 26/09/19.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation

protocol Endpoint {
    var base: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        components.queryItems = queryItems
        
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}

enum DataType: String {
    case Person = "people"
    case Vehicle = "vehicles"
    case Starship = "starships"
}

enum StarWars {
    case search(name: String, type: DataType)
    case data(type: DataType)
}

extension StarWars: Endpoint {
    var base: String {
        return "https://swapi.co"
    }
    
    var path: String {
        switch self {
        case .search(_, let type): return "/api/\(type.rawValue)"
        case .data(let type): return "/api/\(type.rawValue)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .search(let name,_):
            var result = [URLQueryItem]()
            let searchName = URLQueryItem(name: "search", value: name)
            result.append(searchName)
            return result
        case .data:
            return []
        }
    }
    
}
