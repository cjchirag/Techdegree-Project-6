//
//  StarWarsAPI.swift
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
enum StarWarsError: Error {
    case requestFailed
    case responseUnsuccessful
    case invalidData
    case jsonConversionFailure
    case jsonParsingFailure(message: String)
}

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
    private static var session: URLSession {
        return URLSession(configuration: .default)
    }
    
    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
    }
    
    func getAllData(for category: Category, completion: @escaping (Result<[T], StarWarsError>) -> Void) {
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
            // To get the first Collection object
            StarWarsAPI.getCollection(request: theRequest) { result in
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
                            //These statements are executed when we reach the final T collection.
                            currentArray = currentData.results
                            currentArray.map() {
                                allDatas.append($0)
                                print("We are at the last one!Yaay :D")
                                count = count + 1
                            }
                            completion(.success(allDatas))
                        } else {
                            if let nextString = data.next, let nextURL = URL(string: nextString) {
                                let nextRequest = URLRequest(url: nextURL)
                                StarWarsAPI.getCollection(request: nextRequest) { result in
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
    }
    
    
    
    func getData(for request: URLRequest, completion: @escaping (Result<[T], StarWarsError>) -> Void) {
        
        StarWarsAPI<T>.getCollection(request: request) { result in
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
    
    private static func getCollection(request: URLRequest, completion: @escaping (Result<CollectionResults<T>, StarWarsError>) -> Void) {
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
    
    
    private static func performRequestWith(request: URLRequest, completion: @escaping (Result<Data, StarWarsError>) -> Void) {
        
        
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


class Person: Resource, Decodable {
    var name: String
    var height: String
    var mass: String
    var hair_color: String
    var skin_color: String
    var eye_color: String
    var birth_year: String
    var gender: String
    var homeworld: String
    var films: [String]
    var species: [String]
    var vehicles: [String]
    var starships: [String]
    
    init(Name: String, Height: String, Mass: String, Hair_Color: String, Skin_Color: String, Eye_Color: String, Birth_Year: String, Gender: String, HomeWorld: String, Films: [String], Species: [String], Vehicles: [String], Starships: [String]) {
        self.name = Name
        self.height = Height
        self.mass = Mass
        self.hair_color = Hair_Color
        self.skin_color = Skin_Color
        self.eye_color = Eye_Color
        self.birth_year = Birth_Year
        self.gender = Gender
        self.homeworld = HomeWorld
        self.films = Films
        self.species = Species
        self.vehicles = Vehicles
        self.starships = Starships
    }
}
extension Person {
    convenience init?(json: [String: Any]) {
        
        struct key {
            static let name = "name"
            static let height = "height"
            static let mass = "mass"
            static let hair_color = "hair_color"
            static let skin_color = "skin_color"
            static let eye_color = "eye_color"
            static let birth_year = "birth_year"
            static let gender = "gender"
            static let homeworld = "homeworld"
            static let films = "films"
            static let species = "species"
            static let vehicles = "vehicles"
            static let starships = "starships"
        }
        
        guard let name = json[key.name] as? String,
            let height = json[key.height] as? String,
            let mass = json[key.mass] as? String,
            let hair_color = json[key.hair_color] as? String,
            let skin_color = json[key.skin_color] as? String,
            let eye_color = json[key.eye_color] as? String,
            let birth_year = json[key.birth_year] as? String,
            let gender = json[key.gender] as? String,
            let homeworld = json[key.homeworld] as? String,
            let films = json[key.films] as? [String],
            let species = json[key.species] as? [String],
            let vehicles = json[key.vehicles] as? [String],
            let starships = json[key.starships] as? [String]
            else { return nil }
        
        self.init(Name: name, Height: height, Mass: mass, Hair_Color: hair_color, Skin_Color: skin_color, Eye_Color: eye_color, Birth_Year: birth_year, Gender: gender, HomeWorld: homeworld, Films: films, Species: species, Vehicles: vehicles, Starships: starships)
    }
    private enum CodingKeys: String, CodingKey {
        case name
        case height
        case mass
        case hair_color
        case skin_color
        case eye_color
        case gender
        case birth_year
        case vehicles
        case starships
        case films
        case species
        case homeworld
    }
}

extension Person {
    var category: Category {
        return .people
    }
    
    var endpoint: StarWarsEndpoint {
        return .people
    }
}



var peoples: [String] = []

let client = StarWarsAPI<Person>()
client.getAllData(for: .people) { result in
    switch result {
    case .success(let data):
        print("Fetching data")
        data.map() {peoples.append($0.name)}
    case .failure(let error):
        print("There's an error: \(error)")
    }
}
peoples
