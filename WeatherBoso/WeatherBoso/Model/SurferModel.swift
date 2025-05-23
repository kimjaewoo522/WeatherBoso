//
//  SurferModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation

struct WeatherForecastResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let current: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather

    struct CurrentWeather: Decodable {
        let temperature2m: Double
        let windSpeed10m: Double
        let time: String

        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case windSpeed10m = "wind_speed_10m"
            case time
        }
    }

    struct HourlyWeather: Decodable {
        let time: [String]
        let temperature2m: [Double]
        let weatherCode: [Int]

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
        }
    }

    struct DailyWeather: Decodable {
        let time: [String]
        let sunrise: [String]
        let sunset: [String]
        let weatherCode: [Int]
        let temperature2mMax: [Double]

        enum CodingKeys: String, CodingKey {
            case time, sunrise, sunset
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
        }
    }
}

struct MarineForecastResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let current: CurrentMarine
    let hourly: HourlyMarine

    struct CurrentMarine: Decodable {
        let waveHeight: Double
        let time: String

        enum CodingKeys: String, CodingKey {
            case waveHeight = "wave_height"
            case time
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



