import Foundation
import RxRelay
import RxSwift

final class AnglerCategoryViewModel {
    
    let anglerSections = BehaviorRelay<[AnglerSection]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    private let locations: [AnglerLocation] = [
        .init(name: "가덕도", imageName: "Gadeok", obsCode: "DT_0063", lat: 35.024, lon: 128.81),
        .init(name: "거제도", imageName: "Geojae", obsCode: "DT_0029", lat: 34.801, lon: 128.699),
        .init(name: "광양", imageName: "Gwangyang", obsCode: "DT_0049", lat: 34.903, lon: 127.754),
        .init(name: "마산", imageName: "Masan", obsCode: "DT_0062", lat: 35.197, lon: 128.576),
        .init(name: "목포", imageName: "Mokpo", obsCode: "DT_0007", lat: 34.779, lon: 126.375),
        .init(name: "부산", imageName: "Busan", obsCode: "DT_0005", lat: 35.096, lon: 129.035),
        .init(name: "삼천포", imageName: "3000", obsCode: "DT_0061", lat: 34.924, lon: 128.069),
        .init(name: "서귀포", imageName: "Seogui", obsCode: "DT_0010", lat: 33.24, lon: 126.561),
        .init(name: "여수", imageName: "Yeosu", obsCode: "DT_0016", lat: 34.747, lon: 127.765),
        .init(name: "인천", imageName: "Incheon", obsCode: "DT_0001", lat: 37.451, lon: 126.592),
        .init(name: "제주", imageName: "Jeju", obsCode: "DT_0004", lat: 33.527, lon: 126.543),
        .init(name: "포항", imageName: "Pohang", obsCode: "DT_0091", lat: 36.051, lon: 129.376)
    ]
    
    func fetchAnglers() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let todayString = formatter.string(from: Date())

        let observables = locations.map { location -> Observable<Angler> in
            let obsCode = location.obsCode
            let lat = location.lat
            let lon = location.lon

            let tideURL = URL(string: "https://www.khoa.go.kr/api/oceangrid/tideObsPreTab/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(todayString)&ResultType=json")!
            let tempURL = URL(string: "https://www.khoa.go.kr/api/oceangrid/tideObsTemp/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(todayString)&ResultType=json")!
            let windURL = URL(string: "https://www.khoa.go.kr/api/oceangrid/tideObsWind/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(todayString)&ResultType=json")!
            let forecastURL = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=8b75ef2c71a36b9d2f481894ddda0ded&units=metric&lang=kr")!

            let tide: Observable<TideResponse> = NetworkManager.shared.fetch(url: tideURL).asObservable()
            let temp: Observable<WaterTempResponse> = NetworkManager.shared.fetch(url: tempURL).asObservable()
            let wind: Observable<WindResponse> = NetworkManager.shared.fetch(url: windURL).asObservable()
            let forecast: Observable<RiderResponse> = NetworkManager.shared.fetch(url: forecastURL).asObservable()

            return Observable
                .combineLatest(tide, temp, wind, forecast)
                .map { tideRes, tempRes, windRes, forecastRes -> Angler in
                    let now = Date()
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let of = DateFormatter()
                    of.dateFormat = "HH:mm"
                    let tf = DateFormatter()
                    tf.dateFormat = "HH:mm"

                    let closestTemp = tempRes.result.data?
                        .compactMap { (item: WaterTempData) -> (date: Date, temp: String)? in
                            guard let date = df.date(from: item.recordTime) else { return nil }
                            return (date, item.waterTemp)
                        }
                        .min(by: { (a, b) -> Bool in
                            abs(a.date.timeIntervalSince(now)) < abs(b.date.timeIntervalSince(now))
                        })?.temp ?? "-"


                    let closestAir = forecastRes.list
                        .min { abs($0.dt - now.timeIntervalSince1970) < abs($1.dt - now.timeIntervalSince1970) }?
                        .main.temp ?? 0

                    let weatherDesc = forecastRes.list
                        .min { abs($0.dt - now.timeIntervalSince1970) < abs($1.dt - now.timeIntervalSince1970) }?
                        .weather.first?.description ?? "-"

                    let highs = tideRes.result.data
                        .filter { $0.hlCode == "고조" }
                        .compactMap { df.date(from: $0.tphTime).map(of.string) }

                    let lows = tideRes.result.data
                        .filter { $0.hlCode == "저조" }
                        .compactMap { df.date(from: $0.tphTime).map(of.string) }

                    let windSpeed = windRes.result.data
                        .compactMap { (item: WindData) -> (date: Date, speed: String)? in
                            guard let date = df.date(from: item.recordTime) else { return nil }
                            return (date, item.windSpeed)
                        }
                        .min(by: { (a, b) -> Bool in
                            abs(a.date.timeIntervalSince(now)) < abs(b.date.timeIntervalSince(now))
                        })?.speed ?? "-"


                    let hourly = forecastRes.list.prefix(5).map {
                        TimeWeatherInfo(
                            time: tf.string(from: Date(timeIntervalSince1970: $0.dt)),
                            imageSource: .url(iconCode: $0.weather.first?.icon ?? "01d"),
                            value: "\(Int($0.main.temp))°C"
                        )
                    }

                    return Angler(
                        name: location.name,
                        temperature: String(format: "%.1f°C", closestAir),
                        waterTemp: "\(closestTemp)°C",
                        status: weatherDesc,
                        imageName: location.imageName,
                        wind: "\(windSpeed)m/s",
                        highTideList: highs,
                        lowTideList: lows,
                        hourlyForecast: hourly
                    )
                }
                .catch { error in
                    print("\(location.name) 실패:", error)
                    return Observable.empty() // 해당 지역 무시
                }
        }

        Observable.merge(observables)
            .toArray()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] anglers in
                let section = AnglerSection(header: "추천 낚시 지역", items: anglers)
                self?.anglerSections.accept([section])
            }, onError: { error in
                print("일부 지역만 반영되었습니다:", error)
            })
            .disposed(by: disposeBag)
    }

    
}
