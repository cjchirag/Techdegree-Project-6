//
//  StarWarsAPI.swift
//  StarWars
//
//  Created by LOGIN on 2019-09-29.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation

protocol Resource {
    var name: String {get}
    var category: Category {get}
    var endpoint: StarWarsEndpoint {get}
}

enum Category {
    case people
    case vehicles
    case starships
}

class StarWarsAPI<T: Resource> where T: Decodable {
    let session: URLSession
    
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    var decoder: JSONDecoder{
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
    }
   
    func getAllData(for category: Category, completion: @escaping (Result<[T], StarWarsError>) -> Void) {
        var group = DispatchGroup()
        var request: URLRequest?
        var allDatas: [T] = []
        if category == .people {
            let endpoint = StarWarsEndpoint.people
            request = endpoint.request
        } else if category == .vehicles {
            let endpoint = StarWarsEndpoint.vehicles
            request = endpoint.request
        } else if category == .starships {
            let endpoint = StarWarsEndpoint.starships
            request = endpoint.request
        }
        guard let theRequest = request else {
            completion(.failure(.requestFailed))
            return
        }
        DispatchQueue.global(qos: .background).async {
            
            self.getCollection(request: theRequest) { result in
                switch result{
                case .success(let data):
                    group.enter()
                    var count = 0
                    var nextFlag = true
                    var resultArray = data.results //First set of collection
                    
                    
                    while nextFlag == true { // loop will run until there is no next page
                        for value in resultArray {
                            allDatas.append(value) // Adding sets of collection to the alldata array
                        }
                        if data.next == nil {
                            nextFlag = false
                        } else {
                            nextFlag = true
                            if let nextString = data.next, let nextURL = URL(string: nextString) {
                                let nextRequest = URLRequest(url: nextURL)
                                self.getData(for: nextRequest) { result in
                                    switch result{
                                    case .success(let data):
                                        resultArray = data
                                        print("Working here for the: \(count)")
                                        group.leave()
                                    case .failure(let error):
                                        group.leave()
                                        print("Error in getting the next object")
                                    }
                                }
                             group.wait()
                            }
                        }
                        count = count + 1
                    }
                    
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                    group.leave()
                }
            }
        }
        group.notify(queue: .main){
        completion(.success(allDatas))
        }
        
    }
    
    func getData(for request: URLRequest, completion: @escaping (Result<[T], StarWarsError>) -> Void) {
        
        getCollection(request: request) { result in
            switch result{
            case .success(let data):
                do{
                    let resultData = data.results
                    completion(.success(resultData))
                }  catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context){
                    print("Key: \(key) not found. There is an error")
                    print("CodingPath: \(context.codingPath)")
                } catch let DecodingError.valueNotFound(value, context){
                    print("Value: \(value) not found")
                    print("CodingPath:", context.codingPath)
                } catch {
                    print("Error: ", error)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}


extension StarWarsAPI {
    
     private func getCollection(request: URLRequest, completion: @escaping (Result<CollectionResults<T>, StarWarsError>) -> Void) {
        performRequestWith(request: request) { result in
            switch result{
            case .success(let data):
                do {
                    let jsonResponse = try self.decoder.decode(CollectionResults<T>.self, from: data)
                    completion(.success(jsonResponse))
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context){
                    print("Key: \(key) not found. There is an error")
                    print("CodingPath: \(context.codingPath)")
                } catch let DecodingError.valueNotFound(value, context){
                    print("Value: \(value) not found")
                    print("CodingPath:", context.codingPath)
                } catch {
                    print("Error: ", error)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
     private func performRequestWith(request: URLRequest, completion: @escaping (Result<Data, StarWarsError>) -> Void) {
        
        
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
