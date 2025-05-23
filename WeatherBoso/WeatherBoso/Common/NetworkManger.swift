//
//  NetworkManger.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case invalidUrl
    case dataFetchFail
    case decodingFail
}

// 네트워크 로직이 필요할때 앱의 모든 곳에서 사용할 수 있는 싱글톤 네트워크 매니저.
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // 네트워크 로직을 수행하고, 결과를 Single 로 리턴함.
    // Single 은 오직 한 번만 값을 뱉는 Observable 이기 때문에 서버에서 데이터를 한 번 불러올 때 적절.
    func fetch<T: Decodable>(url: URL) -> Single<T> {
        return Single.create { observer in
            print("API 요청 시작: \(url.absoluteString)")
            let session = URLSession(configuration: .default)
            session.dataTask(with: URLRequest(url: url)) { data, response, error in
                // error 가 있다면 Single 에 fail 방출.
                if let error = error {
                    print("통신 에러: \(error)")
                    observer(.failure(error))
                    return
                }
                
                // data 가 없거나 http 통신 에러 일 때 dataFetchFail 방출.
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    print("응답 실패 혹은 상태 코드 이상")
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedData = try decoder.decode(T.self, from: data)
                    print("디코딩 성공")
                    observer(.success(decodedData))
                } catch {
                    // 디코딩 실패했다면 decodingFail 방출.
                    print("디코딩 실패")
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
