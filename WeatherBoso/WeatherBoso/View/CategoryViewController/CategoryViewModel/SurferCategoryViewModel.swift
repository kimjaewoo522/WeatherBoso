//
//  SurferCategoryViewModel.swift
//  WeatherBoso
//
//  Created by 김기태 on 5/23/25.
//

import Foundation
import RxSwift
import RxRelay

final class SurferCategoryViewModel {
    private let weatherService = WeatherService()
    
    struct BeachLocation {
        let name: String
        let imageName: String
        let lat: Double
        let lon: Double
        let keyword: [String]
    }
    
    private let beachList: [BeachLocation] = [
        BeachLocation(name: "죽도해변", imageName: "Yangyang1", lat: 37.96, lon: 128.88, keyword: ["죽도", "양양"]),
        BeachLocation(name: "설악해변", imageName: "Yangyang2", lat: 38.13, lon: 128.79, keyword: ["설악", "양양"]),
        BeachLocation(name: "월포해변", imageName: "Yangyang3", lat: 36.21, lon: 129.46, keyword: ["월포", "포항"]),
        BeachLocation(name: "만리포해변", imageName: "Yangyang4", lat: 36.79, lon: 126.13, keyword: ["만리포", "태안"])
    ]
    
    // 검색어 입력을 처리할 Relay
    let searchText = BehaviorRelay<String>(value: "")
    
    func fetchFilteredBeachSections() -> Observable<[BeachSection]> {
        // Observable 리턴
        return searchText
        // 검색어 바뀔때 새롭게 필터링, 같은 값이면 무시(한번만 반응)
            .distinctUntilChanged()
        // 최신 값만 처리, query는 현재 검색어
            .flatMapLatest { [unowned self] query -> Observable<[BeachSection]> in
                // 삼항 연산자
                let filtered = query.isEmpty
                ? beachList
                : beachList.filter { location in
                    location.keyword.contains {
                        // 대소문자 구분없이 포함 여부 확인
                        $0.localizedCaseInsensitiveContains(query) }
                }
                
                let beachObservables = filtered.map { location in
                    weatherService.fetchWeather(latitude: location.lat, longitude: location.lon)
                        .map { weather in
                            Beach(name: location.name,
                                  imageName: location.imageName,
                                  temperature: weather.temperature,
                                  weatherStatus: weather.weatherCode,
                                  latitude: location.lat,
                                  longitude: location.lon)
                        }
                }
                
                return Observable.combineLatest(beachObservables)
                    .map { beaches in
                        [BeachSection(items: beaches)]
                    }
            }
    }
}
