//
//  Interacotor.swift
//  ImageFinder
//
//  Created by jae on 2022/12/11.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol InteractorProtocol {
    func getImages(parmas: ImageParams) -> Single<ImageResponse?>
}

class Interactor: InteractorProtocol {
    
    
    let host = "https://dapi.kakao.com"
    let path = "/v2/search/image"
    var headers: HTTPHeaders = [
        "Accept": "application/json",
        "Connection": "keep-alive"
    ]
    
    func getImages(parmas: ImageParams) -> Single<ImageResponse?> {
        
        self.setAPIKey()
        
        return Single<ImageResponse?>.create { single in
            let request = AF.request(
                self.host + self.path,
                method: .get,
                parameters: parmas,
                headers: self.headers
            ).responseData { response in
                switch response.result {
                case let .success(jsonData):
                    do {
                        let returnObject = try JSONDecoder().decode(ImageResponse.self, from: jsonData)
                        single(.success(returnObject))
                    } catch {
                        single(.success(nil))
                    }
                case .failure(_):
                    single(.success(nil))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    fileprivate func setAPIKey() {
        let apiKey = "KakaoAK 4997a16baff313b2bf87060c34b708f0"

        guard let kakaoAPI = Bundle.main.object(forInfoDictionaryKey: "KakaoAPI") as? [String: String],
              let apiKey = kakaoAPI["key"]
        else { return }
        
        self.headers.add(name: "Authorization", value: apiKey)
    }
}

struct ImageParams: Codable {
    let query: String
    let sort: String
    let page: Int
    let size: Int
}

