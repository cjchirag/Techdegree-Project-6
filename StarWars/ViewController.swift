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
        var URLS: [String] = []
        var firstCollection: CollectionResults<Person>?
        client.getCollection(request: StarWarsEndpoint.people.request) { result in
            switch result {
            case .success(let data):
                client.getURLS(with: data) { result in
                    switch result{
                    case .success(let datas):
                        URLS = datas
                        print(URLS.count)
                        print(URLS)
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
        // Do any additional setup after loading the view.
    }


}

