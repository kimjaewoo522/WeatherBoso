# WeatherBoso

> “야외에서 하는 취미 활동 맞춤형 날씨앱을 개발하자” 라는 목표를 가지고 만든 application 입니다.

## 프로젝트 개요

WeatherBoso는 야외 활동(런닝, 서핑, 야구, 낚시, 라이딩 등)을 즐기는 사람들을 위한 맞춤형 날씨 정보 앱입니다.
기존의 일반적인 날씨 앱과는 다르게, 사용자 개개인의 취미 활동에 초점을 맞춰 관련 정보를 제공함으로써 더 실용적이고 직관적인 사용자 경험을 제공합니다.

예를 들어,
낚시를 좋아하는 사용자는 간조/만조 시간, 
서핑을 즐기는 사용자는 해양 날씨 정보와 파도 높이를,
러닝을 즐기는 사용자는 온도, 습도, 풍속, 미세먼지 정보를,
그리고 라이딩 사용자에게는 공기 질과 날씨 변화를 손쉽게 제공받을 수 있습니다.

또한 검색 기능을 통해 원하는 장소의 날씨를 즉시 확인할 수 있고, 실시간으로 섭씨/화씨 전환, 데이터 새로고침 기능까지 갖춘 스마트한 야외 취미 파트너 앱입니다.

## 팀 구성
| 이름      |       GitHub                        |
| -------- | ---------------------------------- |
| 김재우  |  https://github.com/kimjaewoo522 |
| 김기태   |  https://github.com/kkt6394 |
| 강성훈   |  https://github.com/tututu08 |
| 최영락   | https://github.com/yeungrak|
| 한여정   | https://github.com/Sophie4han |



## 프로젝트 일정

- **시작일**: 2025/05/20  
- **종료일**: 2025/05/28

## 기술 스택

### 아키텍처
- MVVM

### 비동기 처리
- RxSwift
- RxDataSources
- RxGesture
- RxCocoa
- RxRelay

### API 통신
- URLSession

### 활용 API
- Geocoding
- OpenWeather(Current, air pollution)
- 국가해양정보 활용 센터
- Open-meteo

### UI Frameworks
- UIKit
- Snapkit

##  주요 기능

1. **서핑**
- 지역 및 해변을 검색하여 등록된 해변을 볼 수 있습니다. 해변 선택 시 날씨 정보(파도, 일출, 일몰, 풍속, 기온)를 확인할 수 있습니다.
      
2. **야구**  
- 야구팬들을 위해 해당 일자의 강수 정보, 습도 등을 제공해서 야구 관람에 있어 편의를 제공하고자 하였습니다

3. **낚시**
- 

4. **런닝**  
- 등록된 장소의 날씨정보(온도, 습도, 풍속)와 미세먼지 상태를 확인 할 수 있습니다. 그리고 해당주소 검색시 그 장소의 날씨 정보가 나옵니다.

5. **라이딩**
- 등록된 라이딩 코스에 대한 날씨, 온도, 미세먼지 , 초미세먼지, 풍속, 시간 별 날씨 정보를 확인 할 수 있습니다.
날씨 정보를 확인하고 싶은 주소를 입력하여 그 지역에 대한 날씨 정보를 확인 할 수 있습니다.

## 📁 WeatherBoso 프로젝트 디렉토리 구조

```
📁 WeatherBoso
├── App
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Common
│   ├── GeocodingNetworkManager.swift
│   ├── NetworkManager.swift
│   └── WeatherService.swift
│
├── Model
│   ├── AnglerModel/
│   ├── BaseBallModel.swift
│   ├── BaseballStadiumData.swift
│   ├── RiderModel.swift
│   ├── RunnerModel.swift
│   └── SurferModel.swift
│
├── Resources
│   ├── Fonts/
│   ├── Assets.xcassets
│   └── Info.plist
│
├── Secret
│   └── Secret.swift
│
├── View
│   ├── CategoryViewController
│   │   ├── CategoryViewCollectionCell
│   │   │   ├── AnglerCell.swift
│   │   │   ├── BaseballCell.swift
│   │   │   ├── RiderCell.swift
│   │   │   ├── RunnerCell.swift
│   │   │   └── SurferCell.swift
│   │   ├── CategoryViewModel
│   │   │   ├── AnglerCategoryViewModel.swift
│   │   │   ├── RunnerCategoryViewModel.swift
│   │   │   └── SurferCategoryViewModel.swift
│   │   ├── CellModel
│   │   │   ├── Angler.swift
│   │   │   ├── Beach.swift
│   │   │   └── RunningSpot.swift
│   │   └── SectionModel
│   │       ├── AnglerSection.swift
│   │       ├── BeachSection.swift
│   │       └── RunningSpotSection.swift
│   ├── AnglerCategoryViewController.swift
│   ├── BaseBallCategoryViewController.swift
│   ├── RiderCategoryViewController.swift
│   ├── RunnerCategoryViewController.swift
│   └── SurferCategoryViewController.swift
│
├── DetailViewController
│   ├── AnglerDetailViewController.swift
│   ├── BaseBallDetailViewController.swift
│   ├── CustomWeatherInfo.swift
│   ├── RiderDetailViewController.swift
│   ├── RunnerDetailViewController.swift
│   └── SurferDetailViewController.swift
│
├── UIBar
│   └── SearchBar.swift
│
├── LaunchScreen
│   ├── MainViewController.swift
│   └── SplashViewController.swift
│
└── ViewModel
    ├── AnglerViewModel.swift
    ├── BaseBallViewModel.swift
    ├── RiderViewModel.swift
    ├── RunnerViewModel.swift
    └── SurferViewModel.swift
```
