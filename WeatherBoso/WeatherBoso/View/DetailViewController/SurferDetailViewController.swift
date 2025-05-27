import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

final class SurferDetailViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let refreshControl = UIRefreshControl()
    
    private let customWeatherInfo = CustomWeatherInfoView()
    private let disposeBag = DisposeBag()
    private let beachName: String
    private var viewModel: SurferDetailViewModel!
    
    init(name: String, latitude: Double, longitude: Double) {
        self.beachName = name
        self.viewModel = SurferDetailViewModel(latitude: latitude, longitude: longitude)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        bindRefreshControl()
        setupSwipeGesture()
    }
    
    private func setupSwipeGesture() {
        self.view.rx.swipeGesture(.right)
            .when(.recognized)
            .bind { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(customWeatherInfo)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        customWeatherInfo.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        customWeatherInfo.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        scrollView.refreshControl = refreshControl
    }
    
    private func bindRefreshControl() {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.reloadWeather()
                
            })
            .disposed(by: disposeBag)
    }
    
    private func reloadWeather() {
        let input = SurferDetailViewModel.Input(fetchTrigger: Observable.just(()))
        let output = viewModel.transform(input: input)
        
        output.weather
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weather in
                self?.updateUI(with: weather)
                self?.refreshControl.endRefreshing()
                
            }, onError: { [weak self] error in
                print("Error")
                self?.refreshControl.endRefreshing()
                
            })
            .disposed(by: disposeBag)
    }
    
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
        customWeatherInfo.makeHeaderStack(
            title: "파도보소",
            location: beachName,
            temperature: "\(weather.temperature)°C",
            status: weather.weatherCode
        )
        
        let waveHeight = weather.waveHeight
        let imageName: String
        switch waveHeight {
        case ..<0.5:
            imageName = "Surfing3"
        case 0.5..<1.2:
            imageName = "Surfing"
        case 1.2...:
            imageName = "Surfing2"
        default:
            imageName = "Surfing"
        }
        
        customWeatherInfo.setImageTC(imageName, UIColor(red: 0.247, green: 0.518, blue: 0.576, alpha: 1))
        
        customWeatherInfo.makeLargeStack(items: [
            WeatherData(title: "파도", value: "\(weather.waveHeight)m"),
            WeatherData(title: "바람", value: "\(weather.windSpeed)m/s"),
            WeatherData(title: "일출", value: weather.sunrise.first?.split(separator: "T").last.map(String.init) ?? "-"),
            WeatherData(title: "일몰", value: weather.sunset.first?.split(separator: "T").last.map(String.init) ?? "-")
        ])
        
        let hourlyWaveHeight = Array(weather.hourlyWaveHeight.prefix(4))
        let startHour = 0
        let waveTimeData: [TimeWeatherInfo] = hourlyWaveHeight.enumerated().map { index, height in
            let hour = startHour + index * 6
            let timeString = String(format: "%02d:00", hour)
            
            let waveImage: String
            switch height {
            case ..<0.5:
                waveImage = "Surfing3"
            case 0.5..<1.2:
                waveImage = "Surfing"
            case 1.2...:
                waveImage = "Surfing2"
            default:
                waveImage = "Surfing"
            }
            
            return TimeWeatherInfo(time: timeString, imageSource: WeatherImageSource.local(named: waveImage), value: "\(height)m")

        }
       
        customWeatherInfo.makeTimeStack(data: waveTimeData)
    }
}

