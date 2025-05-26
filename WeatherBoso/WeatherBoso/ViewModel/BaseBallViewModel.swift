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
    
    let disposedBag = DisposeBag()
    let weatherPerDay = BehaviorRelay<[StadiumModel]>(value: [])
    
    init() {}
    
    /// 밖에서 읽을 수는 있으나 수정 불가
    var stadiumInfo: [StadiumModel] = [
        StadiumModel(stadiumName: "수원 Kt위즈파크", teamLogo: "SuwonKT", lat: 37.30, lon: 127.01, temp: nil, description: nil),
        StadiumModel(stadiumName: "잠실 야구장", teamLogo: "Jamsil", lat: 37.51, lon: 127.07, temp: nil, description: nil),
        StadiumModel(stadiumName: "인천 SSG 랜더스 필드", teamLogo: "LandersField", lat: 37.4367, lon: 126.6908, temp: nil, description: nil),
        StadiumModel(stadiumName: "사직 야구장", teamLogo: "Sajik", lat: 35.19, lon: 129.06, temp: nil, description: nil),
        StadiumModel(stadiumName: "대구 스타디움", teamLogo: "Daegu", lat: 35.84, lon: 128.68, temp: nil, description: nil),
        StadiumModel(stadiumName: "대전 한화생명 볼파크", teamLogo: "DaejeonHanwha", lat: 36.32, lon: 127.43, temp: nil, description: nil),
        StadiumModel(stadiumName: "광주 기아 챔피언스 필드", teamLogo: "GwangjuKia", lat: 35.17, lon: 126.89, temp: nil, description: nil),
        StadiumModel(stadiumName: "창원 NC파크", teamLogo: "ChangwonNC", lat: 35.22, lon: 128.58, temp: nil, description: nil),
        StadiumModel(stadiumName: "고척 스카이돔", teamLogo: "Gocheok", lat: 37.50, lon: 126.87, temp: nil, description: nil)
    ]
    
    //    func fetchDetail(for id: Int) {
    //            guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)/") else { return }
    //
    //            NetworkManager.shared.fetch(url: url)
    //                .subscribe(onSuccess: { [weak self] (detail: PokemonDetail) in
    //                    self?.pokemonDetail.accept(detail)
    //                }, onFailure: { error in
    //                    print("상세 조회 실패: \(error)")
    //                })
    //                .disposed(by: disposeBag)
    //        }
    //
    func fetchAllStadiumWeather() {
        var updatedStadiums = Array(repeating: StadiumModel.empty, count: stadiumInfo.count)
        let group = DispatchGroup()

        for (index, stadium) in stadiumInfo.enumerated() {
            group.enter()

            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(stadium.lat)&lon=\(stadium.lon)&appid=82fa9d3fa33aaa4358ca085201f3a956&units=metric&lang=kr") else {
                group.leave()
                continue
            }

            NetworkManager.shared.fetch(url: url/*, lat: stadium.lat, lon: stadium.lon*/)
                .subscribe(onSuccess: { [weak self] (response: WeatherResponse) in
                    var updated = stadium
                    updated.temp = String(format: "%.1f℃", response.main.temp)
                    updated.description = response.weather.first?.description
                    updatedStadiums[index] = updated
                    group.leave()
                }, onFailure: { error in
                    print("에러1: \(error.localizedDescription)")

                        if let urlError = error as? URLError {
                            print("URLError2: \(urlError)")
                        }

                        if let afError = error as? DecodingError {
                            print("DecodingError3: \(afError)")
                        }
                    group.leave()
                })
                .disposed(by: disposedBag)
        }

        group.notify(queue: .main) {
            print("모두 로딩 완료: \(updatedStadiums.count)개")
            self.weatherPerDay.accept(updatedStadiums)
        }
    }

    
    
    
    //    func fiveDaysWeatherURL(for index: Int) {
    //
    //        let myAPI = "82fa9d3fa33aaa4358ca085201f3a956"
    //
    //        let stadiumLoca = stadiumInfo[index]
    //        guard let URL = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}") else {
    //            return
    //        }
    //
    //        NetworkManager.shared.fetch(url: URL, lat: stadiumLoca.lat, lon: stadiumLoca.lon)
    //            .subscribe(onSuccess: { [weak self] (response: WeatherResponse) in
    //                let temperature = "\(Int(response.list.first?.main.temp ?? 0))°C"
    //                let desc = response.list.first?.weather.first?.description ?? ""
    //
    //                self?.stadiumInfo[index].temp = temperature
    //                self?.stadiumInfo[index].description = desc
    //            }, onFailure: { [weak self] error in
    //                print("")
    //            })
    //            .disposed(by: disposedBag)
    //    }
    
    
}
