// AnglerDetailViewModel.swift
import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class AnglerDetailViewModel {
    private let disposeBag = DisposeBag()
    //Relay 생성 및 기본값 설정
    let highTide = BehaviorRelay<[String]>(value: [])
    let lowTide = BehaviorRelay<[String]>(value: [])
    let waterTemp = BehaviorRelay<String>(value: "-")
    let windSpeed = BehaviorRelay<String>(value: "-")
    let locationName = BehaviorRelay<String>(value: "-")
    let hourlyForecast = PublishRelay<[TimeWeatherInfo]>()
    
    func fetch(obsCode: String, date: String) {
        fetchTide(obsCode: obsCode, date: date)
        fetchTemp(obsCode: obsCode, date: date)
        fetchWind(obsCode: obsCode, date: date)
    }

    private func fetchTide(obsCode: String, date: String) {
            guard let url = URL(string:
                "https://www.khoa.go.kr/api/oceangrid/tideObsPreTab/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(date)&ResultType=json"
            ) else { return }
            NetworkManager.shared.fetch(url: url)
                .subscribe(onSuccess: { (response: TideResponse) in
                    response.result.data.forEach {
                        print("시간: \($0.tphTime), hlCode: \($0.hlCode)")
                    }

                    let data = response.result.data
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "HH:mm"

                    let highs = data.filter { $0.hlCode == "고조" }
                        .compactMap { item -> String? in
                            guard let date = dateFormatter.date(from: item.tphTime) else { return nil }
                            return outputFormatter.string(from: date)
                        }

                    let lows = data.filter { $0.hlCode == "저조" }
                        .compactMap { item -> String? in
                            guard let date = dateFormatter.date(from: item.tphTime) else { return nil }
                            return outputFormatter.string(from: date)
                        }

                    self.highTide.accept(Array(highs))
                    self.lowTide.accept(Array(lows))
                    self.locationName.accept(response.result.meta.obsPostName)

                }, onFailure: { print("조석 fetch 오류 발생", $0) })
                .disposed(by: disposeBag)
        }

    private func fetchTemp(obsCode: String, date: String) {
        guard let url = URL(string:
            "https://www.khoa.go.kr/api/oceangrid/tideObsTemp/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(date)&ResultType=json"
        ) else { return }
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { (response: WaterTempResponse) in
                print("수온 응답 개수:", response.result.data.count)
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let closest = response.result.data
                    .compactMap { item -> (date: Date, temp: String)? in
                        guard let date = formatter.date(from: item.recordTime) else { return nil }
                        return (date, item.waterTemp)
                    }
                    .min(by: { abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now)) })

                let latestTemp = closest?.temp ?? "-"
                self.waterTemp.accept(latestTemp + "°C")

            }, onFailure: { error in
                print("수온 fetch 오류발생", error)
                        URLSession.shared.dataTask(with: url) { data, _, _ in
                            if data != nil { return }
                        }.resume()
                    })
            .disposed(by: disposeBag)
    }
    
    private func fetchWind(obsCode: String, date: String) {
        guard let url = URL(string:
            "https://www.khoa.go.kr/api/oceangrid/tideObsWind/search.do?ServiceKey=O6PVDU7e1ymtJJAgEAZtlQ==&ObsCode=\(obsCode)&Date=\(date)&ResultType=json"
        ) else { return }

        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { (response: WindResponse) in
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let closest = response.result.data
                    .compactMap { item -> (date: Date, windSpeed: String)? in
                        guard let date = formatter.date(from: item.recordTime) else { return nil }
                        return (date, item.windSpeed)
                    }
                    .min(by: { abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now)) })
                let latestSpeed = closest?.windSpeed ?? "-"
                self.windSpeed.accept(latestSpeed + "m/s")
            }, onFailure: { error in
                print("풍량 fetch 오류 발생", error)
                self.windSpeed.accept("-")
            })
            .disposed(by: disposeBag)
    }
    func fetchForecast(lat: Double, lon: Double) {
            let apiKey = "8b75ef2c71a36b9d2f481894ddda0ded"
            let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=kr"
            guard let url = URL(string: urlString) else { return }
            
            NetworkManager.shared.fetch(url: url)
                .subscribe(onSuccess: { (response: RiderResponse) in
                    // API 기준으로 최근 5개의 정보 가져옴
                    let list = response.list.prefix(5)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    
                    let infos = list.map { entry in
                        let time = formatter.string(from: Date(timeIntervalSince1970: entry.dt))
                        let iconCode = entry.weather.first?.icon ?? "01d"
                        let temp = "\(Int(entry.main.temp))º"
                        
                        return TimeWeatherInfo(
                            time: time,
                            imageSource: .url(iconCode: iconCode),
                            value: temp
                        )
                    }
                    self.hourlyForecast.accept(infos)
                }, onFailure: {
                    print("예보 fetch 오류:", $0)
                })
                .disposed(by: disposeBag)
        }
}
