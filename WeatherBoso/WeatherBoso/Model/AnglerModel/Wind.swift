//
//  Wind.swift
//  WeatherBoso
//
//  Created by 강성훈 on 5/22/25.
//
import Foundation

struct WindResponse: Decodable {
    let result: WindResult
}

struct WindResult: Decodable {
    let data: [WindData]
}

struct WindData: Decodable {
    let recordTime: String
    let windSpeed: String
    
    enum CodingKeys: String, CodingKey {
        case recordTime = "record_time"
        case windSpeed = "wind_speed"
    }
}

