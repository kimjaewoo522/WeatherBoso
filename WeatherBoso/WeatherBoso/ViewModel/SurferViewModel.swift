import Foundation
import RxSwift
import RxCocoa

final class SurferDetailViewModel {
    
    // Input
    struct Input {
        let fetchTrigger: Observable<Void>
    }

    // Output
    struct Output {
        let weather: Observable<SurferWeather>
    }
    
    private let weatherService: WeatherService
    private let latitude: Double
    private let longitude: Double

    init(latitude: Double, longitude: Double, weatherService: WeatherService = WeatherService()) {
        self.latitude = latitude
        self.longitude = longitude
        self.weatherService = weatherService
    }
    
    func transform(input: Input) -> Output {
        let weather = input.fetchTrigger
            .flatMapLatest { [unowned self] _ in
                self.weatherService.fetchWeather(latitude: self.latitude, longitude: self.longitude)
            }
        
        return Output(weather: weather)
    }
}
