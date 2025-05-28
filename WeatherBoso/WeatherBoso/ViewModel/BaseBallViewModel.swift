//
//  BaseBallViewModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation
import RxSwift
import RxCocoa

class BaseBallViewModel {
    
    let disposedBag = DisposeBag()
    let weatherPerDay = BehaviorRelay<[StadiumModel]>(value: [])
    let categoryHomeScreen = BehaviorRelay<[StadiumModel]>(value: [])
    var weatherDict: [String: WeatherResponse] = [:]
    let weatherPerHour = BehaviorRelay<[TimeWeatherInfo]>(value: [])
    let currentWeather = BehaviorRelay<WeatherResponse?>(value: nil)
    let weatherRawList = BehaviorRelay<[ForecastItem]>(value: [])

    
    let dummyWeather = WeatherResponse(
        weather: [Weather(description: "정보 없음", icon: "")],
        main: Main(temp: 0.0, humidity: 0),
        clouds: Clouds(all: 0),
        wind: Wind(speed: 0.0, deg: 0, gust: nil),
        rain: nil,
        dt: 0
    )
    
    // 구장 정보로 초기에 로드되는 고정데이터
    var stadiumInfo: [StadiumModel] = BaseballStadiumData.all
    
    // 디스패치그룹 for 카테고리뷰
    func fetchAllStadiumWeather() {
        var updatedStadiums = Array(repeating: StadiumModel.empty, count: stadiumInfo.count)
        var weatherResponses: [WeatherResponse] = Array(
            repeating: dummyWeather, // 또는 첫 번째 stadium 날씨 구조체
            count: stadiumInfo.count
        )
        
        let group = DispatchGroup()
        
        for (index, stadium) in stadiumInfo.enumerated() {
            group.enter()
            
            
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(stadium.lat)&lon=\(stadium.lon)&appid=82fa9d3fa33aaa4358ca085201f3a956&units=metric&lang=kr") else {
                group.leave()
                continue
            }
            
            NetworkManager.shared.fetch(url: url/*, lat: stadium.lat, lon: stadium.lon*/)
                .subscribe(onSuccess: { [weak self] (response: WeatherResponse) in
                    var updated = stadium
                    updated.temp = String(format: "%.1f℃", response.main.temp)
                    updated.description = response.weather.first?.description
                    updatedStadiums[index] = updated
                    group.leave()
                }, onFailure: { error in
                    
                    group.leave()
                })
                .disposed(by: disposedBag)
        }
        
        group.notify(queue: .main) {
           
            self.weatherPerDay.accept(updatedStadiums)
            self.categoryHomeScreen.accept(updatedStadiums) // 여기서 초기화 해줘야 초기 화면에 뜸
            
            for (index, stadium) in self.stadiumInfo.enumerated() {
                self.weatherDict[stadium.stadiumName] = weatherResponses[index]
            }
        }
    }
    
    func searchStadiums(for keyword: String) {
        if keyword.isEmpty { // 검색어 없을때 weatherPerDay의 더미데이터 기본으로 보여주기
            categoryHomeScreen.accept(weatherPerDay.value)
        } else {
            
            let filtered = weatherPerDay.value.filter { stadium in
                stadium.stadiumName.localizedCaseInsensitiveContains(keyword) ||
                stadium.searchKeywords.contains { $0.localizedCaseInsensitiveContains(keyword) }
            }
            categoryHomeScreen.accept(filtered)
        }
        
    }
    
    // 디테일뷰
    func fetchcurrentWeather(for stadium: StadiumModel) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(stadium.lat)&lon=\(stadium.lon)&appid=82fa9d3fa33aaa4358ca085201f3a956&units=metric&lang=kr") else {
            return
        }
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { (response: WeatherResponse) in
                self.currentWeather.accept(response)
            }, onFailure: { error in
            })
            .disposed(by: disposedBag)

    }
    
    func fetchWeatherPerHour(for stadium: StadiumModel) {
        print("함수 작동 성공")
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(stadium.lat)&lon=\(stadium.lon)&appid=82fa9d3fa33aaa4358ca085201f3a956&units=metric&lang=kr") else {
            
            return
        }
        print("url 생성 성공")
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { (response: ForecastResponse) in
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                
                let hourlyWeather = response.list.prefix(5).map { item in
                    let time = formatter.string(
                        from: Date(
                            timeIntervalSince1970: TimeInterval(item.dt)))
                    let temp = "\(Int(item.main.temp))°"
                    let icon = item.weather.first?.icon ?? ""
                    let iconCode = item.weather.first?.icon ?? "01d"
                    let imageName: String
                    if icon.contains("01") { imageName = "sunny" }
                    else if icon.contains("n") { imageName = "night" }
                    else if icon.contains("09") || icon.contains("10") { imageName = "rain" }
                    else if icon.contains("13") { imageName = "snow" }
                    else { imageName = "cloud" }
                    
                    return TimeWeatherInfo(
                        time: time,
                        imageSource: .url(iconCode: iconCode),
                        value: temp)
                }
                
                self.weatherPerHour.accept(hourlyWeather)
            }, onFailure: { error in
                self.weatherPerHour.accept([])
            })
            .disposed(by: disposedBag)
    }
}
