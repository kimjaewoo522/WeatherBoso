import Foundation
import RxRelay

final class AnglerDetailViewModel {
    
    let locationName = BehaviorRelay<String>(value: "-")
    let temperature = BehaviorRelay<String>(value: "-")
    let status = BehaviorRelay<String>(value: "-") 
    let hightide = BehaviorRelay<[String]>(value: [])
    let lowtide = BehaviorRelay<[String]>(value: [])
    let wind = BehaviorRelay<String>(value: "-")
    let hourlyForecast = BehaviorRelay<[TimeWeatherInfo]>(value: [])
    let waterTemp = BehaviorRelay<String>(value: "-")
    
    init(angler: Angler) {
        bind(angler: angler)
    }

    private func bind(angler: Angler) {
        locationName.accept(angler.name)
        temperature.accept(angler.temperature)
        waterTemp.accept(angler.waterTemp)
        status.accept(angler.status)
        hightide.accept(angler.highTideList)
        lowtide.accept(angler.lowTideList)
        wind.accept(angler.wind)
        hourlyForecast.accept(angler.hourlyForecast)
        
    }
    func calculateFishingScore(waterTemp: String, wind: String, tides: [String]) -> Int {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)

        // 수온 점수 (최대 10)
        let tempValue = Double(waterTemp.replacingOccurrences(of: "°C", with: "")) ?? 0
        var score = 0
        if (12...22).contains(tempValue) {
            score += 10
        } else if (10...24).contains(tempValue) {
            score += 6
        } else {
            score += 2
        }

        // 풍속 점수 (최대 30)
        let windValue = Double(wind.replacingOccurrences(of: "m/s", with: "")) ?? 0
        if windValue < 4 {
            score += 30
        } else if windValue < 6 {
            score += 20
        } else if windValue < 8 {
            score += 10
        }

        // 조석 점수 (고조/저조 ±2시간이면 각각 30점, 최대 60점)
        let tideScore = tides
            .compactMap { timeStr -> Int? in
                let comps = timeStr.split(separator: ":")
                guard comps.count == 2,
                      let hour = Int(comps[0]),
                      let minute = Int(comps[1]) else { return nil }
                let tideHourDecimal = Double(hour) + Double(minute) / 60
                let diff = abs(tideHourDecimal - Double(currentHour))
                return diff <= 2 ? 30 : 0
            }
            .reduce(0, +)

        score += min(tideScore, 60)

        return min(score, 100)
    }
}
