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
    private let disposeBag = DisposeBag()
    private var airPolluiton: AirPollutionData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bind()
        viewModel.fecthWeatherInfo()
        viewModel.fetchAirQuality()
        //        setupContent()
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
                self.customWeatherInfo.updateWeatherHeader(
                    title: "달려보소",
                    location: "부산",
                    temperature: "\(Int(weather.main.temp))°",
                    status: weather.weather.first?.description ?? "이야 맑다"
                )
                
                let pm10Value = Int(air.components.pm10)
                let pm25Value = Int(air.components.pm25)
                let pm10 = self.airQualityStatus(for: pm10Value, type: .pm10)
                let pm25 = self.airQualityStatus(for: pm25Value, type: .pm25)
                
                print("대기질 components 확인: \(air.components)")
                self.customWeatherInfo.updateWeatherInfo(items: [
                    WeatherData(title: "가시거리", value: "\((weather.visibility) / 1000 )km"),
                    WeatherData(title: "풍속", value: "\(weather.wind.speed) m/s"),
                    WeatherData(title: "미세먼지", value: "\(pm10)"),
                    WeatherData(title: "초미세먼지", value: "\(pm25)")
                ])
            }, onError: { error in
                print("에러 발생: \(error)")
            })
            .disposed(by: disposeBag)
        
        customWeatherInfo.setImageTC("Riding2", .blue)
    }
    
    private enum DustType {
        case pm10, pm25
    }
    private enum WeatherType {
        case sunny
        case rainy
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
    
    
    //MARK: - UI구성
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(customWeatherInfo)
        //customWeatherInfo에 대한 제약조건 ( 뷰 전체 )
        customWeatherInfo.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}
