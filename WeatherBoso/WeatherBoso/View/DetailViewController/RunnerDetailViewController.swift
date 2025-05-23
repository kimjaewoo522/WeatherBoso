//
//  RunnerView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift

final class RunnerDetailViewController: UIViewController {
    
    private let weatherInfoView = CustomWeatherInfoView()
    private let viewModel = RiderViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureWeatherView()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(weatherInfoView)
    }

    private func setupConstraints() {
        weatherInfoView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    private func configureWeatherView() {
        viewModel.fecthWeatherInfo()
        viewModel.fetchAirQuality()
        //combineLatest: 두 Observable이 emit할 때마다 가장 최신 값들을 함께 묶어 전달, nil을 제거한 유효값만 전달
        Observable
            .combineLatest(viewModel.nowWeather.compactMap { $0 }, viewModel.airPollutionResponse.compactMap { $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weather, air in
                guard let self = self else { return }

                self.weatherInfoView.setImageTC("Running4", .black)
                self.weatherInfoView.updateWeatherHeader(
                    title: "뛰어 보소",
                    location: "서울특별시",
                    temperature: "\(Int(weather.main.temp))℃",
                    status: weather.weather.first?.description ?? "정보 없음"
                )

                let humidity = "\(weather.main.humidity)%"
                let windSpeed = "\(weather.wind.speed)m/s"
                
                let pm10Value = Int(air.components.pm10 ?? 0)
                let pm25Value = Int(air.components.pm25 ?? 0)

                let pm10 = self.airQualityStatus(for: pm10Value, type: .pm10)
                let pm25 = self.airQualityStatus(for: pm25Value, type: .pm25)

                let weatherDataList = [
                    WeatherData(title: "습도", value: humidity),
                    WeatherData(title: "풍속", value: windSpeed),
                    WeatherData(title: "미세먼지", value: pm10),
                    WeatherData(title: "초미세먼지", value: pm25)
                ]

                self.weatherInfoView.updateWeatherInfo(items: weatherDataList)
            })
            .disposed(by: disposeBag)
    }

    private enum DustType {
        case pm10, pm25
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
}
