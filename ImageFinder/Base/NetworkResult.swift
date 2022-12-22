//
//  NetworkResult.swift
//  ImageFinder
//
//  Created by jae on 2022/12/10.
//

import Foundation
import Alamofire

enum NetworkResult<C:Codable, E: NSError> {
    case success(C)
    case falied(E)
}

//enum NetworkError: Int, Error {
//    case badRequest = 400
//    case authenticationFailed = 401
//    case notFoundException = 404
//    case contentLengthError = 413
//    case quotaExceeded = 429
//    case systemError = 500
//    case endpointError = 503
//    case timeout = 504
//}
