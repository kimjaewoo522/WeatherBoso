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
    private let toggleTempButton: UIButton = {
        let button = UIButton()
        button.setTitle("🔄화씨", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    var isCelsius = true
    
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
        setWeatherStack(with: weatherInDetails)
        bind()
        setUI()
        //        bind()
        
        viewModel.fetchcurrentWeather(for: stadium)
        viewModel.fetchWeatherPerHour(for: stadium)
    }
    
    private func  setWeatherStack(with rain: WeatherResponse) {
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
        
        let rainfall = rain.rain?.the1H ?? 0.0
        //        let imageName = rainfall < 0.1 ? "Baseball" : "Baseball2"
        let imageName: String
        switch rainfall {
        case ..<0.1:
            imageName = "Baseball2"
        default:
            imageName = "Baseball"
        }
        
    }
    
    private func setUI() {
        view.addSubview(detailCustomView)
        view.addSubview(toggleTempButton)
        detailCustomView.snp.makeConstraints{
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        toggleTempButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(180)
            make.leading.equalToSuperview().offset(39)
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
        
        toggleTempButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.isCelsius.toggle()
                self.updateTemperatureDisplay()
                updateTemperatureDisplay()
            }
            .disposed(by: disposeBag)
        
        setWeatherStack(with: weatherInDetails)
        
        
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
        guard let weather = viewModel.currentWeather.value else { return }
        
        // 헤더 영역 업데이트
        detailCustomView.makeHeaderStack(
            title: "야구보소",
            location: stadium.stadiumName,
            temperature: formattedTemp(weather.main.temp),
            status: weather.weather.first?.description ?? "정보 없음"
        )
        
        // 시간별 예보 영역 업데이트
        let hourlyList = viewModel.weatherRawList.value
        
        let timeData: [TimeWeatherInfo] = hourlyList.prefix(5).map { entry in
            let date = Date(timeIntervalSince1970: TimeInterval(entry.dt))
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let time = formatter.string(from: date)
            
            let iconCode = entry.weather.first?.icon ?? "01d"
            let temp = formattedTemp(entry.main.temp)
            
            return TimeWeatherInfo(time: time, imageSource: .url(iconCode: iconCode), value: temp)
        }
        
        detailCustomView.makeTimeStack(data: timeData)
    }
    
}


