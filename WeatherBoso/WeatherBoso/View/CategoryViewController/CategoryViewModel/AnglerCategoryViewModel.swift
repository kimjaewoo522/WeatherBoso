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
        
        let observables: [Observable<Angler>] = locations.map { location in
            let obsCode = location.obsCode
            let lat = location.lat
            let lon = location.lon
            
            let tideURL = URL(string: "https://www.khoa.go.kr/api/oceangrid/tideObsPreTab/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(todayString)&ResultType=json")!
            let tempURL = URL(string: "https://www.khoa.go.kr/api/oceangrid/tideObsTemp/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(todayString)&ResultType=json")!
            let windURL = URL(string: "https://www.khoa.go.kr/api/oceangrid/tideObsWind/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(todayString)&ResultType=json")!
            let forecastURL = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=8b75ef2c71a36b9d2f481894ddda0ded&units=metric&lang=kr")!
            
            let tideObservable: Single<TideResponse> = NetworkManager.shared.fetch(url: tideURL)
            let tempObservable: Single<WaterTempResponse> = NetworkManager.shared.fetch(url: tempURL)
            let windObservable: Single<WindResponse> = NetworkManager.shared.fetch(url: windURL)
            let forecastObservable: Single<RiderResponse> = NetworkManager.shared.fetch(url: forecastURL)
            
            return Observable.zip(
                tideObservable.asObservable(),
                tempObservable.asObservable(),
                windObservable.asObservable(),
                forecastObservable.asObservable()
            )
            .map { (tide, temp, wind, forecast) -> Angler in
                let now = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "HH:mm"
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                
                let closestWaterTemp = temp.result.data?
                    .compactMap { item -> (date: Date, temp: String)? in
                        guard let date = dateFormatter.date(from: item.recordTime) else { return nil }
                        return (date, item.waterTemp)
                    }
                    .min(by: { abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now)) })?.temp ?? "-"
                
                let closestAirTemp = forecast.list
                    .min(by: { abs($0.dt - now.timeIntervalSince1970) < abs($1.dt - now.timeIntervalSince1970) })?
                    .main.temp ?? 0
                let formattedAirTemp = String(format: "%.1f°C", closestAirTemp)

                
                
                let weatherDesc = forecast.list
                    .min(by: { abs($0.dt - now.timeIntervalSince1970) < abs($1.dt - now.timeIntervalSince1970) })?
                    .weather.first?.description ?? "-"
                
                let highs = tide.result.data.compactMap { item -> String? in
                    guard item.hlCode == "고조",
                          let date = dateFormatter.date(from: item.tphTime)
                    else { return nil }
                    return outputFormatter.string(from: date)
                }
                
                let lows = tide.result.data.compactMap { item -> String? in
                    guard item.hlCode == "저조",
                          let date = dateFormatter.date(from: item.tphTime)
                    else { return nil }
                    return outputFormatter.string(from: date)
                }
                
                let latestWindSpeed = wind.result.data
                    .compactMap { item -> (date: Date, speed: String)? in
                        guard let date = dateFormatter.date(from: item.recordTime) else { return nil }
                        return (date, item.windSpeed)
                    }
                    .min(by: { abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now)) })?.speed ?? "-"
                
                
                let hourlyList: [TimeWeatherInfo] = forecast.list.prefix(5).map { entry in
                    let time = timeFormatter.string(from: Date(timeIntervalSince1970: entry.dt))
                    let iconCode = entry.weather.first?.icon ?? "01d"
                    let temp = "\(Int(entry.main.temp))°C"
                    
                    
                    return TimeWeatherInfo(
                        time: time,
                        imageSource: .url(iconCode: iconCode),
                        value: temp
                    )
                }
                
                return Angler(
                    name: location.name,
                    temperature: "\(formattedAirTemp)",
                    waterTemp: "\(closestWaterTemp)°C",
                    status: weatherDesc,
                    imageName: location.imageName,
                    wind: "\(latestWindSpeed)m/s",
                    highTideList: highs,
                    lowTideList: lows,
                    hourlyForecast: hourlyList
                )
            }
        }
        
        Observable.zip(observables)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] anglers in
                let section = AnglerSection(header: "추천 낚시 지역", items: anglers)
                self?.anglerSections.accept([section])
            }, onError: { error in
                print("전체 지역 데이터 fetch 실패:", error)
            })
            .disposed(by: disposeBag)
    }
    
}
