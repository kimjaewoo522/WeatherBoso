//
//  RiderModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation

struct RiderResponse: Decodable {
    let list: [WeatherEntry]
}

struct WeatherEntry: Decodable {
    let dt: TimeInterval         // 예보 시간 (Unix Timestamp)
    let main: MainInfo
    let weather: [WeatherInfo]
    let wind: WindInfo
    let visibility: Int          // 가시거리 (m)
}

struct MainInfo: Decodable {
    let temp: Double             // 온도 (섭씨, units=metric 설정 시)
    let humidity: Int            // 습도
}

struct WeatherInfo: Decodable {
    let id: Int                  // 날씨 아이콘 ID
    let description: String      // 날씨 상태 (예: 맑음, 흐림)
    let icon: String             // 날씨 ICON
}

struct WindInfo: Decodable {
    let speed: Double            // 풍속 (m/s)
}
//MARK: - 공기질 Model
struct AirPollutionResponse: Decodable {
    let list: [AirPollutionData]
}

struct AirPollutionData: Decodable {
    let main: AQI
    let components: AirComponents
}

struct AQI: Decodable {
    let aqi: Int // 1~5 (1: 좋음, 5: 매우 나쁨)
}

struct AirComponents: Decodable {
    let pm25: Double // 초-미세먼지
    let pm10: Double // 미세먼지
    
    enum CodingKeys: String, CodingKey {
        case pm25 = "pm2_5"
        case pm10
    }
}
