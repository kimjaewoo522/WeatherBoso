//
//  Tide.swift
//  WeatherBoso
//
//  Created by 강성훈 on 5/22/25.
//

struct TideResponse: Decodable {
    let result: TideResult
}

struct TideResult: Decodable {
    let data: [TideData]
    let meta: TideMeta
    
    struct TideData: Decodable {
        let tphTime: String
        let hlCode: String
        
        enum CodingKeys: String, CodingKey {
            case tphTime = "tph_time"
            case hlCode = "hl_code"
        }
    }
    
    struct TideMeta: Decodable {
        let obsPostName: String
        
        enum CodingKeys: String, CodingKey {
            case obsPostName = "obs_post_name"
        }
    }
}
