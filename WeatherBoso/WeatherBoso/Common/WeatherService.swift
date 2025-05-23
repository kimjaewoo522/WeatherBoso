//
//  WeatherService.swift
//  WeatherBoso
//
//  Created by 김기태 on 5/23/25.
//

import Foundation
import RxSwift

final class WeatherService {
    
    func fetchWeather(latitude: Double, longitude: Double) -> Observable<(temperature: String, weather: String)> {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&models=kma_seamless&current=temperature_2m,weather_code&timezone=Asia%2FTokyo&wind_speed_unit=ms&temporal_resolution=hourly_6"
        
        guard let url = URL(string: urlString) else { return .error(NSError(domain: "Invalid URL", code: -1)) }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data in
                let decoder = JSONDecoder()
                let result = try decoder.decode(OpenMeteoResponse.self, from: data)
                let temp = result.current.temperature2m
                let weatherCode = result.current.code
                let weatherText = WeatherMapper.map(code: weatherCode)
                
                return ("\(temp)°C", weatherText)
            }
    }
}
