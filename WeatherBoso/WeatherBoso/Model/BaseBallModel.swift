//
//  BaseBallModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation

struct StadiumModel {
    let stadiumName: String
    let teamLogo: String
    let lat: String
    let lon: String
    let temp: String?
    let description: String?
}

struct WeatherResponse: Decodable {
    let dt: Int
    let list: [List]
//    let city: City
}

struct List: Decodable {
    
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let rain: Rain
    
    enum CodingKeys: String, CodingKey {
        case dt
        case main
        case weather
        case clouds
        case wind
        case rain
    }
}

struct Weather: Codable {
    let description, icon: String
}

struct Main: Decodable {
    let temp: Double
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case humidity
    }
    
}

struct Rain: Codable {
    let the3H: Double
    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double
}

struct Clouds: Codable {
    let all: Int
}
