//
//  BaseBallViewModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation
import RxSwift
import RxCocoa

class BaseBallViewModel {
    
      /// binding을 위해 꼭 필요
//    let stadiums = BehaviorSubject<[StadiumModel]>(value: [])
    init() {}
    /// 밖에서 읽을 수는 있으나 수정 불가
    private(set) var stadiumInfo: [StadiumModel] = [
        StadiumModel(stadiumName: "수원 Kt위즈파크", teamLogo: "SuwonKT", lat: "37.30", lon: "127.01", temp: nil, description: nil),
        StadiumModel(stadiumName: "잠실 야구장", teamLogo: "Jamsil", lat: "37.51", lon: "127.07", temp: nil, description: nil),
        StadiumModel(stadiumName: "인천 SSG 랜더스 필드", teamLogo: "LandersField", lat: "37.4367", lon: "126.6908", temp: nil, description: nil),
        StadiumModel(stadiumName: "사직 야구장", teamLogo: "Sajik", lat: "129.06", lon: "35.19", temp: nil, description: nil),
        StadiumModel(stadiumName: "대구 스타디움", teamLogo: "Daegu", lat: "128.68", lon: "35.84", temp: nil, description: nil),
        StadiumModel(stadiumName: "대전 한화생명 볼파크", teamLogo: "DaejeonHanwha", lat: "127.43", lon: "36.32", temp: nil, description: nil),
        StadiumModel(stadiumName: "광주 기아 챔피언스 월드", teamLogo: "GwangjuKia", lat: "126.89", lon: "35.17", temp: nil, description: nil),
        StadiumModel(stadiumName: "창원 NC파크", teamLogo: "ChangwonNC", lat: "128.58", lon: "35.22", temp: nil, description: nil),
        StadiumModel(stadiumName: "고척 스카이돔", teamLogo: "Gocheok", lat: "126.87", lon: "37.50", temp: nil, description: nil)
    ]
    
//    func stadium() {
//        
//        let stadiumInfo: [StadiumModel] = [
//            StadiumModel(stadiumName: "수원 Kt위즈파크", teamLogo: "SuwonKT"),
//            StadiumModel(stadiumName: "잠실 야구장", teamLogo: "Jamsil"),
//            StadiumModel(stadiumName: "인천 SSG 랜더스 필드", teamLogo: "LandersField"),
//            StadiumModel(stadiumName: "사직 야구장", teamLogo: "Sajik"),
//            StadiumModel(stadiumName: "대구 스타디움", teamLogo: "Daegu"),
//            StadiumModel(stadiumName: "대전 한화생명 볼파크", teamLogo: "DaejeonHanwha"),
//            StadiumModel(stadiumName: "광주 기아 챔피언스 월드", teamLogo: "GwangjuKia"),
//            StadiumModel(stadiumName: "창원 NC파크", teamLogo: "ChangwonNC"),
//            StadiumModel(stadiumName: "고척 스카이돔", teamLogo: "Gocheok")
//        ]
//        
//        stadiums.onNext(stadiumInfo)
//    }
    
}
