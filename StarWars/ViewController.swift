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
        var client = StarWarsAPI<Person>()
        var endpoint = StarWarsEndpoint.people
        print(endpoint.request)
        client.test(request: endpoint.request)
        // Do any additional setup after loading the view.
    }


}

