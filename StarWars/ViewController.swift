//
//  ViewController.swift
//  StarWars
//
//  Created by chirag on 24/09/19.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var resultArray: [Person] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = StarWarsAPI<Person>()
        client.getAllData(for: .people) { resultant in
            switch resultant {
            case .success(let data):
                data.map() {$0.name}
            case .failure(let error):
                print("Error in controller")
                print(error)
            }
        }
        
        // Do any additional setup after loading the view.
    }


}

