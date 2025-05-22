//
//  SurferViewModel.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class SurferViewModel {
    
    private let disposeBag = DisposeBag()
    
    let weatherRelay = PublishRelay<WeatherForecastResponse>()
    let marineRelay = PublishRelay<MarineForecastResponse>()
    
    func fetchWeatherData() {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=37.37009&longitude=128.31866&daily=sunrise,sunset,weather_code,temperature_2m_max&hourly=temperature_2m,weather_code&models=kma_seamless&current=temperature_2m,wind_speed_10m&timezone=Asia%2FTokyo&wind_speed_unit=ms&temporal_resolution=hourly_6") else { return }
        
        NetworkManager.shared.fetch(url: url)
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] (response: WeatherForecastResponse) in
                self?.weatherRelay.accept(response)
            }.disposed(by: disposeBag)
    }
    
    func fetchMarineData() {
        guard let url = URL(string: "https://marine-api.open-meteo.com/v1/marine?latitude=38&longitude=128.7&hourly=wave_height&current=wave_height&timezone=Asia%2FTokyo&wind_speed_unit=ms&temporal_resolution=hourly_6&cell_selection=sea") else { return }
        
        NetworkManager.shared.fetch(url: url)
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] (response: MarineForecastResponse) in
                self?.marineRelay.accept(response)
            }.disposed(by: disposeBag)

    }
}
