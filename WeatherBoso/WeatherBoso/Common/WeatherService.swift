//
//  WeatherService.swift
//  WeatherBoso
//
//  Created by 김기태 on 5/23/25.
//

import Foundation
import RxSwift

final class WeatherService {
    
    func fetchWeather(latitude: Double, longitude: Double) -> Observable<SurferWeather> {
        let weatherUrlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=sunrise,sunset&models=kma_seamless&current=temperature_2m,weather_code,wind_speed_10m&timezone=Asia%2FTokyo&forecast_days=1&wind_speed_unit=ms&temporal_resolution=hourly_6"
        let marineUrlString = "https://marine-api.open-meteo.com/v1/marine?latitude=\(latitude)&longitude=\(longitude)&hourly=wave_height&current=wave_height&timezone=Asia%2FTokyo&forecast_days=1&wind_speed_unit=ms&temporal_resolution=hourly_6&cell_selection=sea"
        
        guard let weatherUrl = URL(string: weatherUrlString),
              let marineUrl = URL(string: marineUrlString)
        else { return .error(NSError(domain: "Invalid URL", code: -1)) }
        
        let weatherRequest = URLSession.shared.rx.data(request: URLRequest(url: weatherUrl))
            .map{ data -> WeatherForecastResponse in
                try JSONDecoder().decode(WeatherForecastResponse.self, from: data)
            }
        
        let marineRequest = URLSession.shared.rx.data(request: URLRequest(url: marineUrl))
            .map{ data -> MarineForecastResponse in
                try JSONDecoder().decode(MarineForecastResponse.self, from: data)
            }
        return Observable.zip(weatherRequest, marineRequest)
            .map { weather, marine in
                let temperature = "\(weather.current.temperature2m)"
                let weatherCode = WeatherMapper.map(code: weather.current.weatherCode)
                let waveHeight = marine.current.waveHeight
                let hourlyWaveHeight = marine.hourly.waveHeight
                let windSpeed = weather.current.windSpeed10m
                let sunrise = weather.daily.sunrise
                let sunset = weather.daily.sunset
                return SurferWeather(temperature: temperature,
                                     weatherCode: weatherCode,
                                     waveHeight: waveHeight,
                                     hourlyWaveHeight: hourlyWaveHeight,
                                     windSpeed: windSpeed,
                                     sunrise: sunrise,
                                     sunset: sunset)
            }
        
    }
}
