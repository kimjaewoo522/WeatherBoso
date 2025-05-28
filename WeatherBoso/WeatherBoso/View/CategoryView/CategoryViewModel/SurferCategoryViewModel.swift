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
    let isLoading = BehaviorRelay<Bool>(value: false)

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
        BeachLocation(name: "만리포해변", imageName: "Yangyang4", lat: 36.79, lon: 126.13, keyword: ["만리포", "태안"]),
        BeachLocation(name: "중문해변", imageName: "Yangyang5", lat: 36.79, lon: 126.13, keyword: ["중문", "제주"]),
        BeachLocation(name: "이호테우해변", imageName: "Yangyang6", lat: 36.79, lon: 126.13, keyword: ["이호테우", "제주"]),
        BeachLocation(name: "송정해변", imageName: "Yangyang7", lat: 36.79, lon: 126.13, keyword: ["송정", "부산"])
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
                self.isLoading.accept(true)
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
                        self.isLoading.accept(false)
                        return [BeachSection(items: beaches)]
                    }
                    .catch { error in
                        self.isLoading.accept(false)
                                            return .just([])
                    }
            }
    }
}
