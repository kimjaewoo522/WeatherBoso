//
//  RiderCategoryView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation

// 날씨 데이터 모델 (온도와 설명은 API 요청 후 채워짐)
struct LocationWeatherModel {
    let name: String
    let lat: Double
    let lon: Double
    let temp: Double?
    let description: String?
    let imageName: String
}

final class RiderCategoryViewController: UIViewController {
    
    private let searchBar = SearchBar()
    private let weatherService = WeatherService()
    private let disposeBag = DisposeBag()
    private let geocoder = CLGeocoder()
    
    lazy var collection = UICollectionView(
        frame: .zero, collectionViewLayout: collectionSet()
    )
    
    private var locations: [LocationWeatherModel] = [
            LocationWeatherModel(
                name: "경기도 남양주 화음길",
                lat: 37.6519,
                lon: 127.2165,
                temp: nil,
                description: "날씨 불러오는 중",
                imageName: "hwaEumgil"
            ),
            LocationWeatherModel(
                name: "경상남도 남해 19번 국도",
                lat: 34.8374,
                lon: 127.8635,
                temp: nil,
                description: "날씨 불러오는 중",
                imageName: "namHae"
            ),
            LocationWeatherModel(
                name: "제주도 신창 풍차 해안도로",
                lat: 33.3004,
                lon: 126.1743,
                temp: nil,
                description: "날씨 불러오는 중",
                imageName: "sinChang"
            ),
            LocationWeatherModel(
                name: "강원도 새천년 해안도로",
                lat: 37.6024,
                lon: 129.1175,
                temp: nil,
                description: "날씨 불러오는 중",
                imageName: "saecheonnyeon"
            )
    ]

    
    private let customNavBar: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.circle",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.setTitle("  달려보소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GmarketSansTTFMedium", size: 29)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
        setupCollectionView()
        fetchAllLocationWeathersUsingViewModel()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        [customNavBar, searchBar, collection].forEach { view.addSubview($0) }
        customNavBar.addSubview(backButton)
    }
    
    private func setupConstraints() {
        customNavBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(customNavBar.snp.bottom).offset(23)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(56)
        }
        
        collection.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(27)
            $0.leading.trailing.bottom.equalToSuperview().inset(23)
        }
    }
    
    private func setupBindings() {
        backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchBar.searchTextField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] query in
                self?.geocodeAndFetchWeather(for: query)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        collection.register(RiderCell.self, forCellWithReuseIdentifier: RiderCell.id)
        collection.dataSource = self
        collection.delegate = self
    }
    
    private func collectionSet() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(
            top: 0, leading: 0,
            bottom: 23, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(110)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    //모든 위치의 날씨 정보를 가져오는 함수
    private func fetchAllLocationWeathersUsingViewModel() {
        for (index, location) in locations.enumerated() {
            let viewModel = RiderViewModel()
            
            // viewModel의 nowWeather Subject에서 한 번만 값을 받아옴
            viewModel.nowWeather
                .compactMap { $0 }
                .take(1) // 첫 번째 값만 받도록 제한
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] weather in
                    guard let self = self else { return }
                    
                    let updated = LocationWeatherModel(
                        name: location.name,
                        lat: location.lat,
                        lon: location.lon,
                        temp: weather.main.temp,
                        description: weather.weather.first?.description,
                        imageName: location.imageName
                    )
                    
                    self.locations[index] = updated
                    self.collection.reloadItems(at: [IndexPath(item: index, section: 0)])
                })
                .disposed(by: disposeBag)
            
            // 위치 설정 + 날씨 데이터 fetch 시작
            viewModel.updateLocation(lat: location.lat, lon: location.lon)
        }
    }
    
    //주소를 위경도 바꿔서 날씨를 가져오는 함수
    private func geocodeAndFetchWeather(for address: String) {
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if error != nil {
                return
            }
            
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                return
            }
            
            // 좌표로 날씨 가져오기
            let viewModel = RiderViewModel()
            viewModel.nowWeather
                .compactMap { $0 }
                .take(1)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { weather in
                    let newLocation = LocationWeatherModel(
                        name: address,
                        lat: coordinate.latitude,
                        lon: coordinate.longitude,
                        temp: weather.main.temp,
                        description: weather.weather.first?.description ?? "알 수 없음",
                        imageName: "defaultRoad" // 기본 이미지 이름
                    )
                    self.locations.insert(newLocation, at: 0)
                    self.collection.reloadData()
                })
                .disposed(by: self.disposeBag)

            viewModel.updateLocation(lat: coordinate.latitude, lon: coordinate.longitude)
        }
    }
}

extension RiderCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RiderCell.id, for: indexPath) as? RiderCell else {
            return UICollectionViewCell()
        }

        let model = locations[indexPath.item]
        cell.locaName.text = model.name
        cell.tempLabel.text = model.temp != nil ? "\(Int(model.temp!))℃" : "로딩 중..."
        cell.statusLabel.text = model.description
        cell.locabg.image = UIImage(named: model.imageName)

        return cell
    }
}

extension RiderCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = locations[indexPath.item]
        let viewModel = RiderViewModel()
        viewModel.updateLocation(lat: model.lat, lon: model.lon)

        let detailVC = RiderDetailViewController()
        // ViewModel을 detailVC에 설정하는 방법 (detailVC에 viewModel 프로퍼티가 있다면)
        // detailVC.viewModel = viewModel
        detailVC.setLocation(lat: model.lat, lon: model.lon, locationName: model.name)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
