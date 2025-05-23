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
        // 현재 날씨
        viewModel.nowWeather
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weather in
                guard let self = self else { return }
                self.nowWeather = weather
                self.customWeatherInfo.updateWeatherHeader(
                    title: "달려보소",
                    location: "부산",
                    temperature: "\(Int(weather?.main.temp ?? -999))°",
                    status: weather?.weather.first?.description ?? "이야 맑다"
                )
                self.customWeatherInfo.updateWeatherInfo(items: [
                    WeatherData(title: "가시거리", value: "\(weather?.visibility ?? 0)m"),
                    WeatherData(title: "풍속", value: "\(weather?.wind.speed ?? 0) m/s"),
                    WeatherData(title: "미세먼지", value: "\(self.airPolluiton?.components.pm10 ?? 0)"),
                    WeatherData(title: "초미세먼지", value: "\(self.airPolluiton?.components.pm25 ?? 0)")
                ])
            }, onError: { error in
                print("에러 발생: \(error)")
            })
            .disposed(by: disposeBag)
        
        customWeatherInfo.setImageTC("Riding2", .blue)
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
