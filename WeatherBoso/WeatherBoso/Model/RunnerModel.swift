//
//  RunnerModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation

struct GeocodeResponse: Decodable {
    let addresses: [GeocodeAddress]
}

struct GeocodeAddress: Decodable {
    let roadAddress: String // 도로명주소
    let x: String  // 경도 (longitude)
    let y: String  // 위도 (latitude)
}
