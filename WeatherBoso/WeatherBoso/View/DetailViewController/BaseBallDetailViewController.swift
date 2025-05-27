//
//  BaseBallView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BaseBallDetailViewController: UIViewController {
    
    private let stadium: StadiumModel
    private let weatherInDetails: WeatherResponse
    let detailCustomView = CustomWeatherInfoView()
    let viewModel = BaseBallViewModel()
    let disposeBag = DisposeBag()
    private let dummyWeather = WeatherResponse(
        weather: [Weather(description: "정보 없음", icon: "")],
        main: Main(temp: 0.0, humidity: 0),
        clouds: Clouds(all: 0),
        wind: Wind(speed: 0.0, deg: 0, gust: nil),
        rain: nil,
        dt: 0
    )
    
    init(stadium: StadiumModel, weather: WeatherResponse) {
        self.stadium = stadium
        self.weatherInDetails = weather
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setWeatherStack()
        setUI()
        bind()
        
        viewModel.fetchcurrentWeather(for: stadium)
        viewModel.fetchWeatherPerHour(for: stadium)
    }
    
    private func  setWeatherStack() {
        detailCustomView.makeHeaderStack(
            title: "야구보소",
            location: stadium.stadiumName,
            temperature:String(format: "%.1f℃", weatherInDetails.main.temp),
            status: weatherInDetails.weather.first?.description ?? ""
        )
        
        detailCustomView.makeLargeStack(items: [
            WeatherData(title: "강수량", value: "\(weatherInDetails.rain?.the1H ?? 0.0) mm"),
            WeatherData(title: "풍속", value: "\(weatherInDetails.wind?.speed ?? 0.0) m/s"),
            WeatherData(title: "구름량", value: "\(weatherInDetails.clouds?.all ?? 0)%"),
            WeatherData(title: "습도", value: "\(weatherInDetails.main.humidity)%"),
        ])
        
        detailCustomView.setImageTC("BaseBall", .black)
    }
    
    private func setUI() {
        view.addSubview(detailCustomView)
        detailCustomView.snp.makeConstraints{
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    
    private func bind() {
        
        viewModel.currentWeather
                .compactMap { $0 }
                .asDriver(onErrorJustReturn: dummyWeather)
                .drive(onNext: { [weak self] weather in
                    guard let self = self else { return }

                    self.detailCustomView.makeHeaderStack(
                        title: "야구보소",
                        location: self.stadium.stadiumName,
                        temperature: String(format: "%.1f℃", weather.main.temp),
                        status: weather.weather.first?.description ?? ""
                    )

                    self.detailCustomView.makeLargeStack(items: [
                        WeatherData(title: "강수량", value: "\(weather.rain?.the1H ?? 0.0) mm"),
                        WeatherData(title: "풍속", value: "\(weather.wind?.speed ?? 0.0) m/s"),
                        WeatherData(title: "구름량", value: "\(weather.clouds?.all ?? 0)%"),
                        WeatherData(title: "습도", value: "\(weather.main.humidity)%"),
                    ])
                })
                .disposed(by: disposeBag)
        
        // 하단 시간별 날씨
        viewModel.weatherPerHour
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] timeData in
                print("바인딩 완료: \(timeData.count)")
                self?.detailCustomView.makeTimeStack(data: timeData)
            })
            .disposed(by: disposeBag)
        
        setWeatherStack()
        
        
    }
    
    
}
