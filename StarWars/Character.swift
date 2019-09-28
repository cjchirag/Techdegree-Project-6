//
//  Character.swift
//  StarWars
//
//  Created by chirag on 24/09/19.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation


class Person {
    var name: String
    var height: Int
    var mass: Int
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
        self.height = Int(Height) ?? 0
        self.mass = Int(Mass) ?? 0
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
}

