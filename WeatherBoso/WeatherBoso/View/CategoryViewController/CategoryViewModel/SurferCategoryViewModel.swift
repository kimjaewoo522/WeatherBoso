//
//  SurferCategoryViewModel.swift
//  WeatherBoso
//
//  Created by 김기태 on 5/23/25.
//

import Foundation
import RxSwift

final class SurferCategoryViewModel {
    
    private let weatherService = WeatherService()
    
    struct BeachLocation {
        let name: String
        let imageName: String
        let lat: Double
        let lon: Double
    }
    
    private let beachList: [BeachLocation] = [
        BeachLocation(name: "죽도해변", imageName: "Yangyang1", lat: 37.96, lon: 128.88),
        BeachLocation(name: "설악해변", imageName: "Yangyang2", lat: 38.13, lon: 128.79),
        BeachLocation(name: "월포해변", imageName: "Yangyang3", lat: 36.21, lon: 129.46),
        BeachLocation(name: "만리포해변", imageName: "Yangyang4", lat: 36.79, lon: 126.13)


    ]
    
    func fetchBeachSections() -> Observable<[BeachSection]> {
        let beachObservables = beachList.map { location in
            weatherService.fetchWeather(latitude: location.lat, longitude: location.lon)
                .map { temp, weather in
                    Beach(name: location.name,
                          imageName: location.imageName,
                          temperature: temp,
                          weatherStatus: weather)
                }
        }
        
        return Observable.zip(beachObservables)
            .map { beaches in
                [BeachSection(items: beaches)]
            }
    }
}
