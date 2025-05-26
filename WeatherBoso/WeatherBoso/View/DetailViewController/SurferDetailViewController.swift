import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SurferDetailViewController: UIViewController {
    
    private let customWeatherInfo = CustomWeatherInfoView()
    private let disposeBag = DisposeBag()
    
    private var viewModel: SurferDetailViewModel!
    
    // MARK: - Init with Lat/Lon
    init(latitude: Double, longitude: Double) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = SurferDetailViewModel(latitude: latitude, longitude: longitude)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(customWeatherInfo)
        customWeatherInfo.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        let input = SurferDetailViewModel.Input(fetchTrigger: Observable.just(()))
        let output = viewModel.transform(input: input)

        output.weather
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weather in
                self?.updateUI(with: weather)
            })
            .disposed(by: disposeBag)
    }

    private func updateUI(with weather: SurferWeather) {
        customWeatherInfo.updateWeatherHeader(
            title: "파도보소",
            location: "부산",
            temperature: "\(weather.temperature)°C",
            status: weather.weatherCode
        )
        
        customWeatherInfo.setImageTC("Riding2", .blue)
        
        customWeatherInfo.updateWeatherInfo(items: [
            WeatherData(title: "파도", value: "\(weather.waveHeight)m"),
            WeatherData(title: "바람", value: "\(weather.windSpeed)m/s"),
            WeatherData(title: "일출", value: weather.sunrise.first ?? "-"),
            WeatherData(title: "일몰", value: weather.sunset.first ?? "-")
        ])
    }
}
