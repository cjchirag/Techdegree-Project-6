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
    static var session: URLSession {
        return URLSession(configuration: .default)
    }
    
    static var decoder: JSONDecoder{
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
    }
    
    // How to use groups
    //Error handling over here
    //Pages vs. Ts!! Think about this and refactor a bit.
    
    func getDatas(_ urlrequest: URLRequest) -> [T] {
        var datas: [T] = []
        var urls: [URL]?
        
        DispatchQueue.global(qos: .background).async {
        StarWarsAPI.getURLS(request: urlrequest) { result in
            switch result{
            case .success(let data):
                var count = 0
                for url in data{
                    urls?[count] = url
                    count = count + 1
                }
            case .failure(let error):
                print("Error in collecting urls")
            }
        }
    }
        
        guard let yurls = urls else {
            return []
        }
        
        DispatchQueue.global(qos: .background).async {
        StarWarsAPI.getData(yurls) { result in
            switch result{
            case .success(let data):
                var count = 0
                for d in data{
                    datas[count] = d
                    count = count + 1
                    print(d)
                }
            case .failure(let error):
                print("An error has occured")
            }
        }
    }
        return datas
        
    }
    
    

    static func getData(_ urls: [URL], completion: @escaping (Result<[T],StarWarsError>) -> Void) {
        var datas: [T] = []
        let group = DispatchGroup()
        var count = 0
        
        
        DispatchQueue.global(qos: .background).async {
        for url in urls {
            group.enter()
            getTS(request: URLRequest(url: url)) { result in
                
                switch result{
                case .success(let data):
                    for resource in data {
                        datas[count] = resource
                        count += 1
                    }
                    completion(.success(datas))
                    group.leave()
                case .failure(let error):
                    group.leave()
                    completion(.failure(error))
                }
            }
        }
    }
        
    }
    
    static func getURLS(request: URLRequest, completion: @escaping (Result<[URL],StarWarsError>) -> Void) {
        var URLList: [URL] = []
        DispatchQueue.global(qos: .background).async {
        getCollection(request: request) { result in
            switch result {
            case .success(let data):
                guard let urlstring = data.next else {
                    return
                }
                let urlOptional = URL(string: urlstring)
                guard let url = urlOptional else {
                    return
                }
                URLList.append(url)
                completion(.success(URLList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
    
}


extension StarWarsAPI {
    
    static func getTS(request: URLRequest, completion: @escaping (Result<[T], StarWarsError>) -> Void) {
        
        performRequestWith(request: request) { result in
            switch result{
            case .success(let data):
                do{
                    let jsonResponse = try self.decoder.decode([T].self, from: data)
                    completion(.success(jsonResponse))
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
    
     static func getCollection(request: URLRequest, completion: @escaping (Result<CollectionResults<T>, StarWarsError>) -> Void) {
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

/*
 static func getData(request: URLRequest, completion: @escaping (Result<CollectionResults<T>, StarWarsError>) -> Void) {
 performRequestWith(request: request, completion: <#T##(Result<Data, StarWarsError>) -> Void#>)
 }
 */


/*
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
 */
