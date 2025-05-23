//
//  SurferView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import Foundation
import UIKit
import SnapKit


final class SurferDetailViewController: UIViewController {
    private let customWeatherInfo = CustomWeatherInfoView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()

    }
    private func setupUI() {
      view.backgroundColor = .white
      view.addSubview(customWeatherInfo)
      //customWeatherInfo에 대한 제약조건 ( 뷰 전체 )
      customWeatherInfo.snp.makeConstraints { make in
        make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
      }
    }
    func setupContent() {
        //헤더스택뷰에 들어갈 정보
        customWeatherInfo.updateWeatherHeader(
            title: "파도보소",
            location: "부산",
            temperature: "36도",
            status: "맑음")
        //이미지랑, 타이틀 색상 정보
        customWeatherInfo.setImageTC("Riding2", .blue)
        // 하단 스택뷰 정보
        customWeatherInfo.updateWeatherInfo(items: [
            WeatherData(title: "파도", value: "30km"),
            WeatherData(title: "바람", value: "30km"),
            WeatherData(title: "일출", value: "30km"),
            WeatherData(title: "일몰", value: "30km")
        ])
    }
}

