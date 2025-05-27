//
//  BaseBallCategoryView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BaseBallCategoryViewController: UIViewController{
    
    private let searchBar = SearchBar()
    private let viewModel = BaseBallViewModel()
    private var data: [StadiumModel] = []
    private let disposeBag = DisposeBag()
    lazy var collection = UICollectionView(
        frame: .zero, collectionViewLayout: collectionSet()
    )
    
    private let customNavBar: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.circle",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.setTitle("  야구보소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GmarketSansTTFMedium", size: 29)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data = viewModel.stadiumInfo
        [collection, searchBar, customNavBar].forEach { view.addSubview($0) }
        customNavBar.addSubview(backButton)
        view.backgroundColor = .white
        setConst()
        
        collection.register(BaseballCell.self, forCellWithReuseIdentifier: BaseballCell.id)
        backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        bind()
        viewModel.fetchAllStadiumWeather()
    }
    
    private func setConst() {
        
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
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(100)
        }
        
    }
    
    private func collectionSet() -> UICollectionViewCompositionalLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(
            top: 10, leading: 15,
            bottom: 13, trailing: 15)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(110)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func bind() {
        // 컬렉션뷰 바인딩
        viewModel.categoryHomeScreen
            .bind(to: collection.rx.items(
                cellIdentifier: BaseballCell.id,
                cellType: BaseballCell.self
            )) { index, model, cell in
                cell.setData(with: model)
            }
            .disposed(by: disposeBag)
        
        // 셀 누르면 디테일뷰로 이동
        collection.rx.modelSelected(StadiumModel.self)
            .bind { [weak self] stadium in
                guard let self = self,
                      let weather = self.viewModel.weatherDict[stadium.stadiumName] else { return }
                
                let detailVC = BaseBallDetailViewController(stadium: stadium, weather: weather)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        // 검색필터
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] keyword in
                self?.viewModel.searchStadiums(for: keyword)
            }
            .disposed(by: disposeBag)
        
        viewModel.categoryHomeScreen.accept(viewModel.weatherPerDay.value)
        
    }
}

