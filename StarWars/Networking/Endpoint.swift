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
    var queryItem: URLQueryItem? { get }
}

extension Endpoint {
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        
        if let queryItem = queryItem {
            components.queryItems = [queryItem]
        }
        
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}


enum StarWarsEndpoint: String {
    case people
    case starships
    case vehicles
    case films
}

extension StarWarsEndpoint: Endpoint {
    var queryItem: URLQueryItem? {
        return nil
    }
    
    var base: String {
        return "https://swapi.co"
    }
    
    var path: String {
        return "/api/\(self.rawValue)"
    }
    
}
