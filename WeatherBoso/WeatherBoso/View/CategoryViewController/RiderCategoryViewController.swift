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

struct LocationWeatherModel {
    let name: String
    let lat: Double
    let lon: Double
    let temp: Double
    let description: String
    let imageName: String
}

final class RiderCategoryViewController: UIViewController {
    
    private let searchBar = SearchBar()
    
    private let disposeBag = DisposeBag()
    lazy var collection = UICollectionView(
        frame: .zero, collectionViewLayout: collectionSet()
    )
    
    private let locations: [LocationWeatherModel] = [
            LocationWeatherModel(
                name: "경기도 남양주 화음길",
                lat: 37.6519,
                lon: 127.2165,
                temp: 25,
                description: "Mostly Sunny",
                imageName: "hwaEumgil"
            ),
            LocationWeatherModel(
                name: "경상남도 남해 19번 국도",
                lat: 34.8374,
                lon: 127.8635,
                temp: 25,
                description: "Mostly Sunny",
                imageName: "namHae"
            ),
            LocationWeatherModel(
                name: "제주도 신창 풍차 해안도로",
                lat: 33.3004,
                lon: 126.1743,
                temp: 25,
                description: "Mostly Sunny",
                imageName: "sinChang"
            ),
            LocationWeatherModel(
                name: "강원도 새천년 해안도로",
                lat: 37.6024,
                lon: 129.1175,
                temp: 25,
                description: "Mostly Sunny",
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
        cell.tempLabel.text = "\(Int(model.temp))℃"
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
