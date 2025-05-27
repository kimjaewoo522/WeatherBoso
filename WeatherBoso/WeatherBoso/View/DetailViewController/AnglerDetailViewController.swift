import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class AnglerDetailViewController: UIViewController {

    private let viewModel: AnglerDetailViewModel
    private let weatherInfoView = CustomWeatherInfoView()
    private let disposeBag = DisposeBag()

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
        view.addSubview(weatherInfoView)
        weatherInfoView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(20)

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
            let items = [
                WeatherData(title: "만조", value: high.joined(separator: "\n")),
                WeatherData(title: "간조", value: low.joined(separator: "\n")),
                WeatherData(title: "수온", value: temp),
                WeatherData(title: "풍속", value: wind)
            ]
            self?.weatherInfoView.makeLargeStack(items: items)
        })
        .disposed(by: disposeBag)

        viewModel.hourlyForecast
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] forecast in
                self?.weatherInfoView.makeTimeStack(data: forecast)
            })
            .disposed(by: disposeBag)
        
    }
}
