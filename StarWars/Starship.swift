//
//  Starship.swift
//  StarWars
//
//  Created by chirag on 24/09/19.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation

class Starship {
    var name: String
    var model: String
    var manufacturer: String
    var cost_in_credits: Int
    var length: Int
    var max_atmosphering_speed: Int
    var crew: Int
    var passengers: Int
    var cargo_capacity: Int
    var consumables: Int
    var hyperdrive_rating: Int
    var MGLT: Int
    var starship_class: String
    var pilots: [String]
    var films: [String]
    
    init(Name: String, Model: String, Manufacturer: String, Cost_In_Credits: String, Length: String, Max_Atmosphering_Speed: String, Crew: String, Passengers: String, Cargo_Capacity: String, Consumables: String, Hyperdrive_Rating: String, mglt: String, Starship_Class: String, Pilots: [String], Films: [String]){
        self.name = Name
        self.model = Model
        self.manufacturer = Manufacturer
        self.cost_in_credits = Int(Cost_In_Credits) ?? -1
        self.length = Int(Length) ?? -1
        self.max_atmosphering_speed = Int(Max_Atmosphering_Speed) ?? -1
        self.crew = Int(Crew) ?? -1
        self.passengers = Int(Passengers) ?? -1
        self.cargo_capacity = Int(Cargo_Capacity) ?? -1
        self.consumables = Int(Consumables) ?? -1
        self.hyperdrive_rating = Int(Hyperdrive_Rating) ?? -1
        self.MGLT = Int(mglt) ?? -1
        self.starship_class = Starship_Class
        self.pilots = Pilots
        self.films = Films
    }
}
// MARK: Write conv inits ine extension!!

extension Starship {
    convenience init?(json: [String:Any]) {
        
        struct key {
            static let name = "name"
            static let model = "model"
            static let manufacturer = "manufacturer"
            static let cost_in_credits = "cost_in_credits"
            static let length = "length"
            static let max_atmosphering_speed = "max_atmosphering_speed"
            static let crew = "crew"
            static let passengers = "passengers"
            static let cargo_capacity = "cargo_capacity"
            static let consumables = "consumables"
            static let hyperdrive_rating = "hyperdrive_rating"
            static let MGLT = "MGLT"
            static let starship_class = "starship_class"
            static let pilots = "pilots"
            static let films = "films"
        }
        
        guard let name = json[key.name] as? String,
            let model = json[key.model] as? String,
            let manufacturer = json[key.manufacturer] as? String,
            let cost_in_credits = json[key.cost_in_credits] as? String,
            let length = json[key.length] as? String,
            let max_atmosphering_speed = json[key.max_atmosphering_speed] as? String,
            let crew = json[key.crew] as? String,
            let passengers = json[key.passengers] as? String,
            let cargo_capacity = json[key.cargo_capacity] as? String,
            let consumables = json[key.consumables] as? String,
            let hyperdrive_rating = json[key.hyperdrive_rating] as? String,
            let MGLT = json[key.MGLT] as? String,
            let starship_class = json[key.starship_class] as? String,
            let pilots = json[key.pilots] as? [String],
            let films = json[key.films] as? [String]
            else { return nil }
        
        self.init(Name: name, Model: model, Manufacturer: manufacturer, Cost_In_Credits: cost_in_credits, Length: length, Max_Atmosphering_Speed: max_atmosphering_speed, Crew: crew, Passengers: passengers, Cargo_Capacity: cargo_capacity, Consumables: consumables, Hyperdrive_Rating: hyperdrive_rating, mglt: MGLT, Starship_Class: starship_class, Pilots: pilots, Films: films)
        
    }
}

