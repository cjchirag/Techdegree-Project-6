//
//  JSONDownloader.swift
//  StarWars
//
//  Created by chirag on 26/09/19.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation
class JSONDownloader {
    let session: URLSession // URLSession instance: An object that coordinates a group of related network data transfer tasks.
    let decoder = JSONDecoder()
    
    //The URLSession class and related classes provide an API for downloading data from and uploading data to endpoints indicated by URLs.
    
    
    
    
   
    
    
    
    
    /*
     
     Loading is performed asynchronously, so your app can remain responsive and handle incoming data or errors as they arrive.
     
     You use a URLSession instance to create one or more URLSessionTask instances, which can fetch and return data to your app, download files, or upload data and files to remote locations. To configure a session, you use a URLSessionConfiguration object, which controls behavior like how to use caches and cookies, or whether to allow connections on a cellular network.
     
     Also, You can use one session repeatedly to create tasks. For example, a web browser might have separate sessions for regular and private browsing use, where the private session doesn’t cache its data.
     
     */
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration) // initialized
    }
    
    convenience init() {
        self.init(configuration: .default) // This init is further used when using this class in the future.
    }
    
    typealias JSON = [String: AnyObject]
    typealias JSONTaskCompletionHandler = (JSON?, StarWarsError?) -> Void
    
    //Once you have a session, you create a data task with one of the dataTask() methods. Tasks are created in a suspended state, and can be started by calling resume().
    
    
    
    
    func jsonTask(with request: URLRequest, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .invalidData)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        //let jsonResponse = try self.decoder.decode(T.self, from: data)
                        //let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                        //completion(json, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
            
        }
        
        return task
    }
}
