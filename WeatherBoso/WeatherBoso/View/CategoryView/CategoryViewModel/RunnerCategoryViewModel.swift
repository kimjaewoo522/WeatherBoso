//
//  RunnerCategoryViewModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/26/25.
//

import Foundation
import RxSwift
import RxCocoa

final class RunnerCategoryViewModel {
    
    private let apiKey = "8b75ef2c71a36b9d2f481894ddda0ded"
    
    struct RunningLocation {
        let name: String
        let imageName: String
        let lat: Double
        let lon: Double
    }
    
    private let RunningList: [RunningLocation] = [
        RunningLocation(name: "마포대교", imageName: "Mapo", lat: 37.53, lon: 126.93),
        RunningLocation(name: "석촌호수", imageName: "Sukchon", lat: 37.51, lon: 127.10),
        RunningLocation(name: "남산공원", imageName: "Namsan", lat: 37.55, lon: 126.99),
        RunningLocation(name: "서울숲", imageName: "SeoulForest", lat:  37.54, lon: 127.03),
        RunningLocation(name: "갈맷길 4코스", imageName: "Galmat", lat: 36.21, lon: 129.46),
        RunningLocation(name: "여의도 공원", imageName: "Yeoui", lat: 37.52, lon: 126.92),
        RunningLocation(name: "온천천", imageName: "onchun", lat: 35.19, lon: 129.10),
        RunningLocation(name: "안양천", imageName: "Anyang", lat: 37.52, lon: 126.88),
        RunningLocation(name: "백운호수", imageName: "Baekwoon", lat: 37.38, lon: 127.00)
    ]
    
    func fetchRunningSpotSections() -> Observable<[RunningSpotSection]> {
        let spotObservables = RunningList.map { location -> Single<RunningSpot> in
            let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.lat)&lon=\(location.lon)&appid=\(apiKey)&units=metric&lang=kr"
            guard let url = URL(string: urlString) else {
                return .error(NetworkError.invalidUrl)
            }
            return NetworkManager.shared.fetch(url: url)
                .map { (response: RiderResponse) in
                    guard let firstEntry = response.list.first else {
                        return RunningSpot(
                            name: location.name,
                            imageName: location.imageName,
                            temperature: "--",
                            weatherStatus: "정보 없음",
                            lat: location.lat,
                            lon: location.lon
                        )
                    }
                    let temp = "\(Int(firstEntry.main.temp))℃"
                    let weather = firstEntry.weather.first?.description ?? "정보 없음"
                    return RunningSpot(
                        name: location.name,
                        imageName: location.imageName,
                        temperature: temp,
                        weatherStatus: weather,
                        lat: location.lat,
                        lon: location.lon
                    )
                }
        }
        return Observable.zip(spotObservables.map { $0.asObservable() })
            .map { spots in
                [RunningSpotSection(items: spots)]
            }
    }
}
