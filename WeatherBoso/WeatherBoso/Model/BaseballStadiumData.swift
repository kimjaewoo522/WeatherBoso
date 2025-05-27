//
//  BaseballStadiumData.swift
//  WeatherBoso
//
//  Created by Sophie on 5/26/25.
//

import Foundation

// 카테고리 더미데이터
struct BaseballStadiumData {
    
    static let all: [StadiumModel] = [
        StadiumModel(
            stadiumName: "수원 Kt위즈파크",
            teamLogo: "SuwonKT",
            lat: 37.30,
            lon: 127.01,
            temp: nil, description: nil,
            searchKeywords: ["수원", "경기도", "위즈파크"]
        ),
        StadiumModel(
            stadiumName: "잠실 야구장",
            teamLogo: "Jamsil",
            lat: 37.51,
            lon: 127.07,
            temp: nil, description: nil,
            searchKeywords: ["잠실", "송파", "서울"]
        ),
        StadiumModel(
            stadiumName: "인천 SSG 랜더스 필드",
            teamLogo: "LandersField",
            lat: 37.4367, lon: 126.6908,
            temp: nil, description: nil,
            searchKeywords: ["인천", "랜더스", "ssg"]
        ),
        StadiumModel(
            stadiumName: "사직 야구장",
            teamLogo: "Sajik",
            lat: 35.19, lon: 129.06,
            temp: nil, description: nil,
            searchKeywords: ["사직", "경상도", "부산"]
        ),
        StadiumModel(
            stadiumName: "대구 스타디움",
            teamLogo: "Daegu",
            lat: 35.84, lon: 128.68,
            temp: nil, description: nil,
            searchKeywords: ["대구", "스타디움"]
        ),
        StadiumModel(
            stadiumName: "대전 한화생명 볼파크",
            teamLogo: "DaejeonHanwha",
            lat: 36.32, lon: 127.43,
            temp: nil, description: nil,
            searchKeywords: ["대전", "한화", "불파크"]
        ),
        StadiumModel(
            stadiumName: "광주 기아 챔피언스 필드",
            teamLogo: "GwangjuKia",
            lat: 35.17, lon: 126.89,
            temp: nil, description: nil,
            searchKeywords: ["광주", "기아", "광주시"]
        ),
        StadiumModel(
            stadiumName: "창원 NC파크",
            teamLogo: "ChangwonNC",
            lat: 35.22, lon: 128.58,
            temp: nil, description: nil,
            searchKeywords: ["창원", "nc", "창원nc"]
        ),
        StadiumModel(
            stadiumName: "고척 스카이돔",
            teamLogo: "Gocheok",
            lat: 37.50, lon: 126.87,
            temp: nil, description: nil,
            searchKeywords: ["고척", "서울", "구로"]
        )
    ]
}
