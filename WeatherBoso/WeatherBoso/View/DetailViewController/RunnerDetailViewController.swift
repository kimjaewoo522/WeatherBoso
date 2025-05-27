import UIKit
import SnapKit
import RxSwift

final class RunnerDetailViewController: UIViewController {
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var isFromSearch: Bool = false
    
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

        Observable
            .combineLatest(
                viewModel.weatherEntry.compactMap { $0 },
                viewModel.nowWeather.compactMap { $0 },
                viewModel.airPollutionResponse.compactMap { $0 }
            )
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (weatherList, currentWeather, air) in
                guard let self = self else { return }

                let imageName = self.imageName(for: currentWeather.main.temp,
                                               mainCondition: currentWeather.weather.first?.main)

                self.weatherInfoView.setImageTC(imageName, .black)
                self.weatherInfoView.makeHeaderStack(
                    title: "뛰어보소",
                    location: self.locationName ?? "",
                    temperature: "\(Int(currentWeather.main.temp))℃",
                    status: currentWeather.weather.first?.description ?? "정보 없음"
                )

                let weatherDataList = self.makeWeatherDataList(weather: currentWeather, air: air)
                self.weatherInfoView.makeLargeStack(items: weatherDataList)

                let timeInfos: [TimeWeatherInfo] = weatherList.prefix(5).compactMap { entry in
                    let date = Date(timeIntervalSince1970: entry.dt)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let timeString = formatter.string(from: date)
                    guard let iconCode = entry.weather.first?.icon else { return nil }
                    let tempValue = "\(Int(entry.main.temp))°C"
                    return TimeWeatherInfo(time: timeString, imageSource: .url(iconCode: iconCode), value: tempValue)
                }
                self.weatherInfoView.makeTimeStack(data: timeInfos)
            })
            .disposed(by: disposeBag)
    }
    
    private func imageName(for temp: Double, mainCondition: String?) -> String {
        guard let condition = mainCondition?.lowercased() else {
            return "Running"
        }

        if condition == "rain" {
            return "Running4"
        } else {
            switch temp {
            case ..<18: return "Running3"
            case 18..<30: return "Running"
            default: return "Running2"
            }
        }
    }
    
    private func makeWeatherDataList(weather: WeatherEntry, air: AirPollutionData) -> [WeatherData] {
        let humidity = "\(weather.main.humidity)%"
        let windSpeed = "\(weather.wind.speed)m/s"
        let pm10Value = Int(air.components.pm10)
        let pm25Value = Int(air.components.pm25)
        let pm10 = airQualityStatus(for: pm10Value, type: .pm10)
        let pm25 = airQualityStatus(for: pm25Value, type: .pm25)

        return [
            WeatherData(title: "습도", value: humidity),
            WeatherData(title: "풍속", value: windSpeed),
            WeatherData(title: "미세먼지", value: pm10),
            WeatherData(title: "초미세먼지", value: pm25)
        ]
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
