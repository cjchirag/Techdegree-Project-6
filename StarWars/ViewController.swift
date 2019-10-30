//
//  ViewController.swift
//  StarWars
//
//  Created by chirag on 24/09/19.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let client = StarWarsAPI<Person>()
        client.getAllData(for: .people) { result in
            switch result {
            case .success(let data):
                print("Fetching data")
                data.map() {print($0.name)}
            case .failure(let error):
                print("There's an error: \(error)")
            }
        }
        
        // Do any additional setup after loading the view.
    }


}

