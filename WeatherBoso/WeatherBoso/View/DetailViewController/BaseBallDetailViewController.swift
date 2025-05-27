//
//  BaseBallView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BaseBallDetailViewController: UIViewController {
    
    private let stadium: StadiumModel
    private let weatherInDetails: WeatherResponse
    let detailCustomView = CustomWeatherInfoView()
    
    init(stadium: StadiumModel, weather: WeatherResponse) {
        self.stadium = stadium
        self.weatherInDetails = weather
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailCustomView.backgroundColor = .white
        view = detailCustomView
        
        detailCustomView.updateWeatherHeader(
            title: "야구보소",
            location: stadium.stadiumName,
            temperature:String(format: "%.1f℃", weatherInDetails.main.temp),
            status: weatherInDetails.weather.first?.description ?? ""
        )
        
        detailCustomView.updateWeatherInfo(items: [
            WeatherData(title: "강수량", value: "\(weatherInDetails.rain?.the1H ?? 0.0) mm"),
            WeatherData(title: "풍속", value: "\(weatherInDetails.wind?.speed ?? 0.0) m/s"),
            WeatherData(title: "구름량", value: "\(weatherInDetails.clouds?.all ?? 0)%"),
            WeatherData(title: "습도", value: "\(weatherInDetails.main.humidity)%"),
        ])
        
        //        detailCustomView.setImageTC(<#T##imageName: String##String#>, <#T##color: UIColor##UIColor#>)
        
    }
    
    private func setConst() {
        detailCustomView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    

}
