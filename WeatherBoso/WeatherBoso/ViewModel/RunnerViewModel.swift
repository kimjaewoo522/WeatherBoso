//
//  RunnerViewModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation
import RxSwift

import Foundation
import RxSwift

final class RunnerViewModel {
    static let shared = RunnerViewModel()
    private init() {}

    // API Key (openweathermap)
    private let apiKey = "8b75ef2c71a36b9d2f481894ddda0ded"
    private let disposeBag = DisposeBag()

    // MARK: - Subjects
    let weatherEntry = BehaviorSubject<[WeatherEntry]?>(value: nil)
    let airPollutionResponse = BehaviorSubject<AirPollutionData?>(value: nil)
    let nowWeather = BehaviorSubject<WeatherEntry?>(value: nil)

    // MARK: - Geocoding
    func fetchCoordinates(for query: String) -> Single<(latitude: String, longitude: String)> {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query=\(encodedQuery)") else {
            return .error(GeocodingNetworkError.invalidUrl)
        }

        var request = URLRequest(url: url)
        request.setValue(Secret.naverClientID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue(Secret.naverClientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return GeocodingNetworkManager.shared.fetch(with: request)
            .map { (response: GeocodeResponse) -> (latitude: String, longitude: String) in
                guard let address = response.addresses.first else {
                    throw GeocodingNetworkError.dataFetchFail
                }
                return (latitude: address.y, longitude: address.x)
            }
    }

    // MARK: - 날씨 정보
    func fetchWeatherInfo(lat: Double, lon: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=kr"
        guard let url = URL(string: urlString) else {
            weatherEntry.onError(NetworkError.invalidUrl)
            return
        }

        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { (response: RiderResponse) in
                self.weatherEntry.onNext(response.list)
                let now = self.nowWeather(from: response.list)
                self.nowWeather.onNext(now)
            }, onFailure: { error in
                self.weatherEntry.onError(error)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 대기질 정보
    func fetchAirQuality(lat: Double, lon: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            airPollutionResponse.onError(NetworkError.invalidUrl)
            return
        }

        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { (response: AirPollutionResponse) in
                self.airPollutionResponse.onNext(response.list.first)
            }, onFailure: { error in
                self.airPollutionResponse.onError(error)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 현재 날씨 추출
    func nowWeather(from list: [WeatherEntry]) -> WeatherEntry? {
        let now = Date().timeIntervalSince1970
        return list.min(by: { abs($0.dt - now) < abs($1.dt - now) })
    }
}
