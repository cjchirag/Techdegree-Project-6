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
        
        func getCharacter(completion: @escaping ([Person], StarWarsError?) -> Void) -> [Person] {
            let client = StarWarsAPI<Person>()
            var data: [Person] = []
            client.getData(for: .people) { result in
                switch result{
                case .success(let datas):
                    data = datas
                case .failure(let error):
                    print(error)
                }
            }
            return data
        }
        getCharacter() { persons, error in
            if error != nil {
                print("An error here")
            } else {
                print(persons)
            }
        }
        // Do any additional setup after loading the view.
    }


}

