//
//  RiderView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import RxSwift
import UIKit
import Foundation
import SnapKit

class RiderDetailViewController: UIViewController {
    // CustomWeatherInfoView 인스턴스 생성
    private let customWeatherInfo = CustomWeatherInfoView()
    private let viewModel = RiderViewModel()
    private var nowWeather: WeatherEntry?
    private var weatherInfo: WeatherInfo?
    private let disposeBag = DisposeBag()
    private var airPolluiton: AirPollutionData?
    private var selectedLocationName: String = "부산" // 기본값
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bind()
        viewModel.fecthWeatherInfo()
        viewModel.fetchAirQuality()
    }
    
    private func bind() {
        // 옵셔널 값을 걸러주고 스트림으로 바꿔줌
        let weatherStream = viewModel.nowWeather.compactMap { $0 }
        let airStream = viewModel.airPollutionResponse.compactMap { $0 }
        // 합성된 Observable을 둘다 방출 뒤 하나라도 방출하면 다른 Observable의 최신값을 같이 방출 (튜플)
        Observable.combineLatest(weatherStream, airStream)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weather, air in
                guard let self = self else { return }
                self.nowWeather = weather
                self.customWeatherInfo.makeHeaderStack(
                    title: "달려보소",
                    location: self.selectedLocationName,
                    temperature: "\(Int(weather.main.temp))°",
                    status: weather.weather.first?.description ?? "이야 맑다"
                )
                
                let pm10Value = Int(air.components.pm10 ?? 0)
                let pm25Value = Int(air.components.pm25 ?? 0)
                let pm10 = self.airQualityStatus(for: pm10Value, type: .pm10)
                let pm25 = self.airQualityStatus(for: pm25Value, type: .pm25)
                let weatherStatusValue = String(weatherInfo?.main ?? "")
                let weatherStatus = self.WeatherStatus(for: weatherStatusValue, type: .main)
                
                print("대기질 components 확인: \(air.components)")
                self.customWeatherInfo.makeLargeStack(items: [
                    WeatherData(title: "가시거리", value: "\((weather.visibility) / 1000 )km"),
                    WeatherData(title: "풍속", value: String(format: "%.1f m/s", weather.wind.speed)),
                    WeatherData(title: "미세먼지", value: "\(pm10)"),
                    WeatherData(title: "초미세먼지", value: "\(pm25)")
                ])
                customWeatherInfo.setImageTC("\(weatherStatus)", .blue)
            }, onError: { error in
                print("에러 발생: \(error)")
            })
            .disposed(by: disposeBag)
        
       
    }
    
    private enum DustType {
        case pm10, pm25
    }
    private enum WeatherType {
        case main
    }
    
    private func airQualityStatus(for value: Int, type: DustType) -> String {
        switch type {
        case .pm10:
            switch value {
            case 0...30: return "좋음"
            case 31...80: return "보통"
            case 81...150: return "나쁨"
            default: return "매우 나쁨"
            }
        case .pm25:
            switch value {
            case 0...15: return "좋음"
            case 16...35: return "보통"
            case 36...75: return "나쁨"
            default: return "매우 나쁨"
            }
        }
    }
    
    private func WeatherStatus(for value: String, type: WeatherType) -> String {
            switch type {
            case .main:
                switch value {
                case "Thunderstorm": return "Riding2"
                case "Drizzle": return "Riding2"
                case "Rain": return "Riding2"
                case "Snow": return "Riding3"
                case "Atmosphere": return "Riding2"
                default: return "Bike"
                }
//                •    “맑음”
//                •    “구름 조금”
//                •    “흐림”
//                •    “약한 비”
//                •    “비”
//                •    “강한 비”
//                •    “눈”
//                •    “소나기”
//                •    “안개”
//                •    “황사”
//                •    “연무”
//                •    “박무”
//                •    “천둥번개”
                //Bike 기본
                //Riding2 비
                //Riding3 눈
            }
        }
    
    
    //MARK: - UI구성
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(customWeatherInfo)
        //customWeatherInfo에 대한 제약조건 ( 뷰 전체 )
        customWeatherInfo.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    //MARK: - 위치 관련
    func setLocation(lat: Double, lon: Double, locationName: String) {
        selectedLocationName = locationName
        viewModel.updateLocation(lat: lat, lon: lon)
    }
}
