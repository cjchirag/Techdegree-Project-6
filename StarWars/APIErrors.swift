//
//  APIErrors.swift
//  StarWars
//
//  Created by chirag on 26/09/19.
//  Copyright © 2019 Chirag Jadhwani. All rights reserved.
//

import Foundation

enum SWAPIError: Error {
    case requestFailed
    case responseUnsuccessful
    case invalidData
    case jsonConversionFailure
    case jsonParsingFailure(message: String)
}
