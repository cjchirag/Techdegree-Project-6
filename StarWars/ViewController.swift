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
    var resultArray: [Person] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let client = StarWarsAPI<Person>()
        client.getAllData(for: .people) { resultant in
            switch resultant {
            case .success(let data):
                print("this")
            case .failure(let error):
                print("Error in controller")
                print(error)
            }
        }
        
        // Do any additional setup after loading the view.
    }


}

