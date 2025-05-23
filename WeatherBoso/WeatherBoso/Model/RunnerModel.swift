//
//  RunnerModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation

struct GeocodeResponse: Codable {
    let addresses: [GeocodeAddress]
}

struct GeocodeAddress: Codable {
    let x: String  // 경도 (longitude)
    let y: String  // 위도 (latitude)
}
