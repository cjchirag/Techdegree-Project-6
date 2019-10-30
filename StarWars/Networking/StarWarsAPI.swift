//
//  StarWarsAPI.swift
//  StarWars
//
//  Created by LOGIN on 2019-09-29.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation

protocol Resource: Decodable {
    var name: String {get}
    var category: Category {get}
    var endpoint: StarWarsEndpoint {get}
}

enum Category {
    case people
    case vehicles
    case starships
}

class StarWarsAPI<T: Resource> {
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
            // To get the first Collection object
            self.getCollection(request: theRequest) { result in
                switch result{
                case .success(let data):
                    
                    var count = 0 // Starting point to count the number of T objects
                    var nextFlag = true //To check if there is a next string
                    var currentData = data //currentData stores the current Collection extracted
                    var currentArray = currentData.results // currentArray stores the current sets of T objects extracts from currentData
                    // This map function updates the first set of T datas received
                    currentArray.map() {
                        allDatas.append($0)
                        count = count + 1
                    }
                    // This while function continues until all the T objects are stored in the allDatas object
                    while count <= currentData.count { // loop will run until there is no next count
                        
                            nextFlag = true // To check if there is a next string
                        if currentData.next == nil {
                            //Write logic when you reach the last one. 
                            completion(.success(allDatas))
                        } else {
                            if let nextString = data.next, let nextURL = URL(string: nextString) {
                                let nextRequest = URLRequest(url: nextURL)
                                self.getCollection(request: nextRequest) { result in
                                    switch result{
                                    case .success(let data):
                                        currentData = data //The currentData is updated based on the new url
                                        currentArray = currentData.results //Results extracted from the new array
                                        currentArray.map() {
                                            allDatas.append($0)
                                            print("Working here for the: \(count)")
                                            count = count + 1
                                        }
                                    case .failure(let error):
                                        print("Error in getting the next object: \(error)")
                                    }
                                }
                            }
                        }
                        
                    }
                                        
                    case .failure(let error):
                            print("Error in getting the next object")
                                    }
                                }
                             
                            }
    

    
    func getData(for request: URLRequest, completion: @escaping (Result<[T], StarWarsError>) -> Void) {
        
        getCollection(request: request) { result in
            switch result{
            case .success(let data):
                do{
                    let resultData = data.results
                    data.results.map() {print("Getting data for: \($0.name)")}
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
