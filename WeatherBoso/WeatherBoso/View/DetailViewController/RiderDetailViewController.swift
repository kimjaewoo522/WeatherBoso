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
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let refreshControl = UIRefreshControl()
    private var selectedLocationName: String = "부산" // 기본값
    private let toggleTempButton: UIButton = {
        let button = UIButton()
        button.setTitle("🔄화씨", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    private var isCelsius = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bind()
        viewModel.fetchWeatherInfo()
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
                    temperature: self.formattedTemp(weather.main.temp),
                    status: weather.weather.first?.description ?? "이야 맑다"
                )
                
                let pm10Value = Int(air.components.pm10)
                let pm25Value = Int(air.components.pm25)
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
                customWeatherInfo.setImageTC("\(weatherStatus)", .orange)
            }, onError: { error in
                print("에러 발생: \(error)")
            })
            .disposed(by: disposeBag)
        
        //시간별 날씨 데이터
        let forecastStream = viewModel.weatherEntry.compactMap { $0 }
        forecastStream
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] forecastList in
                guard let self = self else { return }
                
                let timeData: [TimeWeatherInfo] = forecastList.prefix(5).map { entry in
                    let date = Date(timeIntervalSince1970: entry.dt)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let timeString = formatter.string(from: date)
                    
                    let iconCode = entry.weather.first?.icon ?? "01d"
                    let tempText = "\(Int(entry.main.temp))°C"
                    
                    return TimeWeatherInfo(time: timeString, imageSource: .url(iconCode: iconCode), value: tempText)
                }
                
                self.customWeatherInfo.makeTimeStack(data: timeData)
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
        }
    }
    
    private func formattedTemp(_ temp: Double) -> String {
        if isCelsius {
            return "\(Int(temp))°C"
        } else {
            let f = (temp * 9/5) + 32
            return "\(Int(f))°F"
        }
    }
    private func updateTemperatureDisplay() {
        guard let weather = nowWeather else { return }
        
        // 온도/상태 업데이트
        customWeatherInfo.makeHeaderStack(
            title: "달려보소",
            location: selectedLocationName,
            temperature: formattedTemp(weather.main.temp),
            status: weather.weather.first?.description ?? "정보 없음"
        )
        
        // 시간별 예보도 다시 변환해서 업데이트
        guard let list = try? viewModel.weatherEntry.value() else { return }
        
        let timeData: [TimeWeatherInfo] = list.prefix(5).map { entry in
            let date = Date(timeIntervalSince1970: entry.dt)
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: date)
            
            let iconCode = entry.weather.first?.icon ?? "01d"
            let tempText = formattedTemp(entry.main.temp)
            
            return TimeWeatherInfo(time: timeString, imageSource: .url(iconCode: iconCode), value: tempText)
        }
        customWeatherInfo.makeTimeStack(data: timeData)
    }
    
    //MARK: - UI구성
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(customWeatherInfo)
        scrollView.addSubview(toggleTempButton)
        //customWeatherInfo에 대한 제약조건 ( 뷰 전체 )
        scrollView.alwaysBounceVertical = true
        scrollView.refreshControl = refreshControl
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        customWeatherInfo.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        toggleTempButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(180)
            make.leading.equalToSuperview().offset(39)
        }
        toggleTempButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.isCelsius.toggle()
                self.updateTemperatureDisplay()
            }
            .disposed(by: disposeBag)
        //refreshControl이 사용자가 당겨서 새로고침을 시작했을 때 실행할 메서드를 지정해주는 부분.
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    
    //MARK: - 위치 관련
    func setLocation(lat: Double, lon: Double, locationName: String) {
        selectedLocationName = locationName
        viewModel.updateLocation(lat: lat, lon: lon)
    }
    //실제 새로고침할 때 실행되는 함수 정의.
    @objc private func refreshData() {
        viewModel.fetchWeatherInfo()
        viewModel.fetchAirQuality()
        
        // 새로고침 끝내기
        // 새로고침 UI를 1초 뒤에 종료하는 코드
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
}
