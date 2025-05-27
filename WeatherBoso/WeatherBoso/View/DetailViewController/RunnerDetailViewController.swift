import UIKit
import SnapKit
import RxSwift

final class RunnerDetailViewController: UIViewController {
    var latitude: Double?
    var longitude: Double?
    
    private let weatherInfoView = CustomWeatherInfoView()
    private let viewModel = RunnerViewModel.shared
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
        print("위도: \(latitude ?? 0), 경도: \(longitude ?? 0)")
    }

    private func setupConstraints() {
        weatherInfoView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    private func configureWeatherView() {
        guard let lat = latitude, let lon = longitude else { return }
        viewModel.fetchWeatherInfo(lat: lat, lon: lon)
        viewModel.fetchAirQuality(lat: lat, lon: lon)
        //combineLatest: 두 Observable이 emit할 때마다 가장 최신 값들을 함께 묶어 전달, nil을 제거한 유효값만 전달
        Observable
            .combineLatest(viewModel.nowWeather.compactMap { $0 }, viewModel.airPollutionResponse.compactMap { $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (weather: WeatherEntry, air: AirPollutionData) in
                            guard let self = self else { return }
                            let air = air

                let temp = weather.main.temp
                let imageName: String
                if let mainCondition = weather.weather.first?.main {
                    if mainCondition.lowercased() == "Rain" {
                        imageName = "Running4"
                    } else {
                        switch temp {
                        case ..<18:
                            imageName = "Running3"
                        case 18..<30:
                            imageName = "Running"
                        default:
                            imageName = "Running2"
                        }
                    }
                } else {
                    // 날씨 정보가 없을 경우 기본 이미지
                    imageName = "Running"
                }

                self.weatherInfoView.setImageTC(imageName, .black)
                
                self.weatherInfoView.makeHeaderStack(
                    title: "뛰어 보소",
                    location: "서울특별시",
                    temperature: "\(Int(weather.main.temp))℃",
                    status: weather.weather.first?.description ?? "정보 없음"
                )

                let humidity = "\(weather.main.humidity)%"
                let windSpeed = "\(weather.wind.speed)m/s"
                
                let pm10Value = Int(air.components.pm10)
                let pm25Value = Int(air.components.pm25)

                let pm10 = self.airQualityStatus(for: pm10Value, type: .pm10)
                let pm25 = self.airQualityStatus(for: pm25Value, type: .pm25)

                let weatherDataList = [
                    WeatherData(title: "습도", value: humidity),
                    WeatherData(title: "풍속", value: windSpeed),
                    WeatherData(title: "미세먼지", value: pm10),
                    WeatherData(title: "초미세먼지", value: pm25)
                ]

                self.weatherInfoView.makeLargeStack(items: weatherDataList)
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
