//
//  ViewController.swift
//  StarWars
//
//  Created by chirag on 24/09/19.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var data: UIButton!
    @IBAction func databutton(_ sender: Any) {
       

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let client = StarWarsAPI<Person>()
        client.getAllData(for: .people) {result in
            print(result)
        }
        
        // Do any additional setup after loading the view.
    }


}

