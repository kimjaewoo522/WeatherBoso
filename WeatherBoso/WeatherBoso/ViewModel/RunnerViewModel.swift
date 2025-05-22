//
//  RunnerViewModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation
import RxSwift

// 상속 불가
final class RunnerViewModel {
// 이 코드는 싱글톤(Singleton) 패턴을 구현하는 부분입니다. 이 패턴은 앱 전체에서 RunnerViewModel 인스턴스를 하나만 생성해서 공유하고 싶을 때 사용
    static let shared = RunnerViewModel()
    
// 외부에서 RunnerViewModel()로 새로운 인스턴스를 만드는 것을 막기 위해 생성자를 private으로 제한, 이로써 인스턴스가 오직 shared를 통해서만 생성되도록 합니다.
    private init() {}

    func fetchCoordinates(for query: String) -> Single<(latitude: String, longitude: String)> {
// 주소 문자열을 URL-safe하게 인코딩합니다 (예: 공백 → %20).
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query=\(encodedQuery)") else {
            return .error(GeocodingNetworkError.invalidUrl)
        }

        var request = URLRequest(url: url)
        request.setValue(Secret.naverClientID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue(Secret.naverClientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return GeocodingNetworkManager.shared.fetch(with: request)
        // .map { ... } RxSwift의 Single 타입에 대해 사용되는 변환 연산자, 네트워크 요청의 결과로 GeocodeResponse 타입을 받아, 그걸원하는 형식으로 바꾸고 리턴(튜플)
            .map { (response: GeocodeResponse) -> (latitude: String, longitude: String) in
                // response.adress 배열에서 첫번째 주소(first)가 존재하는지 확인하고, address에 바인딩
                guard let address = response.addresses.first else {
                    // 주소가 없는 경우 GeocodingNetworkError.dataFetchFail 예외를 발생시켜 실패를 리턴합니다.
                    throw GeocodingNetworkError.dataFetchFail
                }
                return (latitude: address.y, longitude: address.x)
            }
    }
}
