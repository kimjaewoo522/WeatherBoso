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
    
}
