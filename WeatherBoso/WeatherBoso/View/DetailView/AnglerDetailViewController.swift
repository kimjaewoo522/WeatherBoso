import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class AnglerDetailViewController: UIViewController {
    
    private let viewModel: AnglerDetailViewModel
    private let weatherInfoView = CustomWeatherInfoView()
    private let disposeBag = DisposeBag()
    private let toggleTempButton: UIButton = {
        let button = UIButton()
        button.setTitle("🔄화씨", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    private var isCelsius = true
    
    private var originalWaterTemp: String = "-"
    private var originalForecast: [TimeWeatherInfo] = []
    
    init(angler: Angler) {
        self.viewModel = AnglerDetailViewModel(angler: angler)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        
        weatherInfoView.setImageTC("Fishing2", .systemGreen)
        view.backgroundColor = .white
        view.addSubview(toggleTempButton)
        view.addSubview(weatherInfoView)
        view.bringSubviewToFront(toggleTempButton)
        
        weatherInfoView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
            
        }
        toggleTempButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(180)
            make.leading.equalToSuperview().offset(39)
        }
    }
    
    private func bindViewModel() {
        Observable.zip(
            viewModel.locationName,
            viewModel.temperature,
            viewModel.status
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] location, temp, status in
            self?.weatherInfoView.makeHeaderStack(
                title: "낚시보소",
                location: location,
                temperature: temp,
                status: status
            )
        })
        .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.hightide,
            viewModel.lowtide,
            viewModel.waterTemp,
            viewModel.wind
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] high, low, temp, wind in
            guard let self = self else { return }
            
            self.originalWaterTemp = temp
            
            let displayedTemp = self.convertTemperature(tempString: temp)
            
            let items = [
                WeatherData(title: "만조", value: high.joined(separator: "\n")),
                WeatherData(title: "간조", value: low.joined(separator: "\n")),
                WeatherData(title: "수온", value: temp),
                WeatherData(title: "풍속", value: wind)
            ]
            self.weatherInfoView.makeLargeStack(items: items)
            
            let tides = high + low
            let score = self.viewModel.calculateFishingScore(waterTemp: temp, wind: wind, tides: tides)
            
            let imageName = score >= 70 ? "Fishing2" : "Fishing"
            let title = score >= 70 ? "오늘 손 맛 직이네~ 날씨점수:\(score)점" : "잘 안잡히노.. 날씨점수:\(score)점"
            self.weatherInfoView.setImageTC(imageName, .systemGreen, title: title)
        })
        
        
        .disposed(by: disposeBag)
        
        viewModel.hourlyForecast
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] forecast in
                self?.originalForecast = forecast
                self?.weatherInfoView.makeTimeStack(data: forecast)
            })
            .disposed(by: disposeBag)
        
        toggleTempButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.isCelsius.toggle()
                self.updateTemperatureDisplay()
            }
            .disposed(by: disposeBag)
        
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
        // 헤더 온도 변경
        let location = viewModel.locationName.value
        let status = viewModel.status.value
        let rawTemp = Double(viewModel.temperature.value.replacingOccurrences(of: "°C", with: "").replacingOccurrences(of: "°F", with: "")) ?? 0
        let tempText = isCelsius ? "\(Int(rawTemp))°C" : "\(Int(rawTemp * 9 / 5 + 32))°F"
        weatherInfoView.makeHeaderStack(title: "낚시보소", location: location, temperature: tempText, status: status)

        // largeStack 수온만 변환
        let waterTempDouble = Double(originalWaterTemp.replacingOccurrences(of: "°C", with: "").replacingOccurrences(of: "°F", with: "").replacingOccurrences(of: "º", with: "")) ?? 0
        let convertedWaterTemp = isCelsius ? waterTempDouble : waterTempDouble * 9 / 5 + 32
        let waterTempUnit = isCelsius ? "°C" : "°F"
        let displayedWaterTemp = String(format: "%.1f%@", convertedWaterTemp, waterTempUnit)

        let items = [
            WeatherData(title: "만조", value: viewModel.hightide.value.joined(separator: "\n")),
            WeatherData(title: "간조", value: viewModel.lowtide.value.joined(separator: "\n")),
            WeatherData(title: "수온", value: displayedWaterTemp),
            WeatherData(title: "풍속", value: viewModel.wind.value)
        ]
        weatherInfoView.makeLargeStack(items: items)

        // timeStack  변환
        let convertedForecast = originalForecast.map { info in
            let rawValue = info.value
                .replacingOccurrences(of: "º", with: "")
                .replacingOccurrences(of: "°C", with: "")
                .replacingOccurrences(of: "°F", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            let num = Double(rawValue) ?? 0
            let unit = isCelsius ? "°C" : "°F"
            let converted = isCelsius ? num : num * 9 / 5 + 32
            let value = String(format: "%.1f%@", converted, unit)
            
            return TimeWeatherInfo(time: info.time, imageSource: info.imageSource, value: value)
        }
        weatherInfoView.makeTimeStack(data: convertedForecast)
    }


    
    private func convertTemperature(tempString: String) -> String {
        let number = Double(tempString.replacingOccurrences(of: "°C", with: "").replacingOccurrences(of: "º", with: "")) ?? 0.0
        if isCelsius {
            return "\(Int(number))°C"
        } else {
            let f = (number * 9 / 5) + 32
            return "\(Int(f))°F"
        }
    }
    
    private func convertForecast(_ forecast: [TimeWeatherInfo]) -> [TimeWeatherInfo] {
        return forecast.map { info in
            let num = Double(info.value.replacingOccurrences(of: "º", with: "")) ?? 0.0
            let value = isCelsius ? "\(Int(num))º" : "\(Int(num * 9 / 5 + 32))ºF"
            return TimeWeatherInfo(time: info.time, imageSource: info.imageSource, value: value)
        }
    }
}
