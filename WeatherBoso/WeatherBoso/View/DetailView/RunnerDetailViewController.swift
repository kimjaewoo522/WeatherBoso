import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RunnerDetailViewController: UIViewController {

    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var isFromSearch: Bool = false
    
    private let weatherInfoView = CustomWeatherInfoView()
    private let viewModel = RunnerViewModel.shared
    private let disposeBag = DisposeBag()
    private let toggleTempButton: UIButton = {
        let button = UIButton()
        button.setTitle("🔄화씨", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    private var isCelsius = true
    
    private let scrollView = UIScrollView()
    private let refreshControl = UIRefreshControl()
    
    private var temperatureUnitLabel: String {
        return isCelsius ? "🔄화씨" : "🔄섭씨"
    }
    
    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
        bindToggleButton()
        bindRefreshControl()
        toggleTempButton.setTitle(temperatureUnitLabel, for: .normal)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(weatherInfoView)
        scrollView.addSubview(toggleTempButton)
        scrollView.alwaysBounceVertical = true
        scrollView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        weatherInfoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
        toggleTempButton.snp.makeConstraints {
            $0.top.equalTo(weatherInfoView.snp.top).offset(160)
            $0.leading.equalToSuperview().inset(35)
        }
    }
    
    // MARK: - 뷰모델 바인딩
    private func bindViewModel() {
        Observable
            .combineLatest(
                viewModel.weatherEntry.compactMap { $0 },
                viewModel.nowWeather.compactMap { $0 },
                viewModel.airPollutionResponse.compactMap { $0 }
            )
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (weatherList, currentWeather, air) in
                guard let owner = self else { return }

                let (imageName, imageTitle) = owner.imageInfo(for: currentWeather.main.temp,
                                                               mainCondition: currentWeather.weather.first?.main)

                owner.weatherInfoView.setImageTC(imageName, .black, title: imageTitle)
                owner.weatherInfoView.makeHeaderStack(
                    title: "뛰어보소",
                    location: owner.locationName ?? "",
                    temperature: owner.formatTemperature(currentWeather.main.temp),
                    status: currentWeather.weather.first?.description ?? "정보 없음"
                )

                let weatherDataList = owner.makeWeatherDataList(weather: currentWeather, air: air)
                owner.weatherInfoView.makeLargeStack(items: weatherDataList)

                let timeInfos: [TimeWeatherInfo] = weatherList.prefix(5).compactMap { entry in
                    let date = Date(timeIntervalSince1970: entry.dt)
                    let timeString = Self.hourFormatter.string(from: date)
                    guard let iconCode = entry.weather.first?.icon else { return nil }
                    let tempValue = owner.formatTemperature(entry.main.temp)
                    return TimeWeatherInfo(time: timeString, imageSource: .url(iconCode: iconCode), value: tempValue)
                }
                owner.weatherInfoView.makeTimeStack(data: timeInfos)
            })
            .disposed(by: disposeBag)
        // Initial fetch
        guard let lat = latitude, let lon = longitude else { return }
        viewModel.fetchWeatherInfo(lat: lat, lon: lon)
        viewModel.fetchAirQuality(lat: lat, lon: lon)
    }
    
    // MARK: - 날씨 정보 리스트 생성
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
    
    // MARK: - 날씨 이미지 및 타이틀 분기 처리
    private func imageInfo(for temp: Double, mainCondition: String?) -> (imageName: String, title: String) {
        guard let condition = mainCondition?.lowercased() else {
            return ("Running", "")
        }

        if condition == "rain" {
            return ("Running4", "하늘에 구멍 뚫렸소")
        } else if temp < 18 {
            return ("Running3", "단디 챙겨 입으소")
        } else if temp < 30 {
            return ("Running", "뛰기 좋소")
        } else {
            return ("Running2", "더워 죽겠소")
        }
    }
    
    private enum DustType {
        case pm10, pm25
    }
    
    // MARK: - 미세먼지 상태 텍스트 변환
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
    
    // MARK: - 온도 단위 토글 버튼 바인딩
    private func bindToggleButton() {
        toggleTempButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.isCelsius.toggle()
                // Trigger fetch to update view reactively
                if let lat = owner.latitude, let lon = owner.longitude {
                    owner.viewModel.fetchWeatherInfo(lat: lat, lon: lon)
                    owner.viewModel.fetchAirQuality(lat: lat, lon: lon)
                }
                owner.toggleTempButton.setTitle(owner.temperatureUnitLabel, for: .normal)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - 당겨서 새로고침 바인딩
    private func bindRefreshControl() {
        refreshControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let lat = owner.latitude, let lon = owner.longitude else { return }
                owner.viewModel.fetchWeatherInfo(lat: lat, lon: lon)
                owner.viewModel.fetchAirQuality(lat: lat, lon: lon)
                owner.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 온도 포맷 변환 (섭씨/화씨)
    private func formatTemperature(_ temp: Double) -> String {
        if isCelsius {
            return "\(Int(temp))℃"
        } else {
            let fahrenheit = temp * 9 / 5 + 32
            return "\(Int(fahrenheit))℉"
        }
    }
}
