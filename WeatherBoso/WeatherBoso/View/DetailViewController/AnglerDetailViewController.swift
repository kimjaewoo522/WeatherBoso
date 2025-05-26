import UIKit
import RxSwift
import RxCocoa

final class AnglerDetailViewController: UIViewController {

    private let viewModel = AnglerDetailViewModel()
    private let disposeBag = DisposeBag()

    private let weatherInfoView = CustomWeatherInfoView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let todayString = formatter.string(from: Date())
        //군산 기준으로 fetch
        viewModel.fetch(for: "DT_0018", date: todayString)
    }

    private func setupUI() {
        weatherInfoView.setImageTC("Fishing2", .orange)
        view.backgroundColor = .white
        view.addSubview(weatherInfoView)
        weatherInfoView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    private func bindViewModel() {
        Observable.zip(
            viewModel.locationName,
            viewModel.waterTemp,
            viewModel.windSpeed
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] location, temp, wind in
            self?.weatherInfoView.makeHeaderStack(
                title: "낚시보소🎣",
                location: location,
                temperature: temp,
                status: "풍속 \(wind)"
            )
        })
        .disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.highTide,
            viewModel.lowTide,
            viewModel.waterTemp,
            viewModel.windSpeed
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

        // 하단 시간별 날씨 정보는 더미 데이터 사용
        let dummyTimeInfo: [TimeWeatherInfo] = [
            .init(time: "06:00", image: "SunImage", value: "23º"),
            .init(time: "09:00", image: "SunImage2", value: "25º"),
            .init(time: "12:00", image: "CloudImage", value: "26º"),
            .init(time: "15:00", image: "RainImage", value: "24º"),
            .init(time: "18:00", image: "RainImage", value: "22º")
        ]
        weatherInfoView.makeTimeStack(data: dummyTimeInfo)
    }
}
