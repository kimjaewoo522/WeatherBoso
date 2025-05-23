import Foundation

struct WaterTempResponse: Decodable {
    let result: WaterTempResult
}

struct WaterTempResult: Decodable {
    let data: [WaterTempData]
}

struct WaterTempData: Decodable {
    let recordTime: String
    let waterTemp: String
    
    enum CodingKeys: String, CodingKey {
        case recordTime = "record_time"
        case waterTemp = "water_temp"
    }
}
