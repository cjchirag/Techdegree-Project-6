//
//  StarWarsAPI.swift
//  StarWars
//
//  Created by LOGIN on 2019-09-29.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation





class StarWarsAPI<T: Decodable> {
    let session: URLSession
    
    init(configuration: URLSessionConfiguration){
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    let decoder = JSONDecoder()
    
}

private extension StarWarsAPI {
    static func getCollection(request: URLRequest, completion: @escaping (Result<CollectionResults<T>, StarWarsError>) -> Void){
        performRequestWith(request: request) { result in
            switch result {
            case .success(let data):
                    let jsonResponse = try self.decoder.decode(CollectionResults<T>.self, from: data)
                    completion(.success(jsonResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    static func performRequestWith(request: URLRequest, completion: @escaping (Result<Data, StarWarsError>) -> Void) {
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(.failure(.invalidData))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.requestFailed))
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    completion(.failure(.responseUnsuccessful))
                    return
                }
                completion(.success(data))
            }
        }
        task.resume()
    }
}
