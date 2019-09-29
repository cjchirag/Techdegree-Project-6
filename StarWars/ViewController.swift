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
        var storedData: [String] = []
        let client = APIClient()
        client.AllCharacters() { data, error in
            print(data[1].name)
        }
        client.AllVehicles() { data, error in
            storedData = data[3].films
            print(" Yeah there you go\(storedData)")
        }
        print("2nd time Stored Data print")
        // Do any additional setup after loading the view.
    }


}

