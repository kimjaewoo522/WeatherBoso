//
//  RiderViewModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//


import Foundation
import RxSwift

class RiderViewModel {
    //api 키
    private let apiKey = "8b75ef2c71a36b9d2f481894ddda0ded"
    //메모리 정리용 disposeBag
    private let disposeBag = DisposeBag()
    //latitude 위도
    private var lat = 37.5665
    //longitude 경도
    private var lon = 126.9780
    
    //날씨 예보를 담는 Rx subject
    let weatherEntry = BehaviorSubject<[WeatherEntry]?>(value: nil)
    //대기질 정보를 담는 Rx Subject
    let airPollutionResponse = BehaviorSubject<AirPollutionData?>(value: nil)
    // 현재 날씨의 정보를 담는 Rx Subject
    let nowWeather = BehaviorSubject<WeatherEntry?>(value: nil)
    
    
    func fecthWeatherInfo () {
        let urlStirng = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=kr"
        guard let url = URL(string: urlStirng) else {
            weatherEntry.onError(NetworkError.invalidUrl)
            return
        }
        NetworkManager.shared.fetch(url: url)
        // API 호출이 성공해서 JSON이 RiderResponse로 파싱된 순간 실행되는 블록이다.
        // RiderResponse를 구독하고 있는 것이다.
            .subscribe(onSuccess: { (response: RiderResponse) in
                //응답으로 받은 RiderRespnse.weatherInfo = [WeatherEntry] 리스트 중에서
                // 오늘 날짜에만 해당하는것들만 필터링 하는 것 ( 3시간 간격 )
                self.weatherEntry.onNext(response.list)
                
                let now = self.nowWeather(from: response.list)
                
                self.nowWeather.onNext(now)
                
            }, onFailure: { error in
                self.weatherEntry.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchAirQuality() {
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            airPollutionResponse.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { (response: AirPollutionResponse) in
                //블로그에 정리해놓음 .first를 쓰는 이유
                self.airPollutionResponse.onNext(response.list.first)
            }, onFailure: { error in
                self.airPollutionResponse.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    //현재 시각과 가장 가까운 예보 하나를 리턴 하는 것임.
    func nowWeather (from list: [WeatherEntry]) -> WeatherEntry? {
        //Date()는 현재 시간임. timeIntervalSince1970은 1970년 1월 1일 기준으로 몇 초가 지난지 Double 타입으로 반환해줌
        //신기한 기능이지만 swift자체 기능임
        let now = Date().timeIntervalSince1970
        // list는 3시간 간격의 예보인데. 그 중에서도 {}안에있는 조건들을 부합하는 하나의 요소를 반환하는 메소드 => min(by:)
        // swift자체에 abs 함수가 있다. 비교 조건 함수인데 $0.dt는 첫 번째 예보의 timestamp $1.dt는 두 번째 예보의 timestamp
        // now: 현재 시각의 timestamp
        // 둘 중 누가 지금 시간에 가까운지 비교하는 함수임.
        // 그래서 비교 했을때 지금 시점과 가장 가까운 예보 1개를 리턴함.
        return list.min(by: {abs($0.dt - now) < abs($1.dt - now)})
    }
}
