//
//  BaseAPI.swift
//  ImageFinder
//
//  Created by jae on 2022/12/10.
//

import Foundation
import Alamofire
import RxSwift

class BaseAPI {
    
    /*
     AF.request(host + path,
     method: .get,
     parameters: imageParms,
     encoder: URLEncodedFormParameterEncoder(destination: .queryString),
     headers: headers
     )
     */
    
//    func request<C: Codable>(url: String, method: Alamofire.HTTPMethod, parameters: Parameters, headers: HTTPHeaders, encoder: URLEncodedFormParameterEncoder) -> Single<C> {
//
//        return Single<C>.create { single in
//            let request = AF.request(
//                url,
//                method: method,
//                parameters: parameters,
//                headers: headers
//            ).responseData { response in
//                switch response.result {
//                case let .success(jsonData):
//                    do {
//                        let returnObject = try JSONDecoder().decode(C.self, from: jsonData)
//                        single(.success(returnObject))
//                    } catch {
//                       print("Parsing Error")
//                    }
//                case let .failure(error):
//                    single(.success(nil))
//                }
//            }
//
//            return Disposables.create {
//                //                request.cancel()
//
//            }
//        }
//
//    }
    
    
}



/*
 return Single<NetworkResult<C>>.create { single in
 let request = AF.request(
 url,
 method: method,
 parameters: parameters,
 headers: headers
 ).responseData { response in
 switch response.result {
 case let .success(jsonData):
 do {
 let returnObject = try JSONDecoder().decode(C.self, from: jsonData)
 single(.success(.success(returnObject)))
 } catch {
 single(.failure(NSError(domain: "Parsing error", code: -2)))
 }
 case let .failure(error):
 single(.success(.error(error)))
 }
 }
 
 return Disposables.create {
 //                request.cancel()
 
 }
 }
 */
