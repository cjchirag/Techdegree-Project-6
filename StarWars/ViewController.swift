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
        
        let client = APIClient()
        client.AllCharacters() { data, error in
            print(data[1].name)
        }
        client.AllVehicles() { data, error in
            print(data[1].films)
        }
        // Do any additional setup after loading the view.
    }


}

