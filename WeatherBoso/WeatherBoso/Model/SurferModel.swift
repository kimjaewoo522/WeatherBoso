//
//  SurferModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation

struct WeatherForecastResponse: Decodable {
    let current: CurrentWeather
    let daily: DailyWeather
    
    struct CurrentWeather: Decodable {
        let temperature2m: Double
        let windSpeed10m: Double
        let weatherCode: Int
        
        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case windSpeed10m = "wind_speed_10m"
            case weatherCode = "weather_code"
        }
    }
    
    struct DailyWeather: Decodable {
        let sunrise: [String]
        let sunset: [String]
        
    }
}

struct MarineForecastResponse: Decodable {
    let current: CurrentMarine
    let hourly: HourlyMarine
    
    struct CurrentMarine: Decodable {
        let waveHeight: Double
        
        enum CodingKeys: String, CodingKey {
            case waveHeight = "wave_height"
        }
    }
    
    struct HourlyMarine: Decodable {
        let time: [String]
        let waveHeight: [Double]
        
        enum CodingKeys: String, CodingKey {
            case time
            case waveHeight = "wave_height"
        }
    }
}


enum WeatherMapper {
    static func map(code: Int) -> String {
        switch code {
        case 0: return "맑음"
        case 1, 2, 3: return "부분 흐림"
        case 45, 48: return "안개"
        case 51, 53, 55, 56, 57: return "이슬비"
        case 61, 63, 65, 66, 67: return "비"
        case 71, 73, 75, 77: return "눈"
        case 80, 81, 82: return "소나기"
        case 95, 96, 99: return "천둥번개"
        default: return "알 수 없음"
        }
    }
}

struct SurferWeather {
    let temperature: String
    let weatherCode: String
    let waveHeight: Double
    let hourlyWaveHeight: [Double]
    let windSpeed: Double
    let sunrise: [String]
    let sunset: [String]
}
